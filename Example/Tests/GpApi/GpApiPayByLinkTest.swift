import XCTest
import GlobalPayments_iOS_SDK

final class GpApiPayByLinkTest: XCTestCase {

    private var payByLink: PayByLinkData!
    private var card: CreditCardData!
    private var address: Address!
    private var browserData: BrowserData!
    private var payByLinkId: String?
    
    private let CURRENCY = "CAD"
    private let AMOUNT: NSDecimalNumber = 7.8

    override class func setUp() {
        super.setUp()
        
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transactions_cnp_cp_bnpl_apm_paybylinks_3ds"

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "",
            appKey: "",
            channel: .cardNotPresent,
            country: "CA",
            accessTokenInfo: accessTokenInfo
        ))
    }
    
    override func setUp() {
        super.setUp()
        
        payByLink = PayByLinkData()
        payByLink.type = .payment
        payByLink.usageMode = .single
        payByLink.allowedPaymentMethods = [PaymentMethodName.card]
        payByLink.usageLimit = "1"
        payByLink.name = "Mobile Bill Payment"
        payByLink.isShippable = true
        payByLink.shippingAmount = 1.23
        payByLink.expirationDate = Date().addDays(10)
        payByLink.images = ["test", "test2", "test3"]
        payByLink.returnUrl = "https://www.example.com/returnUrl"
        payByLink.statusUpdateUrl = "https://www.example.com/statusUrl"
        payByLink.cancelUrl = "https://www.example.com/returnUrl"
        
        address = Address()
        address.streetAddress1 = "Apartment 852"
        address.streetAddress2 = "Complex 741"
        address.streetAddress3 = "no"
        address.city = "Chicago"
        address.postalCode = "5001"
        address.state = "IL"
        address.countryCode = "840"
        
        card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cardPresent = true
        
        browserData = BrowserData()
        browserData.acceptHeader = "text/html,application/xhtml+xml,application/xml;q=9,image/webp,img/apng,*/*;q=0.8"
        browserData.colorDepth = .twentyFourBits
        browserData.ipAddress = "123.123.123.123"
        browserData.javaEnabled = true
        browserData.language = "en"
        browserData.screenHeight = 1080
        browserData.screenWidth = 1920
        browserData.challengeWindowSize = .windowed600x400
        browserData.timezone = "0"
        browserData.userAgent =
                "Mozilla/5.0 (Windows NT 6.1; Win64, x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36"
        
        let expectation =  expectation(description: "PayByLink expectation")
        let startDate = Date().addDays(-40)
        let endDate = Date()
        
        let findPayByLinkService = PayByLinkService.findPayByLink(page: 1, pageSize: 1)
        
        findPayByLinkService.orderBy(.timeCreated, direction: .ascending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(status: .ACTIVE)
            .execute { response, error in
                if response?.results.count ?? 0 > 0 {
                    self.payByLinkId = response?.results.first?.id
                }
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(payByLinkId)
    }
    
    public func test_report_pay_link_detail() {
        // GIVEN
        let payByLinkId = "LNK_sG66QoMtgRlxbxFZNZDqqOBz7xMx5c"
        let expectation = expectation(description: "PayByLink detail Expectation")
        let service = PayByLinkService.payByLinkDetail(payByLinkId)
        var response: PayByLinkSummary?
        var error: Error?
        
        // WHEN
        service.execute {
            response = $0
            error = $1
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual(payByLinkId, response?.id)
    }
    
    public func test_report_pay_link_detail_random_link_id() {
        // GIVEN
        let payByLinkId = UUID().uuidString
        let expectation = expectation(description: "PayByLink detail Expectation")
        let service = PayByLinkService.payByLinkDetail(payByLinkId)
        var response: PayByLinkSummary?
        var error: GatewayException?
        
        // WHEN
        service.execute {
            response = $0
            if let errorException = $1 as? GatewayException {
                error = errorException
            }
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual("RESOURCE_NOT_FOUND", error?.responseCode)
        XCTAssertEqual("40118", error?.responseMessage)
        XCTAssertEqual("Status Code: 404 - Links \(payByLinkId) not found at this /ucp/links/\(payByLinkId)", error?.message)
    }
    
    public func test_report_pay_link_detail_nil_link_id() {
        // GIVEN
        let expectation = expectation(description: "PayByLink detail Expectation")
        let service = PayByLinkService.payByLinkDetail(nil)
        var response: PayByLinkSummary?
        var error: BuilderException?
        
        // WHEN
        service.execute {
            response = $0
            if let errorException = $1 as? BuilderException {
                error = errorException
            }
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(error)
        XCTAssertNil(response)
        XCTAssertEqual("payByLinkId cannot be nil for this rule", error?.message)
    }
    
    public func test_find_pay_link_by_date() {
        // GIVEN
        let expectation = expectation(description: "PayByLink detail Expectation")
        var response: PagedResult<PayByLinkSummary>?
        var error: Error?
        let startDate = Date().addDays(-40)
        let endDate = Date()
        let service = PayByLinkService.findPayByLink(page: 1, pageSize: 10)
        
        // WHEN
        service.orderBy(.timeCreated, direction: .ascending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }
        
        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertNotNil(response?.results)
        let payByLinkData = response?.results.first
        XCTAssertNotNil(payByLinkData)
    }
    
    public func test_find_pay_link_by_date_no_results() {
        // GIVEN
        let expectation = expectation(description: "PayByLink detail Expectation")
        var response: PagedResult<PayByLinkSummary>?
        var error: Error?
        let startDate = Date().addYears(-1).addDays(60)
        let endDate = Date().addYears(-1).addDays(60)
        let service = PayByLinkService.findPayByLink(page: 1, pageSize: 5)
        
        // WHEN
        service.orderBy(.timeCreated, direction: .ascending)
            .withStartDate(startDate)
            .withEndDate(endDate)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }
        
        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertNotNil(response?.results)
        XCTAssertEqual(0, response?.results.count)
        XCTAssertEqual(0, response?.totalRecordCount)
    }
    
    public func test_create_pay_link() {
        // GIVEN
        let expectation = expectation(description: "PayByLink detail Expectation")
        var response: Transaction?
        var error: Error?
        let clientId = UUID().uuidString
        
        payByLink.type = .payment
        payByLink.usageMode = .single
        payByLink.allowedPaymentMethods = [ PaymentMethodName.card ]
        payByLink.usageLimit = "1"
        payByLink.name = "Mobile Bill Payment"
        payByLink.isShippable = true
        payByLink.shippingAmount = 1.23
        payByLink.expirationDate = Date().addDays(10)
        payByLink.images = [ "test", "test2", "test3" ]
        payByLink.returnUrl = "https://www.example.com/returnUrl"
        payByLink.statusUpdateUrl = "https://www.example.com/statusUrl"
        payByLink.cancelUrl = "https://www.example.com/returnUrl"

        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(clientId)
            .withDescription("March and April Invoice")
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 5.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
    }
    
    public func test_create_pay_link_multiple_usage() {
        // GIVEN
        let expectation = expectation(description: "PayByLink detail Expectation")
        var response: Transaction?
        var error: Error?
        let clientId = UUID().uuidString
        payByLink.usageMode = .multiple
        payByLink.usageLimit = "2"

        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(clientId)
            .withDescription("March and April Invoice")
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual(2, response?.payByLinkResponse?.usageLimit)
    }
    
    
    public func test_edit_pay_link() {
        // GIVEN
        let expectationToSearch = expectation(description: "PayByLink Search Expectation")
        var response: PagedResult<PayByLinkSummary>?
        var error: Error?
        let startDate = Date().addDays(-10)
        let endDate = Date()
        let service = PayByLinkService.findPayByLink(page: 1, pageSize: 5)
        
        // WHEN
        service.orderBy(.timeCreated, direction: .ascending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(status: .ACTIVE)
            .execute {
                response = $0
                error = $1
                expectationToSearch.fulfill()
            }
        
        // THEN
        wait(for: [expectationToSearch], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertTrue(response?.results.count ?? 0 > 0)
        
        let payByLinkDataToUpdate = response?.results.first
        XCTAssertNotNil(payByLinkDataToUpdate)
        XCTAssertNotNil(payByLinkDataToUpdate?.id)
        
        // GIVEN
        let expectationToUpdate = expectation(description: "PayByLink Update Expectation")
        var responseToUpdate: Transaction?
        let payByLinkData = PayByLinkData()
        payByLinkData.name = "Test of Test"
        payByLinkData.usageMode = .multiple
        payByLinkData.type = .payment
        payByLinkData.usageLimit = "5"
        let amountToUpdate: NSDecimalNumber = 10.08
        
        // WHEN
        PayByLinkService.edit(payByLinkId: payByLinkDataToUpdate?.id, amount: amountToUpdate)
            .withPayByLinkData(payByLinkData)
            .withDescription("Update PayByLink description")
            .execute {
                responseToUpdate = $0
                error = $1
                expectationToUpdate.fulfill()
            }
        
        wait(for: [expectationToUpdate], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(responseToUpdate)
        XCTAssertNotNil(responseToUpdate?.payByLinkResponse)
        XCTAssertEqual("SUCCESS", responseToUpdate?.responseCode)
        XCTAssertEqual(PayByLinkStatus.ACTIVE.rawValue, responseToUpdate?.responseMessage)
        XCTAssertEqual(amountToUpdate, responseToUpdate?.balanceAmount)
        XCTAssertNotNil(responseToUpdate?.payByLinkResponse?.url)
        XCTAssertNotNil(responseToUpdate?.payByLinkResponse?.id)
    }
    
    public func test_create_pay_link_then_charge() {
        // GIVEN
        let expecatationToCreate = expectation(description: "PayByLink Create expectation")
        var response: Transaction?
        var error: Error?
        payByLink.images = [ "One", "Two", "Three" ]

        
        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(UUID().uuidString)
            .withDescription("March and April Invoice")
            .execute {
                response = $0
                error = $1
                expecatationToCreate.fulfill()
            }
        
        // THEN
        wait(for: [expecatationToCreate], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        assertTransactionResponse(response)
        
        // GIVEN
        let expectationToCharge = expectation(description: "PayByLink Charge expectation")
        var responseCharge: Transaction?
        var errorCharge: Error?
        setupTransactionConfig()
        
        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withPaymentLink(response?.payByLinkResponse?.id)
            .execute(configName: "createTransaction") {
                responseCharge = $0
                errorCharge =  $1
                expectationToCharge.fulfill()
            }
        
        wait(for: [expectationToCharge], timeout: 10.0)
        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, responseCharge?.responseMessage)
        
        // GIVEN
        let expectationDetail = expectation(description: "PayByLink Detail expectation")
        var responseDetail: PayByLinkSummary?
        var errorDetail: Error?
        
        // WHEN
        PayByLinkService.payByLinkDetail(response?.payByLinkResponse?.id)
            .execute {
                responseDetail = $0
                errorDetail = $1
                expectationDetail.fulfill()
            }
        
        wait(for: [expectationDetail], timeout: 10.0)
        XCTAssertNil(errorDetail)
        XCTAssertNotNil(responseDetail)
        XCTAssertEqual(response?.payByLinkResponse?.id, responseDetail?.id)
        XCTAssertEqual(1, responseDetail?.transactions?.count)
    }
    
    private func assertTransactionResponse(_ transaction: Transaction?) {
        XCTAssertEqual("SUCCESS", transaction?.responseCode)
        XCTAssertEqual(PayByLinkStatus.ACTIVE.rawValue, transaction?.responseMessage)
        XCTAssertEqual(AMOUNT, transaction?.balanceAmount)
        XCTAssertNotNil(transaction?.payByLinkResponse?.url)
        XCTAssertNotNil(transaction?.payByLinkResponse?.id)
    }
    
    private func setupTransactionConfig() {
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "v2yRaFOLwFaQc0fSZTCyAdQCBNByGpVK",
            appKey: "oKZpWitk6tORoCVT",
            channel: .cardNotPresent,
            challengeNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            methodNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            merchantContactUrl: "https://enp4qhvjseljg.x.pipedream.net/"
        ), configName: "createTransaction")
    }
    
    // MARK: - POST /links positive cases

    public func test_create_pay_link_response_fields() {
        // GIVEN
        let expectation = expectation(description: "PayByLink Create expectation")
        var response: Transaction?
        var error: Error?
        let clientId = UUID().uuidString

        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(clientId)
            .withDescription("3 x pizzas, 4 x 7up")
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        assertTransactionResponse(response)
        let linkResponse = response?.payByLinkResponse
        XCTAssertNotNil(linkResponse)
        XCTAssertEqual(PaymentMethodUsageMode.single, linkResponse?.usageMode)
        XCTAssertEqual(1, linkResponse?.usageLimit)
        XCTAssertEqual(PayByLinkStatus.ACTIVE, linkResponse?.status)
        XCTAssertEqual(payByLink.name, linkResponse?.name)
        XCTAssertEqual(clientId, linkResponse?.reference)
        XCTAssertEqual(true, linkResponse?.isShippable)
    }

    public func test_create_pay_link_without_images() {
        // GIVEN
        let expectation = expectation(description: "PayByLink Create expectation")
        var response: Transaction?
        var error: Error?
        payByLink.images = nil

        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(UUID().uuidString)
            .withDescription("March and April Invoice")
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        assertTransactionResponse(response)
    }

    public func test_create_pay_link_not_shippable() {
        // GIVEN
        let expectation = expectation(description: "PayByLink Create expectation")
        var response: Transaction?
        var error: Error?
        payByLink.isShippable = false
        payByLink.shippingAmount = nil

        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(UUID().uuidString)
            .withDescription("March and April Invoice")
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        assertTransactionResponse(response)
        XCTAssertEqual(false, response?.payByLinkResponse?.isShippable)
    }

    // MARK: - POST /links negative cases

    public func test_create_pay_link_missing_type() {
        // GIVEN
        payByLink.type = nil

        // WHEN
        let error = createPayByLinkExpectingError()

        // THEN
        assertMandatoryDataMissing(error, field: "type")
    }

    public func test_create_pay_link_missing_usage_mode() {
        // GIVEN
        payByLink.usageMode = nil

        // WHEN
        let error = createPayByLinkExpectingError()

        // THEN
        assertMandatoryDataMissing(error, field: "usage_mode")
    }

    public func test_create_pay_link_missing_name() {
        // GIVEN
        payByLink.name = nil

        // WHEN
        let error = createPayByLinkExpectingError()

        // THEN
        assertMandatoryDataMissing(error, field: "name")
    }

    public func test_create_pay_link_missing_allowed_payment_methods() {
        // GIVEN
        payByLink.allowedPaymentMethods = nil

        // WHEN
        let error = createPayByLinkExpectingError()

        // THEN
        assertMandatoryDataMissing(error, field: "transactions.allowed_payment_methods")
    }

    public func test_create_pay_link_missing_description() {
        // GIVEN
        let expectation = expectation(description: "PayByLink Create expectation")
        var response: Transaction?
        var error: GatewayException?

        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(UUID().uuidString)
            .execute {
                response = $0
                error = $1 as? GatewayException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        assertMandatoryDataMissing(error, field: "description")
    }

    public func test_create_pay_link_missing_currency() {
        // GIVEN
        let expectation = expectation(description: "PayByLink Create expectation")
        var response: Transaction?
        var error: GatewayException?

        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withClientTransactionId(UUID().uuidString)
            .withDescription("March and April Invoice")
            .execute {
                response = $0
                error = $1 as? GatewayException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        assertMandatoryDataMissing(error, field: "currency")
    }

    public func test_create_pay_link_invalid_currency() {
        // GIVEN
        let expectation = expectation(description: "PayByLink Create expectation")
        var response: Transaction?
        var error: GatewayException?

        // WHEN
        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency("QQQ")
            .withClientTransactionId(UUID().uuidString)
            .withDescription("March and April Invoice")
            .execute {
                response = $0
                error = $1 as? GatewayException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertNotNil(error?.responseCode)
        XCTAssertTrue(error?.message?.contains("Status Code: 400") == true)
    }

    // MARK: - GET /links/{id} positive cases

    public func test_pay_link_detail_after_create() {
        // GIVEN
        let reference = UUID().uuidString
        let linkDescription = "March and April Invoice"
        let createExpectation = expectation(description: "PayByLink Create expectation")
        var created: Transaction?
        var createError: Error?

        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(reference)
            .withDescription(linkDescription)
            .execute {
                created = $0
                createError = $1
                createExpectation.fulfill()
            }

        wait(for: [createExpectation], timeout: 20.0)
        XCTAssertNil(createError)
        let createdId = created?.payByLinkResponse?.id
        XCTAssertNotNil(createdId)

        // WHEN
        let (response, error) = payByLinkDetail(createdId)

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual(createdId, response?.id)
        XCTAssertEqual(created?.payByLinkResponse?.url, response?.url)
        XCTAssertEqual(PayByLinkStatus.ACTIVE, response?.status)
        XCTAssertEqual(PayByLinkType.payment, response?.type)
        XCTAssertEqual(PaymentMethodUsageMode.single, response?.usageMode)
        XCTAssertEqual("1", response?.usageLimit)
        XCTAssertEqual("0", response?.usageCount)
        XCTAssertEqual(payByLink.name, response?.name)
        XCTAssertEqual(linkDescription, response?.descriptionSummary)
        XCTAssertEqual(reference, response?.reference)
        XCTAssertEqual("YES", response?.shippable?.uppercased())
        XCTAssertEqual(AMOUNT, response?.amount)
        XCTAssertEqual(CURRENCY, response?.currency)
        XCTAssertEqual([PaymentMethodName.card], response?.allowedPaymentMethods)
        XCTAssertNotNil(response?.expirationDate)
    }

    public func test_pay_link_detail_merchant_metadata() {
        // WHEN
        let (response, error) = payByLinkDetail(payByLinkId)

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertNotNil(response?.merchantId)
        XCTAssertNotNil(response?.merchantName)
        XCTAssertNotNil(response?.accountId)
        XCTAssertNotNil(response?.accountName)
    }

    public func test_pay_link_detail_matches_find_result() {
        // GIVEN
        let (list, listError) = findPayByLink(page: 1, pageSize: 1) {
            $0.orderBy(.timeCreated, direction: .descending)
                .withStartDate(Date().addDays(-20))
                .withEndDate(Date())
        }
        XCTAssertNil(listError)
        let summary = list?.results.first
        XCTAssertNotNil(summary)

        // WHEN
        let (response, error) = payByLinkDetail(summary?.id)

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual(summary?.id, response?.id)
        XCTAssertEqual(summary?.status, response?.status)
        XCTAssertEqual(summary?.name, response?.name)
        XCTAssertEqual(summary?.usageMode, response?.usageMode)
    }

    // MARK: - GET /links/{id} negative cases

    public func test_pay_link_detail_unknown_link_id() {
        // GIVEN
        let unknownId = "LNK_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"

        // WHEN
        let (response, error) = payByLinkDetail(unknownId)

        // THEN
        XCTAssertNil(response)
        let gatewayError = error as? GatewayException
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("RESOURCE_NOT_FOUND", gatewayError?.responseCode)
        XCTAssertEqual("40118", gatewayError?.responseMessage)
    }

    public func test_pay_link_detail_empty_link_id() {
        // WHEN
        let (response, error) = payByLinkDetail("")

        // THEN
        XCTAssertNil(response)
        let gatewayError = error as? GatewayException
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("MANDATORY_DATA_MISSING", gatewayError?.responseCode)
        XCTAssertEqual("40223", gatewayError?.responseMessage)
    }

    public func test_pay_link_detail_with_invalid_credentials() {
        // GIVEN
        let configName = "invalidPayByLinkDetailCredentials"
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "X2QS2alAbhURA3NLwr73pNicdoPijJEp",
            appKey: "invalidAppKey",
            channel: .cardNotPresent,
            country: "CA"
        ), configName: configName)

        let expectation = expectation(description: "PayByLink detail Expectation")
        var response: PayByLinkSummary?
        var error: Error?

        // WHEN
        PayByLinkService.payByLinkDetail(payByLinkId)
            .execute(configName: configName) {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 20.0)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
    }

    /// Executes a `GET /links/{id}` request.
    private func payByLinkDetail(_ linkId: String?) -> (PayByLinkSummary?, Error?) {
        let expectation = expectation(description: "PayByLink detail Expectation")
        var response: PayByLinkSummary?
        var error: Error?

        PayByLinkService.payByLinkDetail(linkId)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 20.0)
        return (response, error)
    }

    // MARK: - GET /links positive cases

    public func test_find_pay_link_by_id() {
        // GIVEN
        let linkId = payByLinkId

        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withPayByLinkId(linkId)
                .withStartDate(Date().addDays(-40))
                .withEndDate(Date())
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertTrue(response?.results.isEmpty == false)
    }

    public func test_find_pay_link_by_status_active() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withStartDate(Date().addDays(-40))
                .withEndDate(Date())
                .withPayByLinkStatus(.ACTIVE)
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertTrue(response?.results.isEmpty == false)
        response?.results.forEach { XCTAssertEqual(PayByLinkStatus.ACTIVE, $0.status) }
    }

    public func test_find_pay_link_by_usage_mode_single() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withStartDate(Date().addDays(-40))
                .withEndDate(Date())
                .withUsageMode(.single)
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        response?.results.forEach { XCTAssertEqual(PaymentMethodUsageMode.single, $0.usageMode) }
    }

    public func test_find_pay_link_by_shippable() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withStartDate(Date().addDays(-40))
                .withEndDate(Date())
                .withShippable(true)
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        response?.results.forEach { XCTAssertEqual("YES", $0.shippable?.uppercased()) }
    }

    public func test_find_pay_link_by_name() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withStartDate(Date().addDays(-40))
                .withEndDate(Date())
                .withDisplayName("Mobile Bill Payment")
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        response?.results.forEach { XCTAssertEqual("Mobile Bill Payment", $0.name) }
    }

    public func test_find_pay_link_paging_metadata() {
        // GIVEN
        let pageSize = 3

        // WHEN total_record_count is only returned for ranges of a month or less
        let (response, error) = findPayByLink(page: 1, pageSize: pageSize) {
            $0.withStartDate(Date().addDays(-20))
                .withEndDate(Date())
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual(1, response?.page)
        XCTAssertEqual(pageSize, response?.pageSize)
        XCTAssertTrue(response?.results.count ?? 0 <= pageSize)
        XCTAssertNotNil(response?.totalRecordCount)
    }

    public func test_find_pay_link_order_by_time_created_descending() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.orderBy(.timeCreated, direction: .descending)
                .withStartDate(Date().addDays(-40))
                .withEndDate(Date())
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual("DESC", response?.order)
        XCTAssertEqual("TIME_CREATED", response?.orderBy)

        // GIVEN ascending request returns the same set in the opposite order
        let (ascendingResponse, ascendingError) = findPayByLink(page: 1, pageSize: 10) {
            $0.orderBy(.timeCreated, direction: .ascending)
                .withStartDate(Date().addDays(-40))
                .withEndDate(Date())
        }

        // THEN
        XCTAssertNil(ascendingError)
        XCTAssertNotNil(ascendingResponse)
        XCTAssertEqual("ASC", ascendingResponse?.order)
        if let first = response?.results.first?.id,
           let ascendingFirst = ascendingResponse?.results.first?.id,
           (response?.totalRecordCount ?? 0) > 1 {
            XCTAssertNotEqual(first, ascendingFirst)
        }
    }

    public func test_find_pay_link_by_second_page() {
        // WHEN
        let (firstPage, firstPageError) = findPayByLink(page: 1, pageSize: 1) {
            $0.orderBy(.timeCreated, direction: .ascending)
                .withStartDate(Date().addDays(-40))
                .withEndDate(Date())
        }
        let (secondPage, secondPageError) = findPayByLink(page: 2, pageSize: 1) {
            $0.orderBy(.timeCreated, direction: .ascending)
                .withStartDate(Date().addDays(-40))
                .withEndDate(Date())
        }

        // THEN
        XCTAssertNil(firstPageError)
        XCTAssertNil(secondPageError)
        XCTAssertEqual(1, firstPage?.page)
        XCTAssertEqual(2, secondPage?.page)
        if let firstId = firstPage?.results.first?.id,
           let secondId = secondPage?.results.first?.id {
            XCTAssertNotEqual(firstId, secondId)
        }
    }

    // MARK: - GET /links negative cases

    public func test_find_pay_link_by_unknown_name() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withStartDate(Date().addDays(-40))
                .withEndDate(Date())
                .withDisplayName(UUID().uuidString)
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual(0, response?.results.count)
    }

    public func test_find_pay_link_by_unknown_reference() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withStartDate(Date().addDays(-40))
                .withEndDate(Date())
                .withReferenceNumber(UUID().uuidString)
        }

        // THEN
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual(0, response?.results.count)
    }

    public func test_find_pay_link_start_date_after_end_date() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withStartDate(Date())
                .withEndDate(Date().addDays(-40))
        }

        // THEN
        XCTAssertNil(response)
        let gatewayError = error as? GatewayException
        XCTAssertNotNil(gatewayError)
        XCTAssertNotNil(gatewayError?.responseCode)
    }

    public func test_find_pay_link_invalid_page() {
        // WHEN
        let (response, error) = findPayByLink(page: 0, pageSize: 10) {
            $0.withStartDate(Date().addDays(-40))
                .withEndDate(Date())
        }

        // THEN
        XCTAssertNil(response)
        let gatewayError = error as? GatewayException
        XCTAssertNotNil(gatewayError)
        XCTAssertEqual("INVALID_REQUEST_DATA", gatewayError?.responseCode)
    }

    public func test_find_pay_link_invalid_currency() {
        // WHEN
        let (response, error) = findPayByLink(page: 1, pageSize: 10) {
            $0.withStartDate(Date().addDays(-40))
                .withEndDate(Date())
                .withCurrency("QQQ")
        }

        // THEN
        if let gatewayError = error as? GatewayException {
            XCTAssertTrue(gatewayError.message?.contains("Status Code: 400") == true)
        } else {
            XCTAssertNil(error)
            XCTAssertEqual(0, response?.results.count)
        }
    }

    public func test_find_pay_link_with_invalid_credentials() {
        // GIVEN
        let configName = "invalidPayByLinkCredentials"
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "X2QS2alAbhURA3NLwr73pNicdoPijJEp",
            appKey: "invalidAppKey",
            channel: .cardNotPresent,
            country: "CA"
        ), configName: configName)

        let expectation = expectation(description: "PayByLink find expectation")
        var response: PagedResult<PayByLinkSummary>?
        var error: Error?

        // WHEN
        PayByLinkService.findPayByLink(page: 1, pageSize: 10)
            .withStartDate(Date().addDays(-40))
            .withEndDate(Date())
            .execute(configName: configName) {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 20.0)
        XCTAssertNil(response)
        XCTAssertNotNil(error)
    }

    /// Executes a `GET /links` request, applying the given criteria to the report builder.
    private func findPayByLink(page: Int,
                               pageSize: Int,
                               criteria: (TransactionReportBuilder<PagedResult<PayByLinkSummary>>) -> TransactionReportBuilder<PagedResult<PayByLinkSummary>>)
    -> (PagedResult<PayByLinkSummary>?, Error?) {
        let expectation = expectation(description: "PayByLink find expectation")
        var response: PagedResult<PayByLinkSummary>?
        var error: Error?

        let service = criteria(PayByLinkService.findPayByLink(page: page, pageSize: pageSize))
        service.execute {
            response = $0
            error = $1
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 20.0)
        return (response, error)
    }

    /// Executes a create Pay By Link request with the current `payByLink` fixture and
    /// returns the gateway error, asserting that no transaction was returned.
    private func createPayByLinkExpectingError(file: StaticString = #filePath,
                                               line: UInt = #line) -> GatewayException? {
        let expectation = expectation(description: "PayByLink Create expectation")
        var response: Transaction?
        var error: GatewayException?

        PayByLinkService.create(payByLink: payByLink, amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withClientTransactionId(UUID().uuidString)
            .withDescription("March and April Invoice")
            .execute {
                response = $0
                error = $1 as? GatewayException
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response, file: file, line: line)
        return error
    }

    private func assertMandatoryDataMissing(_ error: GatewayException?,
                                            field: String,
                                            file: StaticString = #filePath,
                                            line: UInt = #line) {
        XCTAssertNotNil(error, file: file, line: line)
        XCTAssertEqual("MANDATORY_DATA_MISSING", error?.responseCode, file: file, line: line)
        XCTAssertEqual("40005", error?.responseMessage, file: file, line: line)
        XCTAssertTrue(error?.message?.contains(field) == true,
                      "Expected error message to mention \(field) but was \(error?.message ?? "nil")",
                      file: file, line: line)
    }
}
