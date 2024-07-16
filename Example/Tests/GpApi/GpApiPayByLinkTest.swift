import XCTest
import GlobalPayments_iOS_SDK

final class GpApiPayByLinkTest: XCTestCase {

    private var payByLink: PayByLinkData!
    private var card: CreditCardData!
    private var address: Address!
    private var browserData: BrowserData!
    private var payByLinkId: String?
    
    private let CURRENCY = "GBP"
    private let AMOUNT: NSDecimalNumber = 7.8

    override class func setUp() {
        super.setUp()
        
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "LinkManagement"

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "v2yRaFOLwFaQc0fSZTCyAdQCBNByGpVK",
            appKey: "oKZpWitk6tORoCVT",
            channel: .cardNotPresent,
            country: "GB",
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
        let payByLinkId = "LNK_qz4JvAIOrFChQ1lpmxVDyPBPteNKpC"
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
}
