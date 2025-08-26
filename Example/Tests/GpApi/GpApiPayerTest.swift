import XCTest
import GlobalPayments_iOS_SDK

final class GpApiPayerTest: XCTestCase {
    
    private var newCustomer: Customer!
    private var card: CreditCardData!
    private var billingAddress: Address!
    private var shippingAddress: Address!
    
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
        
        newCustomer = Customer()
        newCustomer.key = UUID().uuidString
        newCustomer.firstName = "James"
        newCustomer.lastName = "Mason"

        card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "131"
        card.cardHolderName = "James Mason"

        // billing address
        billingAddress = Address()
        billingAddress.streetAddress1 = "10 Glenlake Pkwy NE"
        billingAddress.streetAddress2 = "no"
        billingAddress.city = "Birmingham"
        billingAddress.postalCode = "50001"
        billingAddress.countryCode = "US"
        billingAddress.state = "IL"

        // shipping address
        shippingAddress = Address()
        shippingAddress.streetAddress1 = "Apartment 852"
        shippingAddress.streetAddress2 = "Complex 741"
        shippingAddress.streetAddress3 = "no"
        shippingAddress.city = "Birmingham"
        shippingAddress.postalCode = "50001"
        shippingAddress.state = "IL"
        shippingAddress.countryCode = "US"
    }
    
    func test_create_payer() {
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        var token: String!
        var tokenizedError: Error?
        
        // WHEN
        card.tokenize {
            token = $0
            self.card.token = $0
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(token)
        
        // GIVEN
        let tokenizedCard2Expectation = expectation(description: "Tokenized Card 2 Expectation")
        var token2: String!
        var tokenized2Error: Error?
        newCustomer.addRecurringPaymentMethod(paymentId: token, paymentMethod: card)

        let card2 = CreditCardData()
        card2.number = "4012001038488884"
        card2.expMonth = Date().currentMonth
        card2.expYear = Date().currentYear + 1
        card2.cvn = "131"
        card2.cardHolderName = "James Mason"
        
        // WHEN
        card2.tokenize {
            token2 = $0
            card2.token = $0
            tokenized2Error = $1
            tokenizedCard2Expectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCard2Expectation], timeout: 10.0)
        XCTAssertNil(tokenized2Error)
        XCTAssertNotNil(token2)
        
        // GIVEN
        let createPayerExpectation = expectation(description: "Create Payer Expectation")
        var payer: Customer?
        var createPayerError: Error?
        newCustomer.addRecurringPaymentMethod(paymentId: token2, paymentMethod: card2)
        
        // WHEN
        newCustomer.create {
            payer = $0
            createPayerError = $1
            createPayerExpectation.fulfill()
        }
        
        //THEN
        wait(for: [createPayerExpectation], timeout: 10.0)
        XCTAssertNil(createPayerError)
        XCTAssertNotNil(payer)
        XCTAssertNotNil(payer?.id)
    }
    
    func test_create_payer_without_payment_methods() {
        // GIVEN
        let createPayerExpectation = expectation(description: "Create Payer Expectation")
        var payer: Customer?
        var createPayerError: Error?
        
        // WHEN
        newCustomer.create {
            payer = $0
            createPayerError = $1
            createPayerExpectation.fulfill()
        }
        
        //THEN
        wait(for: [createPayerExpectation], timeout: 10.0)
        XCTAssertNil(createPayerError)
        XCTAssertNotNil(payer)
        XCTAssertEqual(newCustomer.firstName?.first, payer?.firstName?.first)
        XCTAssertEqual(newCustomer.lastName?.first, payer?.lastName?.first)
        XCTAssertNil(payer?.paymentMethods)
    }
    
    func test_create_payer_without_firstName() {
        // GIVEN
        let createPayerExpectation = expectation(description: "Create Payer Expectation")
        var payer: Customer?
        var createPayerError: GatewayException?
        newCustomer = Customer()
        newCustomer.key = UUID().uuidString
        newCustomer.lastName = "Mason"
        
        // WHEN
        newCustomer.create {
            payer = $0
            if let error = $1 as? GatewayException {
                createPayerError = error
            }
            createPayerExpectation.fulfill()
        }

        //THEN
        wait(for: [createPayerExpectation], timeout: 10.0)
        XCTAssertNil(payer)
        XCTAssertNotNil(createPayerError)
        XCTAssertEqual(createPayerError?.message, "Status Code: 400 - Request expects the following fields: first_name")
        XCTAssertEqual(createPayerError?.responseMessage, "40005")
    }
    
    func test_create_payer_without_lastName() {
        // GIVEN
        let createPayerExpectation = expectation(description: "Create Payer Expectation")
        var payer: Customer?
        var createPayerError: GatewayException?
        newCustomer = Customer()
        newCustomer.key = UUID().uuidString
        newCustomer.firstName = "James"
        
        // WHEN
        newCustomer.create {
            payer = $0
            if let error = $1 as? GatewayException {
                createPayerError = error
            }
            createPayerExpectation.fulfill()
        }

        //THEN
        wait(for: [createPayerExpectation], timeout: 10.0)
        XCTAssertNil(payer)
        XCTAssertNotNil(createPayerError)
        XCTAssertEqual(createPayerError?.message, "Status Code: 400 - Request expects the following fields: last_name")
        XCTAssertEqual(createPayerError?.responseMessage, "40005")
    }
    
    func test_edit_payer() {
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        var token: String!
        var tokenizedError: Error?
        let key = "payer-123"
        let id = "PYR_df7aebe8e356430caf1a3f3b5a8eef71"
        newCustomer.key = key
        newCustomer.id = id
        
        // WHEN
        card.tokenize {
            token = $0
            self.card.token = $0
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(token)
        
        // GIVEN
        let editPayerExpectation = expectation(description: "Edit Payer Expectation")
        var payer: Customer?
        var editPayerError: Error?
        newCustomer.addRecurringPaymentMethod(paymentId: token, paymentMethod: card)
        
        // WHEN
        newCustomer.saveChanges {
            payer = $0
            editPayerError = $1
            editPayerExpectation.fulfill()
        }
        
        //THEN
        wait(for: [editPayerExpectation], timeout: 10.0)
        XCTAssertNil(editPayerError)
        XCTAssertNotNil(payer)
        XCTAssertEqual(newCustomer.key, payer?.key)
        XCTAssertTrue(payer?.paymentMethods?.count ?? 0 > 0)
        XCTAssertEqual(card.token, payer?.paymentMethods?.first?.id)
    }
    
    func test_edit_payer_without_customer_id() {
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        var token: String!
        var tokenizedError: Error?
        let key = "payer-123"
        newCustomer.key = key
        
        // WHEN
        card.tokenize {
            token = $0
            self.card.token = $0
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(token)
        
        // GIVEN
        let editPayerExpectation = expectation(description: "Edit Payer Expectation")
        var payer: Customer?
        var editPayerError: GatewayException?
        newCustomer.addRecurringPaymentMethod(paymentId: token, paymentMethod: card)
        
        // WHEN
        newCustomer.saveChanges {
            payer = $0
            if let error = $1 as? GatewayException {
                editPayerError = error
            }
            editPayerExpectation.fulfill()
        }
        
        //THEN
        wait(for: [editPayerExpectation], timeout: 10.0)
        XCTAssertNil(payer)
        XCTAssertNotNil(editPayerError)
        XCTAssertEqual(editPayerError?.message, "Status Code: 400 - Validation failed for object=\'terminalConfigPartner\'. Error count: 2")
        XCTAssertEqual(editPayerError?.responseMessage, "40041")
    }
    
    func test_edit_payer_with_random_id() {
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        var token: String!
        var tokenizedError: Error?
        let key = "payer-123"
        let id = "PYR_" + UUID().uuidString
        newCustomer.key = key
        newCustomer.id = id
        
        // WHEN
        card.tokenize {
            token = $0
            self.card.token = $0
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(token)
        
        // GIVEN
        let editPayerExpectation = expectation(description: "Edit Payer Expectation")
        var payer: Customer?
        var editPayerError: GatewayException?
        newCustomer.addRecurringPaymentMethod(paymentId: token, paymentMethod: card)
        
        // WHEN
        newCustomer.saveChanges {
            payer = $0
            if let error = $1 as? GatewayException {
                editPayerError = error
            }
            editPayerExpectation.fulfill()
        }
        
        //THEN
        wait(for: [editPayerExpectation], timeout: 10.0)
        XCTAssertNil(payer)
        XCTAssertNotNil(editPayerError)
        XCTAssertEqual(editPayerError?.message, "Status Code: 404 - Payer \(newCustomer.id ?? "") not found at this location")
        XCTAssertEqual(editPayerError?.responseMessage, "40008")
    }
    
    func gpApiPayerInitialize() {
        let config = GpApiConfig(
            appId: "DgRZQ6DAwWtwl6tVGBS6EgnsfVG5SiXh",
            appKey: "cayFg03gE0Ei7TLB",
            channel: .cardNotPresent
        )
        
        config.merchantId = "MER_7e3e2c7df34f42819b3edee31022ee3f"
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
    }
    
    func test_Create_Payer_With_MerchantId() {
        gpApiPayerInitialize()
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        var token: String!
        var tokenizedError: Error?
        
        // WHEN
        card.tokenize {
            token = $0
            self.card.token = $0
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(token)
        newCustomer.addRecurringPaymentMethod(paymentId: token, paymentMethod: card)
        
        // GIVEN
        let tokenizedCard2Expectation = expectation(description: "Tokenized Card 2 Expectation")
        var token2: String!
        var tokenized2Error: Error?
        
        let card2 = CreditCardData()
        card2.number = "4012001038488884"
        card2.expMonth = Date().currentMonth
        card2.expYear = Date().currentYear + 1
        card2.cvn = "131"
        card2.cardHolderName = "James Mason"
        
        // WHEN
        card2.tokenize {
            token2 = $0
            card2.token = $0
            tokenized2Error = $1
            tokenizedCard2Expectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCard2Expectation], timeout: 10.0)
        XCTAssertNil(tokenized2Error)
        XCTAssertNotNil(token2)
        
        // GIVEN
        let createPayerExpectation = expectation(description: "Create Payer Expectation")
        var payer: Customer?
        var createPayerError: Error?
        newCustomer.addRecurringPaymentMethod(paymentId: token2, paymentMethod: card2)
        
        // WHEN
        newCustomer.create {
            payer = $0
            createPayerError = $1
            createPayerExpectation.fulfill()
        }
        
        //THEN
        wait(for: [createPayerExpectation], timeout: 10.0)
        XCTAssertNil(createPayerError)
        XCTAssertNotNil(payer)
        XCTAssertNotNil(payer?.paymentMethods)
        XCTAssertNotNil(payer?.id)
        XCTAssertEqual(newCustomer.firstName?.first, payer?.firstName?.first)
        XCTAssertEqual(newCustomer.lastName?.first, payer?.lastName?.first)
        
        if let paymentMethods = payer?.paymentMethods {
            for pm in paymentMethods {
                let tokensArray: [String?] = [card2.token, card.token]
                let tokensList = tokensArray
                XCTAssertTrue(tokensList.contains(pm.id))
            }
        }
    }
}
