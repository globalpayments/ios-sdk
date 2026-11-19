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
        XCTAssertNil(payer)
        XCTAssertNotNil(editPayerError)
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
        XCTAssertNil(payer)
        XCTAssertNotNil(editPayerError)
    }
    
    // MARK: - POST /payers (Create a Payer) - request / response fields

    func test_create_payer_with_all_request_fields_and_response_mapping() {
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        var token: String?
        var tokenizedError: Error?

        // WHEN
        card.tokenize {
            token = $0
            self.card.token = $0
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(token)

        // GIVEN
        let createPayerExpectation = expectation(description: "Create Payer Expectation")
        var payer: Customer?
        var createPayerError: Error?
        newCustomer.key = "payer-\(UUID().uuidString)"
        newCustomer.addRecurringPaymentMethod(paymentId: token, paymentMethod: card, isDefault: true)

        // WHEN
        newCustomer.create {
            payer = $0
            createPayerError = $1
            createPayerExpectation.fulfill()
        }

        // THEN
        wait(for: [createPayerExpectation], timeout: 10.0)
        XCTAssertNil(createPayerError)
        XCTAssertNotNil(payer)
        XCTAssertTrue(payer?.id?.hasPrefix("PYR_") ?? false)
        XCTAssertNotNil(payer?.timeCreated)
        XCTAssertNotNil(payer?.timeLastUpdated)
        XCTAssertNotNil(payer?.merchantId)
        XCTAssertNotNil(payer?.merchantName)
        XCTAssertNotNil(payer?.accountId)
        XCTAssertNotNil(payer?.accountName)
        XCTAssertEqual(payer?.key, newCustomer.key)
        XCTAssertNotNil(payer?.firstName)
        XCTAssertNotNil(payer?.lastName)
        XCTAssertEqual(payer?.paymentMethods?.count, 1)
        XCTAssertEqual(payer?.paymentMethods?.first?.id, token)
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
        XCTAssertTrue(payer?.action?.Id?.hasPrefix("ACT_") ?? false)
        XCTAssertEqual(payer?.action?.Type, "PAYER_CREATE")
        XCTAssertEqual(payer?.action?.ResultCode, "SUCCESS")
        XCTAssertNotNil(payer?.action?.TimeCreated)
        XCTAssertNotNil(payer?.action?.AppId)
        XCTAssertNotNil(payer?.action?.AppName)
    }

    func test_map_create_payer_documented_response() {
        // GIVEN
        let rawJson = """
        {
            "id": "PYR_e1f1a86a10944ae9abea5b091450b692",
            "time_created": "2021-05-03T21:23:39.718Z",
            "time_last_updated": "2021-05-03T21:23:40.718Z",
            "merchant_id": "MER_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
            "merchant_name": "merchant_1",
            "account_id": "TKA_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
            "account_name": "Tokenization",
            "first_name": "John",
            "last_name": "James",
            "reference": "payer-123",
            "email": "payer@email.com",
            "language": "en",
            "payment_methods": [
                {
                    "id": "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
                    "default": "YES"
                }
            ],
            "action": {
                "id": "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d",
                "type": "PAYER_CREATE",
                "time_created": "2021-05-03T21:23:39.718Z",
                "result_code": "SUCCESS",
                "app_id": "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d",
                "app_name": "my_lovely_app"
            }
        }
        """

        // WHEN
        let payer: Customer? = GpApiMapping.mapRecurringEntity(rawJson)

        // THEN
        XCTAssertEqual(payer?.id, "PYR_e1f1a86a10944ae9abea5b091450b692")
        XCTAssertEqual(payer?.timeCreated, "2021-05-03T21:23:39.718Z".format())
        XCTAssertEqual(payer?.timeLastUpdated, "2021-05-03T21:23:40.718Z".format())
        XCTAssertNotNil(payer?.timeCreated)
        XCTAssertNotNil(payer?.timeLastUpdated)
        XCTAssertEqual(payer?.merchantId, "MER_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.merchantName, "merchant_1")
        XCTAssertEqual(payer?.accountId, "TKA_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.accountName, "Tokenization")
        XCTAssertEqual(payer?.firstName, "John")
        XCTAssertEqual(payer?.lastName, "James")
        XCTAssertEqual(payer?.key, "payer-123")
        XCTAssertEqual(payer?.email, "payer@email.com")
        XCTAssertEqual(payer?.language, "en")
        XCTAssertEqual(payer?.paymentMethods?.count, 1)
        XCTAssertEqual(payer?.paymentMethods?.first?.id, "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
        XCTAssertEqual(payer?.action?.Id, "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(payer?.action?.Type, "PAYER_CREATE")
        XCTAssertEqual(payer?.action?.TimeCreated, "2021-05-03T21:23:39.718Z")
        XCTAssertEqual(payer?.action?.ResultCode, "SUCCESS")
        XCTAssertEqual(payer?.action?.AppId, "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(payer?.action?.AppName, "my_lovely_app")
    }

    func test_map_create_payer_sandbox_response_without_optional_fields() {
        // GIVEN
        let rawJson = """
        {
            "id": "PYR_09b7d92fd2f54a3a8e19b45beaf8daa7",
            "time_created": "2026-11-05T06:49:47.000Z",
            "time_last_updated": "2026-11-05T06:49:47.000Z",
            "first_name": "JXXX",
            "last_name": "JXXXX",
            "reference": "payer-123",
            "merchant_id": "MER_a38dd31cc8e5428fab9d958f0841100f",
            "merchant_name": "SDK_DEV_TEST",
            "account_id": "TKA_1d94afbbe2e54adc8d6dcb81a3f6ffd3",
            "account_name": "tokenization",
            "payment_methods": [
                {
                    "id": "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
                    "default": "YES"
                }
            ],
            "action": {
                "id": "ACT_S6kEDjxlN15vFROmyJl9F2CE5p1s2W",
                "type": "PAYER_CREATE",
                "time_created": "2026-11-05T06:49:47.685Z",
                "result_code": "SUCCESS",
                "app_id": "X2QS2alAbhURA3NLwr73pNicdoPijJEp",
                "app_name": "SDK_DEV_TEST"
            }
        }
        """

        // WHEN
        let payer: Customer? = GpApiMapping.mapRecurringEntity(rawJson)

        // THEN
        XCTAssertEqual(payer?.id, "PYR_09b7d92fd2f54a3a8e19b45beaf8daa7")
        XCTAssertNotNil(payer?.timeCreated)
        XCTAssertNotNil(payer?.timeLastUpdated)
        XCTAssertEqual(payer?.firstName, "JXXX")
        XCTAssertEqual(payer?.lastName, "JXXXX")
        XCTAssertEqual(payer?.key, "payer-123")
        XCTAssertEqual(payer?.merchantId, "MER_a38dd31cc8e5428fab9d958f0841100f")
        XCTAssertEqual(payer?.merchantName, "SDK_DEV_TEST")
        XCTAssertEqual(payer?.accountId, "TKA_1d94afbbe2e54adc8d6dcb81a3f6ffd3")
        XCTAssertEqual(payer?.accountName, "tokenization")
        XCTAssertNil(payer?.email)
        XCTAssertNil(payer?.language)
        XCTAssertEqual(payer?.paymentMethods?.first?.id, "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
        XCTAssertEqual(payer?.action?.Id, "ACT_S6kEDjxlN15vFROmyJl9F2CE5p1s2W")
        XCTAssertEqual(payer?.action?.Type, "PAYER_CREATE")
        XCTAssertEqual(payer?.action?.ResultCode, "SUCCESS")
        XCTAssertEqual(payer?.action?.AppId, "X2QS2alAbhURA3NLwr73pNicdoPijJEp")
        XCTAssertEqual(payer?.action?.AppName, "SDK_DEV_TEST")
    }

    // MARK: - PATCH /payers/{id} (Edit a Payer) - request / response fields

    private func createPayerForEdit(withPaymentMethod: Bool = true) -> (payer: Customer, token: String?) {
        var token: String?
        if withPaymentMethod {
            let tokenizedExpectation = expectation(description: "Tokenized Card Expectation")
            card.tokenize { newToken, _ in
                token = newToken
                self.card.token = newToken
                tokenizedExpectation.fulfill()
            }
            wait(for: [tokenizedExpectation], timeout: 10.0)
            XCTAssertNotNil(token)
            newCustomer.addRecurringPaymentMethod(paymentId: token, paymentMethod: card, isDefault: true)
        }

        let createExpectation = expectation(description: "Create Payer Expectation")
        var created: Customer?
        var createError: Error?
        newCustomer.create {
            created = $0
            createError = $1
            createExpectation.fulfill()
        }
        wait(for: [createExpectation], timeout: 10.0)
        XCTAssertNil(createError)
        XCTAssertNotNil(created?.id)
        return (created ?? Customer(), token)
    }

    private func edit(_ customer: Customer) -> (payer: Customer?, error: Error?) {
        let editExpectation = expectation(description: "Edit Payer Expectation")
        var edited: Customer?
        var editError: Error?
        customer.saveChanges {
            edited = $0
            editError = $1
            editExpectation.fulfill()
        }
        wait(for: [editExpectation], timeout: 10.0)
        return (edited, editError)
    }

    func test_edit_payer_name_only() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false).payer
        let editCustomer = Customer()
        editCustomer.id = created.id
        editCustomer.firstName = "John"
        editCustomer.lastName = "James"

        // WHEN
        let result = edit(editCustomer)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.id, created.id)
        XCTAssertNotNil(result.payer?.firstName)
        XCTAssertNotNil(result.payer?.lastName)
        XCTAssertNotNil(result.payer?.timeCreated)
        XCTAssertNotNil(result.payer?.timeLastUpdated)
        XCTAssertNotNil(result.payer?.merchantId)
        XCTAssertNotNil(result.payer?.accountId)
        XCTAssertEqual(result.payer?.action?.Type, "PAYER_EDIT")
        XCTAssertEqual(result.payer?.action?.ResultCode, "SUCCESS")
    }

    func test_edit_payer_remove_payment_methods() {
        // GIVEN
        let created = createPayerForEdit().payer
        XCTAssertEqual(created.paymentMethods?.count, 1)
        let editCustomer = Customer()
        editCustomer.id = created.id
        editCustomer.paymentMethods = []

        // WHEN
        let result = edit(editCustomer)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.id, created.id)
        XCTAssertTrue(result.payer?.paymentMethods?.isEmpty ?? true)
        XCTAssertEqual(result.payer?.action?.Type, "PAYER_EDIT")
        XCTAssertEqual(result.payer?.action?.ResultCode, "SUCCESS")
    }

    func test_edit_payer_add_new_default_payment_method() {
        // GIVEN
        let created = createPayerForEdit()
        let firstToken = created.token

        let card2 = CreditCardData()
        card2.number = "4012001038488884"
        card2.expMonth = Date().currentMonth
        card2.expYear = Date().currentYear + 1
        card2.cvn = "131"
        card2.cardHolderName = "James Mason"
        let tokenExpectation = expectation(description: "Tokenized Card 2 Expectation")
        var token2: String?
        card2.tokenize { token, _ in
            token2 = token
            card2.token = token
            tokenExpectation.fulfill()
        }
        wait(for: [tokenExpectation], timeout: 10.0)
        XCTAssertNotNil(token2)

        let editCustomer = Customer()
        editCustomer.id = created.payer.id
        editCustomer.firstName = "John"
        editCustomer.lastName = "James"
        editCustomer.key = newCustomer.key
        editCustomer.addRecurringPaymentMethod(paymentId: firstToken, paymentMethod: card)
        editCustomer.addRecurringPaymentMethod(paymentId: token2, paymentMethod: card2, isDefault: true)

        // WHEN
        let result = edit(editCustomer)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.paymentMethods?.count, 2)
        let defaultMethod = result.payer?.paymentMethods?.first { $0.preferredPayment == true }
        XCTAssertEqual(defaultMethod?.id, token2)
        XCTAssertEqual(result.payer?.action?.Type, "PAYER_EDIT")
    }

    func test_map_edit_payer_documented_response() {
        // GIVEN
        let rawJson = """
        {
            "id": "PYR_2ee5480308664428bef46d1094f22adc",
            "time_created": "2025-08-11T11:39:03.000Z",
            "time_last_updated": "2025-08-11T11:46:43.000Z",
            "first_name": "JXXX",
            "last_name": "JXXXX",
            "reference": "Testing_Payer_Encrypted",
            "merchant_id": "MER_c5d37eaf0e3841e083c232b2318af55c",
            "merchant_name": "Sandbox_Merchant_4",
            "account_id": "TKA_c1de85a8a5844c56abd9ca07bbd792c8",
            "account_name": "tokenization",
            "payment_methods": [
                { "id": "PMT_ffc2fc7e-7292-4f3b-9798-5c231414158a", "default": "YES" }
            ],
            "action": {
                "id": "ACT_KXSqpFbwbZTyH8XHeN5Z6Bw6aaXarP",
                "type": "PAYER_EDIT",
                "time_created": "2025-08-11T11:46:43.089Z",
                "result_code": "SUCCESS",
                "app_id": "T6og1tbECpHFeO104qUM383oq5bOJ12r",
                "app_name": "Postman_Collection_Test"
            }
        }
        """

        // WHEN
        let payer: Customer? = GpApiMapping.mapRecurringEntity(rawJson)

        // THEN
        XCTAssertEqual(payer?.id, "PYR_2ee5480308664428bef46d1094f22adc")
        XCTAssertEqual(payer?.timeLastUpdated, "2025-08-11T11:46:43.000Z".format())
        XCTAssertEqual(payer?.firstName, "JXXX")
        XCTAssertEqual(payer?.lastName, "JXXXX")
        XCTAssertEqual(payer?.key, "Testing_Payer_Encrypted")
        XCTAssertEqual(payer?.merchantName, "Sandbox_Merchant_4")
        XCTAssertEqual(payer?.accountName, "tokenization")
        XCTAssertEqual(payer?.paymentMethods?.first?.id, "PMT_ffc2fc7e-7292-4f3b-9798-5c231414158a")
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
        XCTAssertEqual(payer?.action?.Type, "PAYER_EDIT")
        XCTAssertEqual(payer?.action?.ResultCode, "SUCCESS")
        XCTAssertEqual(payer?.action?.AppName, "Postman_Collection_Test")
    }

    func test_map_edit_payer_response_with_empty_payment_methods() {
        // GIVEN
        let rawJson = """
        {
            "id": "PYR_e1f1a86a10944ae9abea5b091450b692",
            "time_created": "2021-05-03T21:23:39.718Z",
            "time_last_updated": "2021-05-03T21:23:39.718Z",
            "first_name": "John",
            "last_name": "James",
            "reference": "payer-123",
            "payment_methods": [],
            "action": { "id": "ACT_1", "type": "PAYER_EDIT", "result_code": "SUCCESS" }
        }
        """

        // WHEN
        let payer: Customer? = GpApiMapping.mapRecurringEntity(rawJson)

        // THEN
        XCTAssertEqual(payer?.id, "PYR_e1f1a86a10944ae9abea5b091450b692")
        XCTAssertEqual(payer?.paymentMethods?.count, 0)
        XCTAssertEqual(payer?.action?.Type, "PAYER_EDIT")
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

    // MARK: - GET /payers (List Payers) - request / response fields

    private func listPayers(_ builder: TransactionReportBuilder<PagedResult<Customer>>) -> (result: PagedResult<Customer>?, error: Error?) {
        let listExpectation = expectation(description: "List Payers Expectation")
        var result: PagedResult<Customer>?
        var listError: Error?
        builder.execute {
            result = $0
            listError = $1
            listExpectation.fulfill()
        }
        wait(for: [listExpectation], timeout: 20.0)
        return (result, listError)
    }

    func test_list_payers() {
        // WHEN
        let response = listPayers(ReportingService.findPayersPaged(page: 1, pageSize: 5))

        // THEN
        XCTAssertNil(response.error)
        XCTAssertNotNil(response.result)
        XCTAssertEqual(response.result?.page, 1)
        XCTAssertEqual(response.result?.pageSize, 5)
        XCTAssertNotNil(response.result?.totalRecordCount)
        XCTAssertNotNil(response.result?.currentPageSize)
        XCTAssertNotNil(response.result?.merchantId)
        XCTAssertNotNil(response.result?.accountId)
        XCTAssertEqual(response.result?.action?.type, "PAYER_LIST")
        XCTAssertEqual(response.result?.action?.resultCode, "SUCCESS")
        XCTAssertLessThanOrEqual(response.result?.results.count ?? 0, 5)
        XCTAssertEqual(response.result?.results.count, response.result?.currentPageSize)
    }

    func test_list_payers_by_id() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: true).payer

        // WHEN
        let response = listPayers(
            ReportingService.findPayersPaged(page: 1, pageSize: 10)
                .withPayerId(created.id)
        )

        // THEN
        XCTAssertNil(response.error)
        XCTAssertEqual(response.result?.results.count, 1)
        let payer = response.result?.results.first
        XCTAssertEqual(payer?.id, created.id)
        XCTAssertEqual(payer?.key, newCustomer.key)
        XCTAssertEqual(payer?.firstName, created.firstName)
        XCTAssertEqual(payer?.lastName, created.lastName)
        XCTAssertNotNil(payer?.timeCreated)
        XCTAssertNotNil(payer?.timeLastUpdated)
        XCTAssertEqual(payer?.paymentMethods?.count, 1)
        XCTAssertNotNil(payer?.paymentMethods?.first?.id)
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
    }

    func test_list_payers_by_reference() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false).payer

        // WHEN
        let response = listPayers(
            ReportingService.findPayersPaged(page: 1, pageSize: 10)
                .withReferenceNumber(newCustomer.key)
        )

        // THEN
        XCTAssertNil(response.error)
        XCTAssertEqual(response.result?.results.count, 1)
        XCTAssertEqual(response.result?.results.first?.id, created.id)
        XCTAssertEqual(response.result?.results.first?.key, newCustomer.key)
    }

    func test_list_payers_by_date_range_and_order() {
        // GIVEN
        _ = createPayerForEdit(withPaymentMethod: false)
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())

        // WHEN
        let response = listPayers(
            ReportingService.findPayersPaged(page: 1, pageSize: 10)
                .withStartDate(startDate)
                .withEndDate(endDate)
                .orderBy(payerOrderBy: .timeCreated, .descending)
        )

        // THEN
        XCTAssertNil(response.error)
        XCTAssertNotNil(response.result)
        XCTAssertGreaterThanOrEqual(response.result?.results.count ?? 0, 1)
        XCTAssertNotNil(response.result?.filterFromTimeCreated)
        XCTAssertNotNil(response.result?.filterToTimeCreated)
        XCTAssertEqual(response.result?.orderBy, "TIME_CREATED")
        XCTAssertEqual(response.result?.order, "DESC")
        let created = response.result?.results.compactMap { $0.timeCreated } ?? []
        XCTAssertEqual(created, created.sorted(by: >))
    }

    func test_list_payers_paging() {
        // WHEN
        let response = listPayers(ReportingService.findPayersPaged(page: 2, pageSize: 1))

        // THEN
        XCTAssertNil(response.error)
        XCTAssertEqual(response.result?.page, 2)
        XCTAssertEqual(response.result?.pageSize, 1)
        XCTAssertLessThanOrEqual(response.result?.results.count ?? 0, 1)
    }

    func test_list_payers_with_unknown_id_returns_empty() {
        // WHEN
        let response = listPayers(
            ReportingService.findPayersPaged(page: 1, pageSize: 10)
                .withPayerId("PYR_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))")
        )

        // THEN
        XCTAssertNil(response.error)
        XCTAssertEqual(response.result?.results.count, 0)
        XCTAssertEqual(response.result?.totalRecordCount, 0)
    }

    func test_map_list_payers_documented_response() {
        // GIVEN
        let rawJson = """
        {
            "total_record_count": 1000,
            "current_page_size": 564,
            "merchant_id": "MER_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
            "merchant_name": "merchant_1",
            "account_id": "TKA_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
            "account_name": "Tokenization",
            "filter": {
                "from_time_created": "2022-05-01",
                "to_time_created": "2023-05-01"
            },
            "paging": {
                "page": 1,
                "page_size": 5,
                "order_by": "TIME_CREATED",
                "order": "ASC"
            },
            "payers": [
                {
                    "id": "PYR_e1f1a86a10944ae9abea5b091450b692",
                    "first_name": "John",
                    "last_name": "James",
                    "reference": "payer-123",
                    "email": "payer@email.com",
                    "language": "en",
                    "payment_methods": {
                        "id": "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
                        "default": "YES"
                    }
                }
            ],
            "action": {
                "id": "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d",
                "type": "PAYER_CREATE",
                "time_created": "2021-05-03T21:23:39.718Z",
                "result_code": "SUCCESS",
                "app_id": "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d",
                "app_name": "my_lovely_app"
            }
        }
        """

        // WHEN
        let result: PagedResult<Customer>? = GpApiMapping.mapReportResponse(rawJson, .findPayersPaged)

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.totalRecordCount, 1000)
        XCTAssertEqual(result?.currentPageSize, 564)
        XCTAssertEqual(result?.merchantId, "MER_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(result?.merchantName, "merchant_1")
        XCTAssertEqual(result?.accountId, "TKA_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(result?.accountName, "Tokenization")
        XCTAssertEqual(result?.filterFromTimeCreated, "2022-05-01")
        XCTAssertEqual(result?.filterToTimeCreated, "2023-05-01")
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.pageSize, 5)
        XCTAssertEqual(result?.orderBy, "TIME_CREATED")
        XCTAssertEqual(result?.order, "ASC")
        XCTAssertEqual(result?.action?.id, "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(result?.action?.type, "PAYER_CREATE")
        XCTAssertEqual(result?.action?.resultCode, "SUCCESS")
        XCTAssertEqual(result?.action?.appId, "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(result?.action?.appName, "my_lovely_app")

        XCTAssertEqual(result?.results.count, 1)
        let payer = result?.results.first
        XCTAssertEqual(payer?.id, "PYR_e1f1a86a10944ae9abea5b091450b692")
        XCTAssertEqual(payer?.firstName, "John")
        XCTAssertEqual(payer?.lastName, "James")
        XCTAssertEqual(payer?.key, "payer-123")
        XCTAssertEqual(payer?.email, "payer@email.com")
        XCTAssertEqual(payer?.language, "en")
        XCTAssertNil(payer?.timeCreated)
        XCTAssertEqual(payer?.paymentMethods?.count, 1)
        XCTAssertEqual(payer?.paymentMethods?.first?.id, "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
    }

    func test_map_list_payers_sandbox_response() {
        // GIVEN
        let rawJson = """
        {
            "total_record_count": 1,
            "current_page_size": 1,
            "merchant_id": "MER_a38dd31cc8e5428fab9d958f0841100f",
            "merchant_name": "SDK_DEV_TEST",
            "account_id": "TKA_1d94afbbe2e54adc8d6dcb81a3f6ffd3",
            "account_name": "tokenization",
            "filter": {
                "from_time_created": "2026-10-07T00:00:00.000Z",
                "to_time_created": "2026-11-06T23:59:59.999Z"
            },
            "paging": {
                "page_size": 5,
                "page": 1,
                "order": "ASC",
                "order_by": "TIME_CREATED"
            },
            "payers": [
                {
                    "id": "PYR_09b7d92fd2f54a3a8e19b45beaf8daa7",
                    "time_created": "2026-11-05T06:49:47.000Z",
                    "time_last_updated": "2026-11-05T06:49:47.000Z",
                    "first_name": "JXXX",
                    "last_name": "JXXXX",
                    "reference": "payer-123",
                    "payment_methods": [
                        {
                            "id": "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
                            "default": "YES"
                        }
                    ]
                }
            ],
            "action": {
                "id": "ACT_DBlBx5jAMruJ3HEikOXuyIenpVCfzc",
                "type": "PAYER_LIST",
                "time_created": "2026-11-06T05:56:44.817Z",
                "result_code": "SUCCESS",
                "app_id": "X2QS2alAbhURA3NLwr73pNicdoPijJEp",
                "app_name": "SDK_DEV_TEST"
            }
        }
        """

        // WHEN
        let result: PagedResult<Customer>? = GpApiMapping.mapReportResponse(rawJson, .findPayersPaged)

        // THEN
        XCTAssertEqual(result?.totalRecordCount, 1)
        XCTAssertEqual(result?.currentPageSize, 1)
        XCTAssertEqual(result?.merchantId, "MER_a38dd31cc8e5428fab9d958f0841100f")
        XCTAssertEqual(result?.accountName, "tokenization")
        XCTAssertEqual(result?.filterFromTimeCreated, "2026-10-07T00:00:00.000Z")
        XCTAssertEqual(result?.filterToTimeCreated, "2026-11-06T23:59:59.999Z")
        XCTAssertEqual(result?.pageSize, 5)
        XCTAssertEqual(result?.page, 1)
        XCTAssertEqual(result?.order, "ASC")
        XCTAssertEqual(result?.orderBy, "TIME_CREATED")
        XCTAssertEqual(result?.action?.type, "PAYER_LIST")
        XCTAssertEqual(result?.action?.resultCode, "SUCCESS")

        XCTAssertEqual(result?.results.count, 1)
        let payer = result?.results.first
        XCTAssertEqual(payer?.id, "PYR_09b7d92fd2f54a3a8e19b45beaf8daa7")
        XCTAssertEqual(payer?.timeCreated, "2026-11-05T06:49:47.000Z".format())
        XCTAssertEqual(payer?.timeLastUpdated, "2026-11-05T06:49:47.000Z".format())
        XCTAssertNotNil(payer?.timeCreated)
        XCTAssertNotNil(payer?.timeLastUpdated)
        XCTAssertEqual(payer?.firstName, "JXXX")
        XCTAssertEqual(payer?.lastName, "JXXXX")
        XCTAssertEqual(payer?.key, "payer-123")
        XCTAssertNil(payer?.email)
        XCTAssertEqual(payer?.paymentMethods?.count, 1)
        XCTAssertEqual(payer?.paymentMethods?.first?.id, "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
    }

    func test_map_list_payers_empty_response() {
        // GIVEN
        let rawJson = """
        {
            "total_record_count": 0,
            "current_page_size": 0,
            "paging": { "page_size": 5, "page": 1, "order": "ASC", "order_by": "TIME_CREATED" },
            "payers": []
        }
        """

        // WHEN
        let result: PagedResult<Customer>? = GpApiMapping.mapReportResponse(rawJson, .findPayersPaged)

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.totalRecordCount, 0)
        XCTAssertEqual(result?.results.count, 0)
    }

    // MARK: - DELETE /payers/{id} (Delete a Payer)

    private func delete(_ customer: Customer) -> (payer: Customer?, error: Error?) {
        let deleteExpectation = expectation(description: "Delete Payer Expectation")
        var deleted: Customer?
        var deleteError: Error?
        customer.delete {
            deleted = $0
            deleteError = $1
            deleteExpectation.fulfill()
        }
        wait(for: [deleteExpectation], timeout: 10.0)
        return (deleted, deleteError)
    }

    func test_delete_payer() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false).payer

        // WHEN
        let result = delete(created)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.id, created.id)
        XCTAssertEqual(result.payer?.status, "DELETED")
        XCTAssertEqual(result.payer?.action?.Type, "PAYER_DELETE")
        XCTAssertEqual(result.payer?.action?.ResultCode, "SUCCESS")
        XCTAssertNotNil(result.payer?.action?.Id)
        XCTAssertNotNil(result.payer?.action?.TimeCreated)
        XCTAssertNotNil(result.payer?.action?.AppId)
        XCTAssertNotNil(result.payer?.action?.AppName)
    }

    func test_delete_payer_with_payment_method() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: true).payer

        // WHEN
        let result = delete(created)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.id, created.id)
        XCTAssertEqual(result.payer?.status, "DELETED")
    }

    func test_delete_payer_is_not_listed_afterwards() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false).payer
        XCTAssertNil(delete(created).error)

        // WHEN
        let response = listPayers(
            ReportingService.findPayersPaged(page: 1, pageSize: 10)
                .withPayerId(created.id)
        )

        // THEN
        XCTAssertNil(response.error)
        XCTAssertEqual(response.result?.results.count, 0)
    }

    func test_delete_payer_twice_returns_not_found() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false).payer
        XCTAssertNil(delete(created).error)

        // WHEN
        let result = delete(created)

        // THEN
        XCTAssertNil(result.payer)
        XCTAssertNotNil(result.error)
        if let exception = result.error as? GatewayException {
            XCTAssertEqual(exception.responseCode, "RESOURCE_NOT_FOUND")
        }
    }

    func test_delete_payer_with_random_id() {
        // GIVEN
        let customer = Customer()
        customer.id = "PYR_\(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())"

        // WHEN
        let result = delete(customer)

        // THEN
        XCTAssertNil(result.payer)
        XCTAssertNotNil(result.error)
        if let exception = result.error as? GatewayException {
            XCTAssertTrue(["RESOURCE_NOT_FOUND", "INVALID_REQUEST_DATA"].contains(exception.responseCode ?? ""))
        }
    }

    func test_delete_payer_without_id() {
        // GIVEN
        let customer = Customer()
        customer.key = UUID().uuidString

        // WHEN
        let result = delete(customer)

        // THEN
        XCTAssertNil(result.payer)
        XCTAssertNotNil(result.error)
    }

    func test_map_delete_payer_documented_response() {
        // GIVEN
        let rawJson = """
        {
            "id": "PYR_e1f1a86a10944ae9abea5b091450b692",
            "status": "DELETED",
            "action": {
                "id": "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d",
                "type": "PAYER_DELETE",
                "time_created": "2021-05-03T21:23:39.718Z",
                "result_code": "SUCCESS",
                "app_id": "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d",
                "app_name": "my_lovely_app"
            }
        }
        """

        // WHEN
        let payer: Customer? = GpApiMapping.mapRecurringEntity(rawJson)

        // THEN
        XCTAssertEqual(payer?.id, "PYR_e1f1a86a10944ae9abea5b091450b692")
        XCTAssertEqual(payer?.status, "DELETED")
        XCTAssertNil(payer?.firstName)
        XCTAssertNil(payer?.paymentMethods)
        XCTAssertEqual(payer?.action?.Id, "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(payer?.action?.Type, "PAYER_DELETE")
        XCTAssertEqual(payer?.action?.TimeCreated, "2021-05-03T21:23:39.718Z")
        XCTAssertEqual(payer?.action?.ResultCode, "SUCCESS")
        XCTAssertEqual(payer?.action?.AppId, "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(payer?.action?.AppName, "my_lovely_app")
    }

    // MARK: - GET /payers/{id} (Get a Payer)

    private func getPayer(id: String?, masked: Bool? = nil) -> (payer: Customer?, error: Error?) {
        let getExpectation = expectation(description: "Get Payer Expectation")
        var payer: Customer?
        var getError: Error?
        Customer.get(id: id ?? "", masked: masked) {
            payer = $0
            getError = $1
            getExpectation.fulfill()
        }
        wait(for: [getExpectation], timeout: 10.0)
        return (payer, getError)
    }

    func test_get_payer() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: true)

        // WHEN
        let result = getPayer(id: created.payer.id)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.id, created.payer.id)
        XCTAssertNotNil(result.payer?.timeCreated)
        XCTAssertNotNil(result.payer?.timeLastUpdated)
        XCTAssertNotNil(result.payer?.merchantId)
        XCTAssertNotNil(result.payer?.merchantName)
        XCTAssertNotNil(result.payer?.accountId)
        XCTAssertNotNil(result.payer?.accountName)
        XCTAssertEqual(result.payer?.key, newCustomer.key)
        XCTAssertEqual(result.payer?.paymentMethods?.count, 1)
        XCTAssertEqual(result.payer?.paymentMethods?.first?.id, created.token)
        XCTAssertEqual(result.payer?.paymentMethods?.first?.preferredPayment, true)
        XCTAssertEqual(result.payer?.action?.Type, "PAYER_SINGLE")
        XCTAssertEqual(result.payer?.action?.ResultCode, "SUCCESS")
        XCTAssertNotNil(result.payer?.action?.Id)
        XCTAssertNotNil(result.payer?.action?.TimeCreated)
        XCTAssertNotNil(result.payer?.action?.AppId)
        XCTAssertNotNil(result.payer?.action?.AppName)
    }

    func test_get_payer_without_payment_methods() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false)

        // WHEN
        let result = getPayer(id: created.payer.id)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.id, created.payer.id)
        XCTAssertEqual(result.payer?.paymentMethods?.count ?? 0, 0)
    }

    func test_get_payer_unmasked() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false)

        // WHEN
        let result = getPayer(id: created.payer.id, masked: false)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.firstName, "James")
        XCTAssertEqual(result.payer?.lastName, "Mason")
    }

    func test_get_payer_masked() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false)

        // WHEN
        let explicit = getPayer(id: created.payer.id, masked: true)
        let byDefault = getPayer(id: created.payer.id)

        // THEN
        XCTAssertNil(explicit.error)
        XCTAssertNil(byDefault.error)
        XCTAssertNotEqual(explicit.payer?.firstName, "James")
        XCTAssertNotEqual(explicit.payer?.lastName, "Mason")
        XCTAssertEqual(explicit.payer?.firstName, byDefault.payer?.firstName)
        XCTAssertEqual(explicit.payer?.lastName, byDefault.payer?.lastName)
    }

    func test_get_payer_after_edit_returns_updated_data() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false).payer
        let editCustomer = Customer()
        editCustomer.id = created.id
        editCustomer.firstName = "John"
        editCustomer.lastName = "James"
        XCTAssertNil(edit(editCustomer).error)

        // WHEN
        let result = getPayer(id: created.id, masked: false)

        // THEN
        XCTAssertNil(result.error)
        XCTAssertEqual(result.payer?.firstName, "John")
        XCTAssertEqual(result.payer?.lastName, "James")
    }

    func test_get_payer_with_random_id() {
        // WHEN
        let result = getPayer(id: "PYR_\(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())")

        // THEN
        XCTAssertNil(result.payer)
        XCTAssertNotNil(result.error)
        if let exception = result.error as? GatewayException {
            XCTAssertTrue(["RESOURCE_NOT_FOUND", "INVALID_REQUEST_DATA"].contains(exception.responseCode ?? ""))
        }
    }

    func test_get_payer_deleted_returns_not_found() {
        // GIVEN
        let created = createPayerForEdit(withPaymentMethod: false).payer
        XCTAssertNil(delete(created).error)

        // WHEN
        let result = getPayer(id: created.id)

        // THEN
        XCTAssertNil(result.payer)
        XCTAssertNotNil(result.error)
    }

    func test_get_payer_without_id() {
        // WHEN
        let result = getPayer(id: nil)

        // THEN
        XCTAssertNil(result.payer)
        XCTAssertNotNil(result.error)
    }

    func test_map_get_payer_documented_response() {
        // GIVEN
        let rawJson = """
        {
            "id": "PYR_e1f1a86a10944ae9abea5b091450b692",
            "time_created": "2021-05-03T21:23:39.718Z",
            "time_last_updated": "2021-05-03T21:23:39.718Z",
            "merchant_id": "MER_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
            "merchant_name": "merchant_1",
            "account_id": "TKA_oOAH6BClraQWS3Qy07dh7tZAN3X2nW",
            "account_name": "Tokenization",
            "first_name": "John",
            "last_name": "James",
            "reference": "payer-123",
            "email": "payer@email.com",
            "language": "en",
            "payment_methods": [
                { "id": "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW", "default": "YES" }
            ],
            "action": {
                "id": "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d",
                "type": "PAYER_SINGLE",
                "time_created": "2021-05-03T21:23:39.718Z",
                "result_code": "SUCCESS",
                "app_id": "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d",
                "app_name": "my_lovely_app"
            }
        }
        """

        // WHEN
        let payer: Customer? = GpApiMapping.mapRecurringEntity(rawJson)

        // THEN
        XCTAssertEqual(payer?.id, "PYR_e1f1a86a10944ae9abea5b091450b692")
        XCTAssertEqual(payer?.timeCreated, "2021-05-03T21:23:39.718Z".format())
        XCTAssertEqual(payer?.timeLastUpdated, "2021-05-03T21:23:39.718Z".format())
        XCTAssertEqual(payer?.merchantId, "MER_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.merchantName, "merchant_1")
        XCTAssertEqual(payer?.accountId, "TKA_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.accountName, "Tokenization")
        XCTAssertEqual(payer?.firstName, "John")
        XCTAssertEqual(payer?.lastName, "James")
        XCTAssertEqual(payer?.key, "payer-123")
        XCTAssertEqual(payer?.email, "payer@email.com")
        XCTAssertEqual(payer?.language, "en")
        XCTAssertEqual(payer?.paymentMethods?.count, 1)
        XCTAssertEqual(payer?.paymentMethods?.first?.id, "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW")
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
        XCTAssertEqual(payer?.action?.Id, "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(payer?.action?.Type, "PAYER_SINGLE")
        XCTAssertEqual(payer?.action?.TimeCreated, "2021-05-03T21:23:39.718Z")
        XCTAssertEqual(payer?.action?.ResultCode, "SUCCESS")
        XCTAssertEqual(payer?.action?.AppId, "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(payer?.action?.AppName, "my_lovely_app")
    }

    func test_map_get_payer_sandbox_masked_response() {
        // GIVEN
        let rawJson = """
        {
            "id": "PYR_0e302098ccbc4ea9aa9ee55d8cd2a46b",
            "time_created": "2026-11-06T07:23:09.000Z",
            "time_last_updated": "2026-11-06T07:23:09.000Z",
            "merchant_id": "MER_a38dd31cc8e5428fab9d958f0841100f",
            "merchant_name": "SDK_DEV_TEST",
            "account_id": "TKA_1d94afbbe2e54adc8d6dcb81a3f6ffd3",
            "account_name": "tokenization",
            "first_name": "JXXX",
            "last_name": "JXXXX",
            "reference": "payer-123",
            "payment_methods": [
                { "id": "PMT_oOAH6BClraQWS3Qy07dh7tZAN3X2nW", "default": "YES" }
            ],
            "action": {
                "id": "ACT_vnZ4CPDdsOrLYMLK6wGfymsyYTZoHN",
                "type": "PAYER_SINGLE",
                "time_created": "2026-11-06T07:23:54.361Z",
                "result_code": "SUCCESS",
                "app_id": "X2QS2alAbhURA3NLwr73pNicdoPijJEp",
                "app_name": "SDK_DEV_TEST"
            }
        }
        """

        // WHEN
        let payer: Customer? = GpApiMapping.mapRecurringEntity(rawJson)

        // THEN
        XCTAssertEqual(payer?.id, "PYR_0e302098ccbc4ea9aa9ee55d8cd2a46b")
        XCTAssertEqual(payer?.firstName, "JXXX")
        XCTAssertEqual(payer?.lastName, "JXXXX")
        XCTAssertNil(payer?.email)
        XCTAssertNil(payer?.language)
        XCTAssertEqual(payer?.paymentMethods?.first?.preferredPayment, true)
        XCTAssertEqual(payer?.action?.Type, "PAYER_SINGLE")
        XCTAssertEqual(payer?.action?.AppName, "SDK_DEV_TEST")
    }
}
