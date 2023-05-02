import XCTest
import GlobalPayments_iOS_SDK

final class GpApiPayLinkTest: XCTestCase {

    private var payLink: PayLinkData!
    private var card: CreditCardData!
    private var address: Address!
    private var browserData: BrowserData!
    private var payLinkId: String?
    
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
        
        payLink = PayLinkData()
        payLink.type = .payment
        payLink.usageMode = .single
        payLink.allowedPaymentMethods = [PaymentMethodName.card]
        payLink.usageLimit = "1"
        payLink.name = "Mobile Bill Payment"
        payLink.isShippable = true
        payLink.shippingAmount = 1.23
        payLink.expirationDate = Date().addDays(10)
        payLink.images = ["test", "test2", "test3"]
        payLink.returnUrl = "https://www.example.com/returnUrl"
        payLink.statusUpdateUrl = "https://www.example.com/statusUrl"
        payLink.cancelUrl = "https://www.example.com/returnUrl"
        
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
        
        let expectation =  expectation(description: "Paylink expectation")
        let startDate = Date().addDays(-40)
        let endDate = Date()
        
        let findPayLinkService = PayLinkService.findPayLink(page: 1, pageSize: 1)
        
        findPayLinkService.orderBy(.timeCreated, direction: .ascending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(payLinkStatus: .ACTIVE)
            .execute { response, error in
                if response?.results.count ?? 0 > 0 {
                    self.payLinkId = response?.results.first?.id
                }
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(payLinkId)
    }
    
    public func test_report_pay_link_detail() {
        // GIVEN
        let payLinkId = "LNK_qz4JvAIOrFChQ1lpmxVDyPBPteNKpC"
        let expectation = expectation(description: "PayLink detail Expectation")
        let service = PayLinkService.payLinkDetail(payLinkId)
        var response: PayLinkSummary?
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
        XCTAssertEqual(payLinkId, response?.id)
    }
    
    public func test_report_pay_link_detail_random_link_id() {
        // GIVEN
        let payLinkId = UUID().uuidString
        let expectation = expectation(description: "PayLink detail Expectation")
        let service = PayLinkService.payLinkDetail(payLinkId)
        var response: PayLinkSummary?
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
        XCTAssertEqual("Status Code: 404 - Links \(payLinkId) not found at this /ucp/links/\(payLinkId)", error?.message)
    }
    
    public func test_report_pay_link_detail_nil_link_id() {
        // GIVEN
        let expectation = expectation(description: "PayLink detail Expectation")
        let service = PayLinkService.payLinkDetail(nil)
        var response: PayLinkSummary?
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
        XCTAssertEqual("payLinkId cannot be nil for this rule", error?.message)
    }
    
    public func test_find_pay_link_by_date() {
        // GIVEN
        let expectation = expectation(description: "PayLink detail Expectation")
        var response: PagedResult<PayLinkSummary>?
        var error: Error?
        let startDate = Date().addDays(-40)
        let endDate = Date()
        let service = PayLinkService.findPayLink(page: 1, pageSize: 10)
        
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
        let payLinkData = response?.results.first
        XCTAssertNotNil(payLinkData)
    }
    
    public func test_find_pay_link_by_date_no_results() {
        // GIVEN
        let expectation = expectation(description: "PayLink detail Expectation")
        var response: PagedResult<PayLinkSummary>?
        var error: Error?
        let startDate = Date().addYears(-1).addDays(60)
        let endDate = Date().addYears(-1).addDays(60)
        let service = PayLinkService.findPayLink(page: 1, pageSize: 5)
        
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
        let expectation = expectation(description: "PayLink detail Expectation")
        var response: Transaction?
        var error: Error?
        let clientId = UUID().uuidString
        
        payLink.type = .payment
        payLink.usageMode = .single
        payLink.allowedPaymentMethods = [ PaymentMethodName.card ]
        payLink.usageLimit = "1"
        payLink.name = "Mobile Bill Payment"
        payLink.isShippable = true
        payLink.shippingAmount = 1.23
        payLink.expirationDate = Date().addDays(10)
        payLink.images = [ "test", "test2", "test3" ]
        payLink.returnUrl = "https://www.example.com/returnUrl"
        payLink.statusUpdateUrl = "https://www.example.com/statusUrl"
        payLink.cancelUrl = "https://www.example.com/returnUrl"

        // WHEN
        PayLinkService.create(payLink: payLink, amount: AMOUNT)
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
        let expectation = expectation(description: "PayLink detail Expectation")
        var response: Transaction?
        var error: Error?
        let clientId = UUID().uuidString
        payLink.usageMode = .multiple
        payLink.usageLimit = "2"

        // WHEN
        PayLinkService.create(payLink: payLink, amount: AMOUNT)
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
        XCTAssertEqual(2, response?.payLinkResponse?.usageLimit)
    }
    
    
    public func test_edit_pay_link() {
        // GIVEN
        let expectationToSearch = expectation(description: "PayLink Search Expectation")
        var response: PagedResult<PayLinkSummary>?
        var error: Error?
        let startDate = Date().addDays(-10)
        let endDate = Date()
        let service = PayLinkService.findPayLink(page: 1, pageSize: 5)
        
        // WHEN
        service.orderBy(.timeCreated, direction: .ascending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(payLinkStatus: .ACTIVE)
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
        
        let payLinkDataToUpdate = response?.results.first
        XCTAssertNotNil(payLinkDataToUpdate)
        XCTAssertNotNil(payLinkDataToUpdate?.id)
        
        // GIVEN
        let expectationToUpdate = expectation(description: "PayLink Update Expectation")
        var responseToUpdate: Transaction?
        let payLinkData = PayLinkData()
        payLinkData.name = "Test of Test"
        payLinkData.usageMode = .multiple
        payLinkData.type = .payment
        payLinkData.usageLimit = "5"
        let amountToUpdate: NSDecimalNumber = 10.08
        
        // WHEN
        PayLinkService.edit(payLinkId: payLinkDataToUpdate?.id, amount: amountToUpdate)
            .withPayLinkData(payLinkData)
            .withDescription("Update Paylink description")
            .execute {
                responseToUpdate = $0
                error = $1
                expectationToUpdate.fulfill()
            }
        
        wait(for: [expectationToUpdate], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(responseToUpdate)
        XCTAssertNotNil(responseToUpdate?.payLinkResponse)
        XCTAssertEqual("SUCCESS", responseToUpdate?.responseCode)
        XCTAssertEqual(PayLinkStatus.ACTIVE.rawValue, responseToUpdate?.responseMessage)
        XCTAssertEqual(amountToUpdate, responseToUpdate?.balanceAmount)
        XCTAssertNotNil(responseToUpdate?.payLinkResponse?.url)
        XCTAssertNotNil(responseToUpdate?.payLinkResponse?.id)
    }
    
    public func test_create_pay_link_then_charge() {
        // GIVEN
        let expecatationToCreate = expectation(description: "PayLink Create expectation")
        var response: Transaction?
        var error: Error?
        payLink.images = [ "One", "Two", "Three" ]

        
        // WHEN
        PayLinkService.create(payLink: payLink, amount: AMOUNT)
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
        let expectationToCharge = expectation(description: "PayLink Charge expectation")
        var responseCharge: Transaction?
        var errorCharge: Error?
        setupTransactionConfig()
        
        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withPaymentLink(response?.payLinkResponse?.id)
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
        let expectationDetail = expectation(description: "PayLink Detail expectation")
        var responseDetail: PayLinkSummary?
        var errorDetail: Error?
        
        // WHEN
        PayLinkService.payLinkDetail(response?.payLinkResponse?.id)
            .execute {
                responseDetail = $0
                errorDetail = $1
                expectationDetail.fulfill()
            }
        
        wait(for: [expectationDetail], timeout: 10.0)
        XCTAssertNil(errorDetail)
        XCTAssertNotNil(responseDetail)
        XCTAssertEqual(response?.payLinkResponse?.id, responseDetail?.id)
        XCTAssertEqual(1, responseDetail?.transactions?.count)
    }
    
    private func assertTransactionResponse(_ transaction: Transaction?) {
        XCTAssertEqual("SUCCESS", transaction?.responseCode)
        XCTAssertEqual(PayLinkStatus.ACTIVE.rawValue, transaction?.responseMessage)
        XCTAssertEqual(AMOUNT, transaction?.balanceAmount)
        XCTAssertNotNil(transaction?.payLinkResponse?.url)
        XCTAssertNotNil(transaction?.payLinkResponse?.id)
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
