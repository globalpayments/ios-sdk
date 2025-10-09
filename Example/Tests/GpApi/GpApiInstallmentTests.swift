import XCTest
import GlobalPayments_iOS_SDK

final class GpApiInstallmentTests: XCTestCase {

    final private var installmentData = InstallmentData()
    private let amount = NSDecimalNumber(2.02)
    private let APP_ID = ""
    private let APP_KEY = ""
    private let currency = "MXN"
    final private var storedCredential: StoredCredential? = nil
    private let FIRST_PAGE = 2
    private let PAGE_SIZE = 10
    private var masterCard =  CreditCardData()
    private var visaCard = CreditCardData()
    private var amexCard = CreditCardData()
    private var carnetCard = CreditCardData()
    private var testVisaCard = CreditCardData()
    private let startDate = Date().addYears(-1).addDays(1)
    private var REPORTING_START_DATE = Date().addMonths(-6)
    
    override func setUp() {
        super.setUp()
        installmentConfiguration()
    }
    
    func installmentConfiguration() {
        let config = GpApiConfig(
            appId: APP_ID,
            appKey: APP_KEY
        )
        config.channel = .cardNotPresent
        config.country = "MX"
        
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        accessTokenInfo.riskAssessmentAccountName = "transaction_processing"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
        
        installmentData.mode = "INTEREST"
        installmentData.program = "SIP"
        installmentData.count = "99"
        installmentData.gracePeriodCount = "30"
        
        storedCredential = StoredCredential(
            type: StoredCredentialType.installment,
            initiator: StoredCredentialInitiator.merchant,
            sequence: StoredCredentialSequence.subsequent,
            reason: StoredCredentialReason.incremental,
            contractReference: "testref"
        )
        
        masterCard.number = "4263970000005262"
        masterCard.expMonth = 12
        masterCard.expYear = 2026
        masterCard.cvn = "123"
        masterCard.cardPresent = false
        masterCard.readerPresent = false
        
        visaCard.number = "4263970000005262"
        visaCard.expMonth = 12
        visaCard.expYear = 2026
        visaCard.cvn = "123"
        visaCard.cardPresent = false
        visaCard.readerPresent = false
        
        carnetCard.number = "4263970000005262"
        carnetCard.expMonth = 12
        carnetCard.expYear = 2026
        carnetCard.cvn = "123"
        carnetCard.cardPresent = false
        carnetCard.readerPresent = false
        carnetCard.cardType = "carnet"

    }
    
    func testCreditSaleForInstallmentMC() {
        
        let expectationCreditSaleForInstallment = expectation(description: "Credit Sale For Installment MC")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .withStoredCredential(storedCredential)
            .withInstallmentData(installmentData)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectationCreditSaleForInstallment.fulfill()
            }
        
        wait(for: [expectationCreditSaleForInstallment], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
    }
    
    func testCreditSaleForInstallmentVisa() {
        let expectationCreditSaleForInstallment = expectation(description: "Credit Sale For Installment Visa")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .withStoredCredential(storedCredential)
            .withInstallmentData(installmentData)
            .execute {transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectationCreditSaleForInstallment.fulfill()
            }
        
        wait(for: [expectationCreditSaleForInstallment], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
     }
    
    func testCreditSaleForInstallmentCarnet() {
        let expectationCreditSaleForInstallment = expectation(description: "Credit Sale For Installment Carnet")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        carnetCard.charge(amount: amount)
            .withCurrency(currency)
            .withStoredCredential(storedCredential)
            .withInstallmentData(installmentData)
            .execute {transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectationCreditSaleForInstallment.fulfill()
            }
        
        wait(for: [expectationCreditSaleForInstallment], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
    }
    
    func testCreditSaleWithoutInstallmentData() {
        let expectationCreditSaleForInstallment = expectation(description: "Credit Sale For without Installment")
        
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        visaCard.charge(amount: amount)
            .withCurrency(currency)
            .withStoredCredential(storedCredential)
            .execute {transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectationCreditSaleForInstallment.fulfill()
            }
        
        wait(for: [expectationCreditSaleForInstallment], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(amount, responseCharge?.balanceAmount)
        XCTAssertEqual("CAPTURED", responseCharge?.responseMessage)
        XCTAssertNil(responseCharge?.installmentData)
    }
    
    func testReportTransactionDetailForInstallmentByID() {
        let expectationInstallmentByID = expectation(description: "Credit Sale For Installment by ID")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .withStoredCredential(storedCredential)
            .withInstallmentData(installmentData)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectationInstallmentByID.fulfill()
            }
        
        wait(for: [expectationInstallmentByID], timeout: 10.0)
        XCTAssertNil(errorResponse)
        
        sleep(UInt32(30.0))
        
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        var transactionSummaryResponse: TransactionSummary?
        var transactionSummaryError: Error?
        
        ReportingService
            .transactionDetail(transactionId: responseCharge?.transactionId ?? "")
            .execute { transactionSummary, error in
                transactionSummaryResponse = transactionSummary
                transactionSummaryError = error
                reportingExecuteExpectation.fulfill()
            }
        
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        
        XCTAssertNotNil(transactionSummaryResponse)
        XCTAssertNotNil(transactionSummaryResponse?.installmentData)
        XCTAssertNil(transactionSummaryError)
        XCTAssertEqual(installmentData.program, transactionSummaryResponse?.installmentData?.program)
        XCTAssertEqual(installmentData.mode, transactionSummaryResponse?.installmentData?.mode)
        XCTAssertEqual(installmentData.count, transactionSummaryResponse?.installmentData?.count)
        XCTAssertEqual(installmentData.gracePeriodCount, transactionSummaryResponse?.installmentData?.gracePeriodCount)
    }
    
    func testReportTransactionsDetailForInstallment() {
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        
        let reportingService = ReportingService.findTransactionsPaged(page: FIRST_PAGE, pageSize: PAGE_SIZE)
        
        let startDate = Date().addMonths(-6)
        
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?
        
        reportingService
            .where(.startDate, startDate)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }
        
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        
       for transactionSummery in transactionsSummaryResponse ?? [] {
           XCTAssertNotNil(transactionSummery.installmentData)
        }
    }

    func testReportTransactionDetailWithoutInstallmentByID() {
        let expectationWithoutInstallmentByID = expectation(description: "Credit Sale For Without Installment by ID")
        var responseCharge: Transaction?
        var errorResponse: Error?
        
        masterCard.charge(amount: amount)
            .withCurrency(currency)
            .withStoredCredential(storedCredential)
            .execute { transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectationWithoutInstallmentByID.fulfill()
            }
        
        wait(for: [expectationWithoutInstallmentByID], timeout: 10.0)
        XCTAssertNil(errorResponse)
        
        sleep(UInt32(30.0))
        
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetailException")
        var transactionSummaryResponse: TransactionSummary?
        var transactionSummaryError: Error?
        
        ReportingService
            .transactionDetail(transactionId: responseCharge?.transactionId ?? "")
            .execute { transactionSummary, error in
                transactionSummaryResponse = transactionSummary
                transactionSummaryError = error
                reportingExecuteExpectation.fulfill()
            }
        
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        
        XCTAssertNotNil(transactionSummaryResponse)
        XCTAssertNotNil(transactionSummaryResponse?.installmentData)
        XCTAssertNil(transactionSummaryError)
        XCTAssertEqual("", transactionSummaryResponse?.installmentData?.program)
        XCTAssertEqual("", transactionSummaryResponse?.installmentData?.mode)
        XCTAssertEqual("", transactionSummaryResponse?.installmentData?.count)
        XCTAssertEqual("", transactionSummaryResponse?.installmentData?.gracePeriodCount)
    }
}

