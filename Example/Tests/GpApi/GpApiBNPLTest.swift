import XCTest
import GlobalPayments_iOS_SDK

final class GpApiBNPLTest: XCTestCase {
    
    private var paymentMethod: BNPL!
    private var shippingAddress: Address!
    private var billingAddress: Address!
    
    private let CURRENCY = "USD"

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "4gPqnGBkppGYvoE5UX9EWQlotTxGUDbs",
            appKey: "FQyJA5VuEQfcji2M",
            channel: .cardNotPresent
        ))
    }
    
    override func setUp() {
        super.setUp()
        paymentMethod = BNPL()
        paymentMethod.BNPLType = .AFFIRM
        paymentMethod.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.cancelUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        
        // shipping address
        shippingAddress = Address()
        shippingAddress.streetAddress1 = "Apartment 852"
        shippingAddress.streetAddress2 = "Complex 741"
        shippingAddress.streetAddress3 = "no"
        shippingAddress.city = "Birmingham"
        shippingAddress.postalCode = "50001"
        shippingAddress.state = "IL"
        shippingAddress.countryCode = "US"
        
        // billing address
        billingAddress = Address()
        billingAddress.streetAddress1 = "Apartment 852"
        billingAddress.streetAddress2 = "Complex 741"
        billingAddress.streetAddress3 = "no"
        billingAddress.city = "Birmingham"
        billingAddress.postalCode = "50001"
        billingAddress.state = "IL"
        billingAddress.countryCode = "US"
    }
    
    func test_BNPL_full_cycle() {
        // GIVEN
        let customer = customer
        let products = products
        let expectationFullCycle = expectation(description: "BNPL full cycle Expectation")
        var responseFullCycle: Transaction?
        var errorFullCycle: Error?
        
        // WHEN
        paymentMethod.authorize(amount: 10)
            .withCurrency(CURRENCY)
            .withMiscProductData(products)
            .withAddress(shippingAddress, type: .shipping)
            .withAddress(billingAddress, type: .billing)
            .withPhoneNumber("1", number: "7708298000", type: .Shipping)
            .withCustomerData(customer)
            .withBNPLShippingMethod(.DELIVERY)
            .execute {
                responseFullCycle = $0
                errorFullCycle = $1
                expectationFullCycle.fulfill()
            }
        
        // THEN
        wait(for: [expectationFullCycle], timeout: 5.0)
        XCTAssertNil(errorFullCycle)
        XCTAssertNotNil(responseFullCycle)
        XCTAssertEqual("SUCCESS", responseFullCycle?.responseCode)
        XCTAssertEqual(TransactionStatus.initiated.mapped(for: .gpApi), responseFullCycle?.responseMessage)
        
        // Complete this flow in Web Browser
        print(responseFullCycle?.bnplResponse?.redirectUrl ?? "")
        sleep(60)
        
        // GIVEN
        let expectationCapture = expectation(description: "BNPL capture Expectation")
        var responseCapture: Transaction?
        var errorCapture: Error?
        
        // WHEN
        responseFullCycle?.capture()
            .execute{
                responseCapture = $0
                errorCapture = $1
                expectationCapture.fulfill()
            }
        
        // THEN
        wait(for: [expectationCapture], timeout: 5.0)
        XCTAssertNil(errorCapture)
        XCTAssertNotNil(responseCapture)
        XCTAssertEqual("SUCCESS", responseCapture?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.mapped(for: .gpApi), responseCapture?.responseMessage)
        
        // GIVEN
        let expectationRefund = expectation(description: "BNPL refund Expectation")
        var responseRefund: Transaction?
        var errorRefund: Error?
        
        // WHEN
        responseCapture?.refund(amount: 5)
            .withCurrency(CURRENCY)
            .execute{
                responseRefund = $0
                errorRefund = $1
                expectationRefund.fulfill()
            }
        
        // THEN
        wait(for: [expectationRefund], timeout: 5.0)
        XCTAssertNil(errorRefund)
        XCTAssertNotNil(responseRefund)
        XCTAssertEqual("SUCCESS", responseRefund?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.mapped(for: .gpApi), responseRefund?.responseMessage)
    }
    
    func test_BNPL_only_mandatory() {
        // GIVEN
        let customer = customer
        let products = products
        let expectation = expectation(description: "BNPL mandatory Expectation")
        var response: Transaction?
        var error: Error?
        
        // WHEN
        paymentMethod.authorize(amount: 550)
            .withCurrency(CURRENCY)
            .withMiscProductData(products)
            .withAddress(shippingAddress, type: .shipping)
            .withAddress(billingAddress, type: .billing)
            .withCustomerData(customer)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }
        
        // THEN
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertEqual(TransactionStatus.initiated.mapped(for: .gpApi), response?.responseMessage)
        XCTAssertNotNil(response?.bnplResponse?.redirectUrl)
    }
    
    func test_BNPL_klarna_provider() {
        // GIVEN
        paymentMethod.BNPLType = .KLARNA
        let customer = customer
        let products = products
        let expectationKlarna = expectation(description: "BNPL Klarna Expectation")
        var responseKlarna: Transaction?
        var errorKlarna: Error?
        
        // WHEN
        paymentMethod.authorize(amount: 550)
            .withCurrency(CURRENCY)
            .withMiscProductData(products)
            .withAddress(shippingAddress, type: .shipping)
            .withAddress(billingAddress, type: .billing)
            .withPhoneNumber("1", number: "7708298000", type: .Shipping)
            .withCustomerData(customer)
            .withBNPLShippingMethod(.DELIVERY)
            .execute {
                responseKlarna = $0
                errorKlarna = $1
                expectationKlarna.fulfill()
            }
        
        // THEN
        wait(for: [expectationKlarna], timeout: 5.0)
        XCTAssertNil(errorKlarna)
        XCTAssertNotNil(responseKlarna)
        XCTAssertEqual("SUCCESS", responseKlarna?.responseCode)
        XCTAssertEqual(TransactionStatus.initiated.mapped(for: .gpApi), responseKlarna?.responseMessage)
        
        // Complete this flow in Web Browser
        print(responseKlarna?.bnplResponse?.redirectUrl ?? "")
        sleep(60)
        
        // GIVEN
        let expectationCapture = expectation(description: "BNPL capture Expectation")
        var responseCapture: Transaction?
        var errorCapture: Error?
        
        // WHEN
        responseKlarna?.capture()
            .execute{
                responseCapture = $0
                errorCapture = $1
                expectationCapture.fulfill()
            }
        
        // THEN
        wait(for: [expectationCapture], timeout: 5.0)
        XCTAssertNil(errorCapture)
        XCTAssertNotNil(responseCapture)
        XCTAssertEqual("SUCCESS", responseCapture?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.mapped(for: .gpApi), responseCapture?.responseMessage)
    }
    
    func test_BNPL_clearpay_provider() {
        // GIVEN
        paymentMethod.BNPLType = .CLEARPAY
        let customer = customer
        let products = products
        let expectationClearPay = expectation(description: "BNPL Clear Pay Expectation")
        var responseClearPay: Transaction?
        var errorClearPay: Error?
        
        // WHEN
        paymentMethod.authorize(amount: 550)
            .withCurrency(CURRENCY)
            .withMiscProductData(products)
            .withAddress(shippingAddress, type: .shipping)
            .withAddress(billingAddress, type: .billing)
            .withPhoneNumber("1", number: "7708298000", type: .Shipping)
            .withCustomerData(customer)
            .withBNPLShippingMethod(.DELIVERY)
            .execute {
                responseClearPay = $0
                errorClearPay = $1
                expectationClearPay.fulfill()
            }
        
        // THEN
        wait(for: [expectationClearPay], timeout: 5.0)
        XCTAssertNil(errorClearPay)
        XCTAssertNotNil(responseClearPay)
        XCTAssertEqual("SUCCESS", responseClearPay?.responseCode)
        XCTAssertEqual(TransactionStatus.initiated.mapped(for: .gpApi), responseClearPay?.responseMessage)
        
        // Complete this flow in Web Browser
        print(responseClearPay?.bnplResponse?.redirectUrl ?? "")
        sleep(60)
        
        // GIVEN
        let expectationCapture = expectation(description: "BNPL capture Expectation")
        var responseCapture: Transaction?
        var errorCapture: Error?
        
        // WHEN
        responseClearPay?.capture()
            .execute{
                responseCapture = $0
                errorCapture = $1
                expectationCapture.fulfill()
            }
        
        // THEN
        wait(for: [expectationCapture], timeout: 5.0)
        XCTAssertNil(errorCapture)
        XCTAssertNotNil(responseCapture)
        XCTAssertEqual("SUCCESS", responseCapture?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.mapped(for: .gpApi), responseCapture?.responseMessage)
    }
    
    private lazy var customer: Customer = {
        let customer = Customer()
        customer.key = "12345678"
        customer.firstName = "James"
        customer.lastName = "Mason"
        customer.email = "james.mason@example.com"
        
        let phoneNumber = PhoneNumber()
        phoneNumber.countryCode = "1"
        phoneNumber.number = "7708298000"
        phoneNumber.areaCode = PhoneNumberType.Home.mapped(for: .gpApi)
        customer.phoneNumber = phoneNumber
        
        let customerDocument = CustomerDocument()
        customerDocument.reference = "123456789"
        customerDocument.issuer = "US"
        customerDocument.type = CustomerDocumentType.PASSPORT
        var documents: [CustomerDocument] = []
        documents.append(customerDocument)
        customer.documents = documents
        return customer
    }()
    
    private lazy var products: [Product] = {
        var products: [Product] = []
        let product = Product()
        product.productId = "92ebf294-f3ef-4aba-af30-6ebaf747de8f"
        product.productName = "iPhone 13"
        product.descriptionProduct = "iPhone 13"
        product.quantity = 1
        product.unitPrice = NSDecimalNumber(decimal: 550)
        product.taxAmount = NSDecimalNumber(decimal: 1)
        product.discountAmount = NSDecimalNumber(decimal: 0)
        product.taxPercentage = NSDecimalNumber(decimal: 0)
        product.netUnitAmount = NSDecimalNumber(decimal: 550)
        product.giftCardCurrency = CURRENCY
        product.url = "https://www.example.com/iphone.html"
        product.imageUrl = "https://www.example.com/iphone.png"
        products.append(product)
        return products
    }()
}
