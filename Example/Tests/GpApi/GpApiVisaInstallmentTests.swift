import XCTest
import GlobalPayments_iOS_SDK

final class GpApiVisaInstallmentTests: XCTestCase {

    private let APP_ID = ""
    private let APP_KEY = ""
    private let timeout: TimeInterval = 60.0

    private var installment: Installment!
    private var visaCard: CreditCardData!

    override func setUp() {
        super.setUp()
        configureService()
        installment = makeInstallment()
    }

    override func tearDown() {
        installment = nil
        visaCard = nil
        super.tearDown()
    }

    // MARK: - Setup helpers

    private func configureService() {
        let config = GpApiConfig(appId: APP_ID, appKey: APP_KEY)
        config.channel = .cardNotPresent
        config.country = "US"

        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "Portico_VISA_IPP_CNP_CERT"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
    }

    private func makeInstallment() -> Installment {
        visaCard = CreditCardData()
        visaCard.number = "4263970000005262"
        visaCard.expMonth = 12
        visaCard.expYear = 2030
        visaCard.cvn = "123"
        visaCard.cardPresent = false
        visaCard.readerPresent = false

        let installment = Installment()
        installment.AccountName = "Portico_VISA_IPP_CNP_CERT"
        installment.Channel = "CNP"
        installment.Amount = 50000
        installment.Currency = "USD"
        installment.Country = "US"
        installment.Reference = UUID().uuidString
        installment.Program = "VIS"
        installment.FundingMode = "CONSUMER_FUNDED"
        installment.EligiblePlans = "LIMITED"
        installment.EntryMode = "ECOM"
        installment.CardDetails = visaCard

        return installment
    }

    private func makeConfirmAvailableInstallment() -> Installment {
        let card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = 12
        card.expYear = 2030

        let installment = Installment()
        installment.AccountName = "Portico_mIpp_6865_Transaction_Processing"
        installment.Channel = "CP"
        installment.Amount = 11099
        installment.Currency = "USD"
        installment.Country = "US"
        installment.Reference = UUID().uuidString
        installment.EntryMode = "ECOM"
        installment.CardDetails = card
        
        return installment
    }
    
    private func createInstallment(description: String) -> (Installment?, Error?) {
        let expectation = expectation(description: description)
        var installmentResponse: Installment?
        var errorResponse: Error?

        installment.create { response, error in
            installmentResponse = response
            errorResponse = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
        return (installmentResponse, errorResponse)
    }

    // MARK: - Positive scenarios

    func test_CreateInstallment_VisaProgram_ReturnsAvailablePlans() {
        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - confirm available plans")

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertNotNil(response?.Id)
        XCTAssertTrue(response?.Id?.hasPrefix("INS_") ?? false)
        XCTAssertEqual("INSTALLMENT_QUERY", response?.Type)
        XCTAssertEqual("AVAILABLE", response?.Status)
        XCTAssertEqual("VIS", response?.Program)
        XCTAssertEqual("CNP", response?.Channel)
        XCTAssertEqual("USD", response?.Currency)
        XCTAssertEqual("US", response?.Country)
        XCTAssertEqual(50000, response?.Amount)
        XCTAssertEqual(installment.Reference, response?.Reference)
        XCTAssertNotNil(response?.TimeCreated)
        XCTAssertEqual("SUCCESS", response?.Action?.ResultCode)
        XCTAssertEqual("INSTALLMENT_QUERY", response?.Action?.Type)
        XCTAssertEqual("00", response?.Result)
        XCTAssertEqual("APPROVAL", response?.Message)
        XCTAssertEqual("ECOM", response?.EntryMode)
        XCTAssertEqual("VISA", response?.Card?.brand)
        XCTAssertEqual("XXXXXXXXXXXX5262", response?.Card?.maskedNumberLast4)
        XCTAssertFalse(response?.terms?.isEmpty ?? true)
    }

    func test_Confirm_Avaialability_Plan() {
        let installment = makeConfirmAvailableInstallment()
        
        let expectation = expectation(description: "Confirm Visa installments - available plans")
        var installmentResponse: Installment?
        var errorResponse: Error?

        installment.create { response, error in
            installmentResponse = response
            errorResponse = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(installmentResponse)
        XCTAssertTrue(installmentResponse?.Id?.hasPrefix("INS_") ?? false)
        XCTAssertEqual("INSTALLMENT_QUERY", installmentResponse?.Type)
        XCTAssertEqual("CP", installmentResponse?.Channel)
        XCTAssertEqual("USD", installmentResponse?.Currency)
        XCTAssertEqual("US", installmentResponse?.Country)
        XCTAssertEqual(11099, installmentResponse?.Amount)
        XCTAssertEqual(installment.Reference, installmentResponse?.Reference)
        XCTAssertEqual("SUCCESS", installmentResponse?.Action?.ResultCode)
        XCTAssertEqual("00", installmentResponse?.Result)
        XCTAssertEqual("APPROVAL", installmentResponse?.Message)
        XCTAssertEqual("VISA", installmentResponse?.Card?.brand)
        XCTAssertEqual("XXXXXXXXXXXX5262", installmentResponse?.Card?.maskedNumberLast4)
    }
    
    func test_CreateInstallment_VisaProgram_LimitedEligiblePlans_ReturnsAtMostTwoPlans() {
        // GIVEN
        installment.EligiblePlans = "LIMITED"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - LIMITED plans")

        // THEN
        XCTAssertNil(error)
        XCTAssertEqual("AVAILABLE", response?.Status)
        XCTAssertNotNil(response?.terms)
        XCTAssertLessThanOrEqual(response?.terms?.count ?? 0, 2)
    }

    func test_CreateInstallment_VisaProgram_FullEligiblePlans_ReturnsAllPlans() {
        // GIVEN
        installment.EligiblePlans = "FULL"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - FULL plans")

        // THEN
        XCTAssertNil(error)
        XCTAssertEqual("AVAILABLE", response?.Status)
        XCTAssertFalse(response?.terms?.isEmpty ?? true)
    }

    func test_CreateInstallment_VisaProgram_WithTermsConstraints_RespectsMaxTimeUnitNumber() {
        // GIVEN
        installment.EligiblePlans = "FULL"
        installment.RequestTerms = InstallmentTerms(maxTimeUnitNumber: "24", maxAmount: "1000000")

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - terms constraints")

        // THEN
        XCTAssertNil(error)
        XCTAssertEqual("AVAILABLE", response?.Status)
        XCTAssertFalse(response?.terms?.isEmpty ?? true)
        response?.terms?.forEach {
            XCTAssertLessThanOrEqual($0.count ?? 0, 24)
            XCTAssertEqual("MONTH", $0.TimeUnit)
        }
    }

    func test_CreateInstallment_VisaProgram_PlanDetailsAreMapped() {
        // GIVEN
        installment.EligiblePlans = "FULL"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - plan details")

        // THEN
        XCTAssertNil(error)
        guard let term = response?.terms?.first else {
            XCTFail("Expected at least one installment plan")
            return
        }
        XCTAssertNotNil(term.name)
        XCTAssertNotNil(term.reference)
        XCTAssertNotNil(term.mode)
        XCTAssertNotNil(term.count)
        XCTAssertNotNil(term.costPercentage)
        XCTAssertNotNil(term.totalPlanCost)
        XCTAssertNotNil(term.planAmount)
        XCTAssertNotNil(term.currency)
    }

    func test_CreateInstallment_VisaProgram_TermsAndConditionsAreMapped() {
        // GIVEN
        installment.EligiblePlans = "FULL"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - terms and conditions")

        // THEN
        XCTAssertNil(error)
        guard let termsAndConditions = response?.terms?.first?.termsAndConditions else {
            XCTFail("Expected terms and conditions on the installment plan")
            return
        }
        XCTAssertFalse(termsAndConditions.isEmpty)
        termsAndConditions.forEach {
            XCTAssertNotNil($0.url)
            XCTAssertNotNil($0.version)
            XCTAssertNotNil($0.termsDescription)
            XCTAssertNotNil($0.language)
        }
    }

    func test_CreateInstallment_VisaProgram_FeesAreMapped() {
        // GIVEN
        installment.EligiblePlans = "FULL"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - fees")

        // THEN
        XCTAssertNil(error)
        guard let fees = response?.terms?.first?.fees else {
            XCTFail("Expected fees on the installment plan")
            return
        }
        XCTAssertNotNil(fees.totalAmount)
        XCTAssertNotNil(fees.totalSubsequentAmount)
        XCTAssertNotNil(fees.subsequentAmount)
        XCTAssertNotNil(fees.totalUpfrontAmount)
        XCTAssertNotNil(fees.upfrontAmount)
        XCTAssertFalse(fees.feeInfo?.isEmpty ?? true)
        fees.feeInfo?.forEach {
            XCTAssertNotNil($0.type)
            XCTAssertNotNil($0.interestRate)
            XCTAssertNotNil($0.flatAmount)
        }
    }

    func test_CreateInstallment_VisaProgram_MerchantFundedMode_HasNoConsumerPlans() {
        // GIVEN
        installment.FundingMode = "MERCHANT_FUNDED"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - merchant funded")

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.Action?.ResultCode)
        XCTAssertEqual("NOT_AVAILABLE", response?.Status)
        XCTAssertTrue(response?.terms?.isEmpty ?? true)
    }

    // MARK: - Negative scenarios

    func test_CreateInstallment_WithInvalidProgram_ReturnsError() {
        // GIVEN
        installment.Program = "INVALID_PROGRAM"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - invalid program")

        // THEN
        XCTAssertNil(response)
        let gatewayException = error as? GatewayException
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayException?.responseCode)
        XCTAssertEqual("40213", gatewayException?.responseMessage)
        XCTAssertEqual("Status Code: 400 - program contains unexpected data", gatewayException?.message)
    }

    func test_CreateInstallment_WithInvalidFundingMode_ReturnsError() {
        // GIVEN
        installment.FundingMode = "INVALID_FUNDING_MODE"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - invalid funding mode")

        // THEN
        XCTAssertNil(response)
        let gatewayException = error as? GatewayException
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayException?.responseCode)
        XCTAssertEqual("40213", gatewayException?.responseMessage)
        XCTAssertEqual("Status Code: 400 - funding_mode contains unexpected data", gatewayException?.message)
    }

    func test_CreateInstallment_WithInvalidEligiblePlans_ReturnsError() {
        // GIVEN
        installment.EligiblePlans = "SOME_PLANS"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - invalid eligible plans")

        // THEN
        XCTAssertNil(response)
        let gatewayException = error as? GatewayException
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayException?.responseCode)
        XCTAssertEqual("40213", gatewayException?.responseMessage)
        XCTAssertEqual("Status Code: 400 - eligible_plans contains unexpected data", gatewayException?.message)
    }

    func test_CreateInstallment_WithInvalidCurrency_ReturnsError() {
        // GIVEN
        installment.Currency = "ZZZ"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - invalid currency")

        // THEN
        XCTAssertNil(response)
        let gatewayException = error as? GatewayException
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayException?.responseCode)
        XCTAssertEqual("40041", gatewayException?.responseMessage)
    }

    func test_CreateInstallment_WithoutAmount_ReturnsError() {
        // GIVEN
        installment.Amount = nil

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - missing amount")

        // THEN
        XCTAssertNil(response)
        let gatewayException = error as? GatewayException
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayException?.responseCode)
        XCTAssertEqual("Status Code: 400 - amount contains unexpected data", gatewayException?.message)
    }

    func test_CreateInstallment_WithInvalidCardNumber_IsDeclined() {
        // GIVEN
        visaCard.number = "4263970000005000"
        installment.CardDetails = visaCard

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - invalid card number")

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertNotEqual("AVAILABLE", response?.Status)
        XCTAssertEqual("05", response?.Result)
        XCTAssertTrue(response?.Message?.hasPrefix("DECLINE") ?? false)
        XCTAssertTrue(response?.terms?.isEmpty ?? true)
    }

    /// The gateway does not reject a past expiry date on an installment query.
    func test_CreateInstallment_WithPastExpiryDate_StillReturnsPlans() {
        // GIVEN
        visaCard.expMonth = 11
        visaCard.expYear = 2020
        installment.CardDetails = visaCard

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - past expiry date")

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual("AVAILABLE", response?.Status)
        XCTAssertEqual("00", response?.Result)
        XCTAssertEqual("APPROVAL", response?.Message)
    }

    func test_CreateInstallment_WithUnsupportedCountry_ReturnsError() {
        // GIVEN
        installment.Country = "ZZ"

        // WHEN
        let (response, error) = createInstallment(description: "Visa installments - unsupported country")

        // THEN
        XCTAssertNil(response)
        let gatewayException = error as? GatewayException
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayException?.responseCode)
    }

    func test_CreateInstallment_WithUnknownConfigName_ReturnsConfigurationError() {
        // GIVEN
        let expectation = expectation(description: "Visa installments - unknown config name")
        var installmentResponse: Installment?
        var errorResponse: Error?

        // WHEN
        installment.create(configName: "unknown_config") { response, error in
            installmentResponse = response
            errorResponse = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)

        // THEN
        XCTAssertNil(installmentResponse)
        XCTAssertNotNil(errorResponse)
    }
}

