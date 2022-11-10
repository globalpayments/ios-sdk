import XCTest
import GlobalPayments_iOS_SDK

class GpApiCreditWithMerchantIdTests: XCTestCase {
    
    private var card: CreditCardData!
    private let AMOUNT: NSDecimalNumber  = 7.8
    private let CURRENCY: String = "USD"
    private let EXPECTED_CODE: String = "SUCCESS"
    private let MER_ID: String = "MER_7e3e2c7df34f42819b3edee31022ee3f"
    private let accessTokenInfo = AccessTokenInfo()
    private var gpConfig: GpApiConfig!
    
    override func setUp() {
        super.setUp()
        
        // create the card object
        card = CreditCardData();
        card.number = "4263970000005262"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "852"
        
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        accessTokenInfo.tokenizationAccountName = "Tokenization"
        
        gpConfig = GpApiConfig(
            appId: "zKxybfLqH7vAOtBQrApxD5AUpS3ITaPz",
            appKey: "GAMlgEojm6hxZTLI",
            channel: .cardNotPresent,
            accessTokenInfo: accessTokenInfo,
            challengeNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            methodNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            merchantContactUrl: "https://enp4qhvjseljg.x.pipedream.net/",
            merchantId: MER_ID
        )
        
        try? ServicesContainer.configureService(config: gpConfig)
    }
    
    override func tearDown() {
        super.tearDown()

        card = nil
    }
    
    func test_credit_authorization() {
        // GIVEN
        let creditAuthExpectation = expectation(description: "Credit Authorization Expectation")
        var creditAuthResult: Transaction?
        var creditAuthError: Error?
        
        // WHEN
        card.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditAuthResult = $0
                creditAuthError = $1
                creditAuthExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditAuthExpectation], timeout: 10.0)
        XCTAssertNil(creditAuthError)
        XCTAssertNotNil(creditAuthResult)
        XCTAssertEqual(EXPECTED_CODE, creditAuthResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, creditAuthResult?.responseMessage)
        
        // GIVEN
        let creditCaptureExpectation = expectation(description: "Credit Capture Expectation")
        var creditCaptureResult: Transaction?
        var creditCaptureError: Error?
        let newAmount: NSDecimalNumber = NSDecimalNumber(decimal: AMOUNT.decimalValue + 0.5)
        
        // WHEN
        creditAuthResult?.capture(amount: newAmount)
            .withGratuity(0.5)
            .execute(completion: {
                creditCaptureResult = $0
                creditCaptureError = $1
                creditCaptureExpectation.fulfill()
            })
        
        // THEN
        wait(for: [creditCaptureExpectation], timeout: 10.0)
        XCTAssertNil(creditCaptureError)
        XCTAssertNotNil(creditCaptureResult)
        XCTAssertEqual(EXPECTED_CODE, creditCaptureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditCaptureResult?.responseMessage)
    }
    
    func test_credit_authorization_capture_lower_amount() {
        // GIVEN
        let creditAuthExpectation = expectation(description: "Credit Authorization Expectation")
        var creditAuthResult: Transaction?
        var creditAuthError: Error?
        
        // WHEN
        card.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditAuthResult = $0
                creditAuthError = $1
                creditAuthExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditAuthExpectation], timeout: 10.0)
        XCTAssertNil(creditAuthError)
        XCTAssertNotNil(creditAuthResult)
        XCTAssertEqual(EXPECTED_CODE, creditAuthResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, creditAuthResult?.responseMessage)
        
        // GIVEN
        let creditCaptureExpectation = expectation(description: "Credit Capture Expectation")
        var creditCaptureResult: Transaction?
        var creditCaptureError: Error?
        
        // WHEN
        creditAuthResult?.capture(amount: 2.99)
            .withGratuity(2.0)
            .execute(completion: {
                creditCaptureResult = $0
                creditCaptureError = $1
                creditCaptureExpectation.fulfill()
            })
        
        // THEN
        wait(for: [creditCaptureExpectation], timeout: 10.0)
        XCTAssertNil(creditCaptureError)
        XCTAssertNotNil(creditCaptureResult)
        XCTAssertEqual(EXPECTED_CODE, creditCaptureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditCaptureResult?.responseMessage)
    }
    
    func test_credit_authorization_capture_higher_amount() {
        // GIVEN
        let creditAuthExpectation = expectation(description: "Credit Authorization Expectation")
        var creditAuthResult: Transaction?
        var creditAuthError: Error?
        
        // WHEN
        card.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditAuthResult = $0
                creditAuthError = $1
                creditAuthExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditAuthExpectation], timeout: 10.0)
        XCTAssertNil(creditAuthError)
        XCTAssertNotNil(creditAuthResult)
        XCTAssertEqual(EXPECTED_CODE, creditAuthResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, creditAuthResult?.responseMessage)
        
        // GIVEN
        let creditCaptureExpectation = expectation(description: "Credit Capture Expectation")
        var creditCaptureResult: Transaction?
        var creditCaptureError: Error?
        let newAmount: NSDecimalNumber = NSDecimalNumber(decimal: AMOUNT.decimalValue * 1.15)
        
        // WHEN
        creditAuthResult?.capture(amount: newAmount)
            .withGratuity(2.0)
            .execute(completion: {
                creditCaptureResult = $0
                creditCaptureError = $1
                creditCaptureExpectation.fulfill()
            })
        
        // THEN
        wait(for: [creditCaptureExpectation], timeout: 10.0)
        XCTAssertNil(creditCaptureError)
        XCTAssertNotNil(creditCaptureResult)
        XCTAssertEqual(EXPECTED_CODE, creditCaptureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditCaptureResult?.responseMessage)
    }
    
    func test_credit_authorization_capture_higher_amount_with_error() {
        // GIVEN
        let creditAuthExpectation = expectation(description: "Credit Authorization Expectation")
        var creditAuthResult: Transaction?
        var creditAuthError: Error?
        
        // WHEN
        card.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditAuthResult = $0
                creditAuthError = $1
                creditAuthExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditAuthExpectation], timeout: 10.0)
        XCTAssertNil(creditAuthError)
        XCTAssertNotNil(creditAuthResult)
        XCTAssertEqual(EXPECTED_CODE, creditAuthResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, creditAuthResult?.responseMessage)
        
        // GIVEN
        let creditCaptureExpectation = expectation(description: "Credit Capture Expectation")
        var creditCaptureResult: Transaction?
        var creditCaptureError: GatewayException?
        let newAmount: NSDecimalNumber = NSDecimalNumber(decimal: AMOUNT.decimalValue * 1.16)
        
        // WHEN
        creditAuthResult?.capture(amount: newAmount)
            .withGratuity(2.0)
            .execute(completion: {
                creditCaptureResult = $0
                if let error = $1 as? GatewayException {
                    creditCaptureError = error
                }
                creditCaptureExpectation.fulfill()
            })
        
        // THEN
        wait(for: [creditCaptureExpectation], timeout: 10.0)
        XCTAssertNil(creditCaptureResult)
        XCTAssertNotNil(creditCaptureError)
        XCTAssertEqual("50020", creditCaptureError?.responseMessage)
        XCTAssertEqual("INVALID_REQUEST_DATA", creditCaptureError?.responseCode)
        XCTAssertEqual("Status Code: 400 - Can\'t settle for more than 115% of that which you authorised ", creditCaptureError?.message)
    }
    
    func test_credit_sale() {
        // GIVEN
        let creditSaleExpectation = expectation(description: "Credit Sale Expectation")
        var creditSaleResult: Transaction?
        var creditSaleError: Error?
        
        let address = Address()
        address.streetAddress1 = "123 Main St."
        address.city = "Downtown"
        address.state = "NJ"
        address.country = "US"
        address.postalCode = "12345"

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withAddress(address)
            .execute {
                creditSaleResult = $0
                creditSaleError = $1
                creditSaleExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditSaleExpectation], timeout: 10.0)
        XCTAssertNil(creditSaleError)
        XCTAssertNotNil(creditSaleResult)
        XCTAssertEqual(EXPECTED_CODE, creditSaleResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditSaleResult?.responseMessage)
    }
    
    func test_credit_sale_with_request_multiUse_token() {
        // GIVEN
        let creditSaleExpectation = expectation(description: "Credit Sale Expectation")
        var creditSaleResult: Transaction?
        var creditSaleError: Error?

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRequestMultiUseToken(true)
            .execute {
                creditSaleResult = $0
                creditSaleError = $1
                creditSaleExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditSaleExpectation], timeout: 10.0)
        XCTAssertNil(creditSaleError)
        XCTAssertNotNil(creditSaleResult)
        XCTAssertEqual(EXPECTED_CODE, creditSaleResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditSaleResult?.responseMessage)
        XCTAssertNotNil(creditSaleResult?.token)
    }
    
    func test_credit_refund() {
        // GIVEN
        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        var creditRefundResult: Transaction?
        var creditRefundError: Error?

        // WHEN
        card.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditRefundResult = $0
                creditRefundError = $1
                creditRefundExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundExpectation], timeout: 10.0)
        XCTAssertNil(creditRefundError)
        XCTAssertNotNil(creditRefundResult)
        XCTAssertEqual(EXPECTED_CODE, creditRefundResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditRefundResult?.responseMessage)
    }
    
    func test_credit_refund_transaction() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var creditChargeResult: Transaction?
        var creditChargeError: Error?

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        
        // WHEN
        creditChargeResult?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditRefundExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
    }
    
    func test_credit_refund_transaction_with_idempotency_key() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var creditChargeResult: Transaction?
        var creditChargeError: Error?
        let idempotencyKey = UUID().uuidString

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        
        // WHEN
        creditChargeResult?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditRefundExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditRefundErrorExpectation = expectation(description: "Credit Refund Error Expectation")
        var creditRefundIdempotencyError: GatewayException?
        let transactionId = creditChargeResult?.transactionId ?? ""
        // WHEN
        creditChargeResult?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditChargeResult = $0
                if let error = $1 as? GatewayException {
                    creditRefundIdempotencyError = error
                }
                creditChargeError = $1
                creditRefundErrorExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundErrorExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeResult)
        XCTAssertNotNil(creditRefundIdempotencyError)
        XCTAssertEqual("DUPLICATE_ACTION", creditRefundIdempotencyError?.responseCode)
        XCTAssertEqual("40039", creditRefundIdempotencyError?.responseMessage)
        XCTAssertEqual("Status Code: 409 - Idempotency Key seen before: id=\(transactionId)", creditRefundIdempotencyError?.message)
    }
    
    func test_credit_refund_transaction_lower_amount() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var creditChargeResult: Transaction?
        var creditChargeError: Error?

        // WHEN
        card.charge(amount: 5.95)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        
        // WHEN
        creditChargeResult?.refund(amount: 3.25)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditRefundExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
    }
    
    func test_credit_refund_transaction_higher_amount() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var creditChargeResult: Transaction?
        var creditChargeError: Error?

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        var creditRefundResult: Transaction?
        var creditRefundError: GatewayException?
        let newAmount: NSDecimalNumber = NSDecimalNumber(decimal: AMOUNT.decimalValue + 2.0)
        // WHEN
        creditChargeResult?.refund(amount: newAmount)
            .withCurrency(CURRENCY)
            .execute {
                creditRefundResult = $0
                if let error = $1 as? GatewayException {
                    creditRefundError = error
                }
                creditRefundExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundExpectation], timeout: 10.0)
        XCTAssertNil(creditRefundResult)
        XCTAssertNotNil(creditRefundError)
        XCTAssertEqual("40087", creditRefundError?.responseMessage)
        XCTAssertEqual("INVALID_REQUEST_DATA", creditRefundError?.responseCode)
        XCTAssertEqual("Status Code: 400 - You may only refund up to 115% of the original amount ", creditRefundError?.message)
    }
    
    func test_credit_refund_transaction_wrong_id() {
        // GIVEN
        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        var creditRefundResult: Transaction? = Transaction()
        let transactionId = UUID().uuidString
        creditRefundResult?.transactionId = transactionId
        creditRefundResult?.token = UUID().uuidString
        var creditRefundError: GatewayException?
        

        // WHEN
        creditRefundResult?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditRefundResult = $0
                if let error = $1 as? GatewayException {
                    creditRefundError = error
                }
                creditRefundExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundExpectation], timeout: 10.0)
        XCTAssertNil(creditRefundResult)
        XCTAssertNotNil(creditRefundError)
        XCTAssertEqual("40008", creditRefundError?.responseMessage)
        XCTAssertEqual("RESOURCE_NOT_FOUND", creditRefundError?.responseCode)
        XCTAssertEqual("Status Code: 404 - Transaction \(transactionId) not found at this location.", creditRefundError?.message)
    }
    
    func test_credit_reverse_transaction() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var creditChargeResult: Transaction?
        var creditChargeError: Error?

        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        
        // WHEN
        creditChargeResult?.reverse(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditRefundExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditRefundExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.reversed.rawValue, creditChargeResult?.responseMessage)
    }
    
    func test_credit_reverse_transaction_with_idempotency_key() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Authorize Expectation")
        var creditChargeResult: Transaction?
        var creditChargeError: Error?
        let idempotencyKey = UUID().uuidString

        // WHEN
        card.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditReverseExpectation = expectation(description: "Credit Reverse Expectation")
        
        // WHEN
        creditChargeResult?.reverse(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditReverseExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditReverseExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.reversed.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditReverseErrorExpectation = expectation(description: "Credit Reverse Error Expectation")
        var creditReverseIdempotencyError: GatewayException?
        let transactionId = creditChargeResult?.transactionId ?? ""
        // WHEN
        creditChargeResult?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditChargeResult = $0
                if let error = $1 as? GatewayException {
                    creditReverseIdempotencyError = error
                }
                creditChargeError = $1
                creditReverseErrorExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditReverseErrorExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeResult)
        XCTAssertNotNil(creditReverseIdempotencyError)
        XCTAssertEqual("DUPLICATE_ACTION", creditReverseIdempotencyError?.responseCode)
        XCTAssertEqual("40039", creditReverseIdempotencyError?.responseMessage)
        XCTAssertEqual("Status Code: 409 - Idempotency Key seen before: id=\(transactionId)", creditReverseIdempotencyError?.message)
    }
    
    func test_credit_reverse_transaction_wrong_id() {
        // GIVEN
        let creditReverseExpectation = expectation(description: "Credit Reverse Expectation")
        var creditReverseResult: Transaction? = Transaction()
        let transactionId = UUID().uuidString
        creditReverseResult?.transactionId = transactionId
        creditReverseResult?.token = UUID().uuidString
        var creditReverseError: GatewayException?
        

        // WHEN
        creditReverseResult?.reverse(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditReverseResult = $0
                if let error = $1 as? GatewayException {
                    creditReverseError = error
                }
                creditReverseExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditReverseExpectation], timeout: 10.0)
        XCTAssertNil(creditReverseResult)
        XCTAssertNotNil(creditReverseError)
        XCTAssertEqual("40008", creditReverseError?.responseMessage)
        XCTAssertEqual("RESOURCE_NOT_FOUND", creditReverseError?.responseCode)
        XCTAssertEqual("Status Code: 404 - Transaction \(transactionId) not found at this location.", creditReverseError?.message)
    }
    
    func test_credit_partial_reverse_transaction() {
        // GIVEN
        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var creditChargeResult: Transaction?
        var creditChargeError: Error?
        
        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                creditChargeError = $1
                creditChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeError)
        XCTAssertNotNil(creditChargeResult)
        XCTAssertEqual(EXPECTED_CODE, creditChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditChargeResult?.responseMessage)
        
        // GIVEN
        let creditReverseExpectation = expectation(description: "Credit Reverse Expectation")
        var creditReverseError: GatewayException?
        

        // WHEN
        creditChargeResult?.reverse(amount: 1.29)
            .withCurrency(CURRENCY)
            .execute {
                creditChargeResult = $0
                if let error = $1 as? GatewayException {
                    creditReverseError = error
                }
                creditReverseExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditReverseExpectation], timeout: 10.0)
        XCTAssertNil(creditChargeResult)
        XCTAssertNotNil(creditReverseError)
        XCTAssertEqual("40214", creditReverseError?.responseMessage)
        XCTAssertEqual("INVALID_REQUEST_DATA", creditReverseError?.responseCode)
        XCTAssertEqual("Status Code: 400 - partial reversal not supported", creditReverseError?.message)
    }
    
    func test_credit_autorization_for_multi_capture() {
        // GIVEN
        let creditAuthorizeExpectation = expectation(description: "Credit Authorize Expectation")
        var creditAuthorizeResult: Transaction?
        var creditAuthorizeError: Error?

        // WHEN
        card.authorize(amount: 14.0)
            .withCurrency(CURRENCY)
            .withMultiCapture(true)
            .execute {
                creditAuthorizeResult = $0
                creditAuthorizeError = $1
                creditAuthorizeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditAuthorizeExpectation], timeout: 10.0)
        XCTAssertNil(creditAuthorizeError)
        XCTAssertNotNil(creditAuthorizeResult)
        XCTAssertEqual(EXPECTED_CODE, creditAuthorizeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, creditAuthorizeResult?.responseMessage)
        
        // GIVEN
        let creditCapture1Expectation = expectation(description: "Credit Capture1 Expectation")
        var creditCapture1Result: Transaction?
        
        // WHEN
        creditAuthorizeResult?.capture(amount: 3.0)
            .execute {
                creditCapture1Result = $0
                creditAuthorizeError = $1
                creditCapture1Expectation.fulfill()
            }
        
        // THEN
        wait(for: [creditCapture1Expectation], timeout: 10.0)
        XCTAssertNil(creditAuthorizeError)
        XCTAssertNotNil(creditCapture1Result)
        XCTAssertEqual(EXPECTED_CODE, creditCapture1Result?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditCapture1Result?.responseMessage)
        
        // GIVEN
        let creditCapture2Expectation = expectation(description: "Credit Capture2 Expectation")
        var creditCapture2Result: Transaction?
        
        // WHEN
        creditAuthorizeResult?.capture(amount: 5.0)
            .execute {
                creditCapture2Result = $0
                creditAuthorizeError = $1
                creditCapture2Expectation.fulfill()
            }
        
        // THEN
        wait(for: [creditCapture2Expectation], timeout: 10.0)
        XCTAssertNil(creditAuthorizeError)
        XCTAssertNotNil(creditCapture2Result)
        XCTAssertEqual(EXPECTED_CODE, creditCapture2Result?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditCapture2Result?.responseMessage)
        
        // GIVEN
        let creditCapture3Expectation = expectation(description: "Credit Capture3 Expectation")
        
        // WHEN
        creditAuthorizeResult?.capture(amount: 7.0)
            .execute {
                creditCapture2Result = $0
                creditAuthorizeError = $1
                creditCapture3Expectation.fulfill()
            }
        
        // THEN
        wait(for: [creditCapture3Expectation], timeout: 10.0)
        XCTAssertNil(creditAuthorizeError)
        XCTAssertNotNil(creditCapture2Result)
        XCTAssertEqual(EXPECTED_CODE, creditCapture2Result?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditCapture2Result?.responseMessage)
    }
    
    func test_credit_autorization_capture_with_idempotency_key() {
        // GIVEN
        let creditAuthExpectation = expectation(description: "Credit Authorize Expectation")
        var creditAuthResult: Transaction?
        var creditAuthError: Error?
        let idempotencyKey = UUID().uuidString

        // WHEN
        card?.authorize(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                creditAuthResult = $0
                creditAuthError = $1
                creditAuthExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditAuthExpectation], timeout: 10.0)
        XCTAssertNil(creditAuthError)
        XCTAssertNotNil(creditAuthResult)
        XCTAssertEqual(EXPECTED_CODE, creditAuthResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, creditAuthResult?.responseMessage)
        
        // GIVEN
        let creditCaptureExpectation = expectation(description: "Credit Capture Expectation")
        var creditCaptureResult: Transaction?
        
        // WHEN
        creditAuthResult?.capture(amount: AMOUNT)
            .withIdempotencyKey(idempotencyKey)
            .execute(completion: {
                
                creditCaptureResult = $0
                creditAuthError = $1
                creditCaptureExpectation.fulfill()
            })
        
        // THEN
        wait(for: [creditCaptureExpectation], timeout: 10.0)
        XCTAssertNil(creditAuthError)
        XCTAssertNotNil(creditCaptureResult)
        XCTAssertEqual(EXPECTED_CODE, creditCaptureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditCaptureResult?.responseMessage)
        
        // GIVEN
        let creditCaptureErrorExpectation = expectation(description: "Credit Capture Error Expectation")
        var creditCaptureError: GatewayException?
        // WHEN
        creditCaptureResult?.capture(amount: AMOUNT)
            .withIdempotencyKey(idempotencyKey)
            .execute(completion: {
                
                creditCaptureResult = $0
                if let error = $1 as? GatewayException {
                    creditCaptureError = error
                }
                creditCaptureErrorExpectation.fulfill()
            })
        
        // THEN
        wait(for: [creditCaptureErrorExpectation], timeout: 10.0)
        XCTAssertNil(creditCaptureResult)
        XCTAssertNotNil(creditCaptureError)
        XCTAssertEqual("40039", creditCaptureError?.responseMessage)
        XCTAssertEqual("DUPLICATE_ACTION", creditCaptureError?.responseCode)
        XCTAssertEqual("Status Code: 409 - Idempotency Key seen before: id=\(creditAuthResult?.transactionId ?? "")", creditCaptureError?.message)
    }
    
    func test_credit_capture_wrong_id() {
        // GIVEN
        let creditCaptureExpectation = expectation(description: "Credit Capture Expectation")
        let transaction = Transaction()
        transaction.transactionId = UUID().uuidString
        var creditCaptureResult: Transaction?
        var creditCaptureError: GatewayException?
        
        // WHEN
        transaction.capture(amount: AMOUNT)
            .execute(completion: {
                creditCaptureResult = $0
                if let error = $1 as? GatewayException {
                    creditCaptureError = error
                }
                creditCaptureExpectation.fulfill()
            })
        
        // THEN
        wait(for: [creditCaptureExpectation], timeout: 10.0)
        XCTAssertNil(creditCaptureResult)
        XCTAssertNotNil(creditCaptureError)
        XCTAssertEqual("40008", creditCaptureError?.responseMessage)
        XCTAssertEqual("RESOURCE_NOT_FOUND", creditCaptureError?.responseCode)
        XCTAssertEqual("Status Code: 404 - Transaction \(transaction.transactionId ?? "") not found at this location.", creditCaptureError?.message)
    }
    
    func test_sale_with_tokenized_payment_method() {
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        let tokenizedCard = CreditCardData()
        var tokenizedError: Error?
        
        // WHEN
        card.tokenize {
            tokenizedCard.token = $0
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(tokenizedCard.token)
        
        // GIVEN
        let tokenizedCardChargeExpectation = expectation(description: "Tokenized Card Charge Expectation")
        var chargeResult: Transaction?
        
        // WHEN
        tokenizedCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute(completion: {
                chargeResult = $0
                tokenizedError = $1
                tokenizedCardChargeExpectation.fulfill()
            })
        
        // THEN
        wait(for: [tokenizedCardChargeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(chargeResult)
        XCTAssertEqual(EXPECTED_CODE, chargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, chargeResult?.responseMessage)
    }
    
    func test_card_tokenization_then_paying_with_token_single_to_multi_use() {
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        let tokenizedCard = CreditCardData()
        var tokenizedError: Error?
        
        card.tokenize(paymentMethodUsageMode: .single, completion: {
            tokenizedCard.token = $0
            tokenizedCard.cardHolderName = "James Mason"
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        })
        
        // THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(tokenizedCard.token)
        
        //GIVEN
        let tokenizedCardChargeExpectation = expectation(description: "Tokenized Card Charge Expectation")
        var tokenizedCardChargeResult: Transaction?
        
        // WHEN
        tokenizedCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRequestMultiUseToken(true)
            .execute(completion: {
                tokenizedCardChargeResult = $0
                tokenizedError = $1
                tokenizedCardChargeExpectation.fulfill()
            })
        
        // THEN
        wait(for: [tokenizedCardChargeExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(tokenizedCardChargeResult)
        XCTAssertEqual(EXPECTED_CODE, tokenizedCardChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, tokenizedCardChargeResult?.responseMessage)
        if let token = tokenizedCardChargeResult?.token {
            XCTAssertTrue(token.contains("PMT_"))
        } else {
            XCTFail("chargeResult token cannot be nil")
        }
        
        // GIVEN
        let tokenizedCardChargeTokenExpectation = expectation(description: "Tokenized Card Charge With New Token Expectation")
        tokenizedCard.token = tokenizedCardChargeResult?.token
        
        // WHEN
        tokenizedCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute(completion: {
                tokenizedCardChargeResult = $0
                tokenizedError = $1
                tokenizedCardChargeTokenExpectation.fulfill()
            })
        
        // THEN
        wait(for: [tokenizedCardChargeTokenExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(tokenizedCardChargeResult)
        XCTAssertEqual(EXPECTED_CODE, tokenizedCardChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, tokenizedCardChargeResult?.responseMessage)
    }
    
    func test_credit_verify() {
        // GIVEN
        let creditVerifyExpectation = expectation(description: "Credit Verify Expectation")
        var creditVerifyResult: Transaction?
        var creditVerifyError: Error?
        
        // WHEN
        card.verify()
            .withCurrency(CURRENCY)
            .execute {
                creditVerifyResult = $0
                creditVerifyError = $1
                creditVerifyExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditVerifyExpectation], timeout: 10.0)
        XCTAssertNil(creditVerifyError)
        XCTAssertNotNil(creditVerifyResult)
        XCTAssertEqual(EXPECTED_CODE, creditVerifyResult?.responseCode)
        XCTAssertEqual(TransactionStatus.verified.rawValue, creditVerifyResult?.responseMessage)
    }
    
    func test_credit_verify_with_address() {
        // GIVEN
        let creditVerifyExpectation = expectation(description: "Credit Verify Expectation")
        var creditVerifyResult: Transaction?
        var creditVerifyError: Error?
        
        let address = Address()
        address.postalCode = "750241234"
        address.streetAddress1 = "6860 Dallas Pkwy"
        
        // WHEN
        card.verify()
            .withCurrency(CURRENCY)
            .withAddress(address)
            .execute {
                creditVerifyResult = $0
                creditVerifyError = $1
                creditVerifyExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditVerifyExpectation], timeout: 5.0)
        XCTAssertNil(creditVerifyError)
        XCTAssertNotNil(creditVerifyResult)
        XCTAssertEqual(EXPECTED_CODE, creditVerifyResult?.responseCode)
        XCTAssertEqual(TransactionStatus.verified.rawValue, creditVerifyResult?.responseMessage)
    }
    
    func test_credit_verify_with_idempotency_key() {
        // GIVEN
        let creditVerifyExpectation = expectation(description: "Credit Verify Expectation")
        var creditVerifyResult: Transaction?
        var creditVerifyError: Error?
        let idempotencyKey = UUID().uuidString
        
        // WHEN
        card.verify()
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditVerifyResult = $0
                creditVerifyError = $1
                creditVerifyExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditVerifyExpectation], timeout: 5.0)
        XCTAssertNil(creditVerifyError)
        XCTAssertNotNil(creditVerifyResult)
        XCTAssertEqual(EXPECTED_CODE, creditVerifyResult?.responseCode)
        XCTAssertEqual(TransactionStatus.verified.rawValue, creditVerifyResult?.responseMessage)
        
        // GIVEN
        let creditVerifyErrorExpectation = expectation(description: "Credit Verify Error Expectation")
        var creditResult: Transaction?
        var creditError: GatewayException?
        
        // WHEN
        card.verify()
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditResult = $0
                if let error = $1 as? GatewayException {
                    creditError = error
                }
                creditVerifyErrorExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditVerifyErrorExpectation], timeout: 10.0)
        XCTAssertNil(creditResult)
        XCTAssertNotNil(creditError)
        XCTAssertEqual("DUPLICATE_ACTION", creditError?.responseCode)
        XCTAssertEqual("40039", creditError?.responseMessage)
        XCTAssertEqual("Status Code: 409 - Idempotency Key seen before: id=\(creditVerifyResult?.transactionId ?? "")", creditError?.message)
    }
    
    func test_credit_verify_without_currency() {
        // GIVEN
        let creditVerifyExpectation = expectation(description: "Credit No Currency Expectation")
        var creditVerifyResult: Transaction?
        var creditVerifyError: GatewayException?
        
        // WHEN
        card.verify()
            .execute {
                creditVerifyResult = $0
                if let error = $1 as? GatewayException {
                    creditVerifyError = error
                }
                creditVerifyExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditVerifyExpectation], timeout: 10.0)
        XCTAssertNil(creditVerifyResult)
        XCTAssertNotNil(creditVerifyError)
        XCTAssertEqual("MANDATORY_DATA_MISSING", creditVerifyError?.responseCode)
        XCTAssertEqual("40005", creditVerifyError?.responseMessage)
        XCTAssertEqual("Status Code: 400 - Request expects the following fields currency", creditVerifyError?.message)
    }
    
    func test_credit_verify_invalid_cvv() {
        // GIVEN
        let creditVerifyExpectation = expectation(description: "Credit Invalid CVV Expectation")
        var creditVerifyResult: Transaction?
        var creditVerifyError: GatewayException?
        card.cvn = "1234"
        
        // WHEN
        card.verify()
            .withCurrency(CURRENCY)
            .execute {
                creditVerifyResult = $0
                if let error = $1 as? GatewayException {
                    creditVerifyError = error
                }
                creditVerifyExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditVerifyExpectation], timeout: 5.0)
        XCTAssertNil(creditVerifyResult)
        XCTAssertNotNil(creditVerifyError)
        XCTAssertEqual("INVALID_REQUEST_DATA", creditVerifyError?.responseCode)
        XCTAssertEqual("40085", creditVerifyError?.responseMessage)
        XCTAssertEqual("Status Code: 400 - Security Code/CVV2/CVC must be 3 digits", creditVerifyError?.message)
    }
    
    func test_credit_verify_not_numeric_cvv() {
        // GIVEN
        let creditVerifyExpectation = expectation(description: "Credit Not Numeric CVV Expectation")
        var creditVerifyResult: Transaction?
        var creditVerifyError: GatewayException?
        card.cvn = "SMA"
        
        // WHEN
        card.verify()
            .withCurrency(CURRENCY)
            .execute {
                creditVerifyResult = $0
                if let error = $1 as? GatewayException {
                    creditVerifyError = error
                }
                creditVerifyExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditVerifyExpectation], timeout: 5.0)
        XCTAssertNil(creditVerifyResult)
        XCTAssertNotNil(creditVerifyError)
        XCTAssertEqual("SYSTEM_ERROR_DOWNSTREAM", creditVerifyError?.responseCode)
        XCTAssertEqual("50018", creditVerifyError?.responseMessage)
        XCTAssertEqual("Status Code: 502 - The line number 12 which contains \'         [number] XXX [/number] \' does not conform to the schema", creditVerifyError?.message)
    }
    
    func test_credit_charge_transactions_with_same_idempotency_key() {
        // GIVEN
        let creditVerifyExpectation = expectation(description: "Credit Same Idempotency Expectation")
        var creditVerifyResult: Transaction?
        var creditVerifyError: Error?
        let idempotencyKey = UUID().uuidString
        
        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditVerifyResult = $0
                creditVerifyError = $1
                creditVerifyExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditVerifyExpectation], timeout: 10.0)
        XCTAssertNil(creditVerifyError)
        XCTAssertNotNil(creditVerifyResult)
        XCTAssertEqual(EXPECTED_CODE, creditVerifyResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditVerifyResult?.responseMessage)
        
        // GIVEN
        let creditChargeErrorExpectation = expectation(description: "Credit Charge Error Expectation")
        var creditResult: Transaction?
        var creditError: GatewayException?
        
        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                creditResult = $0
                if let error = $1 as? GatewayException {
                    creditError = error
                }
                creditChargeErrorExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditChargeErrorExpectation], timeout: 10.0)
        XCTAssertNil(creditResult)
        XCTAssertNotNil(creditError)
        XCTAssertEqual("DUPLICATE_ACTION", creditError?.responseCode)
        XCTAssertEqual("40039", creditError?.responseMessage)
        XCTAssertEqual("Status Code: 409 - Idempotency Key seen before: id=\(creditVerifyResult?.transactionId ?? "")", creditError?.message)
    }
    
    func test_credit_verify_with_stored_credentials() {
        // GIVEN
        let creditStoreCredentialsExpectation = expectation(description: "Credit Store Credentials Expectation")
        var creditStoreCredentialsResult: Transaction?
        var creditStoreCredentialsError: Error?
        let storedCredential = StoredCredential(
            type: StoredCredentialType.subscription,
            initiator: StoredCredentialInitiator.cardHolder,
            sequence: StoredCredentialSequence.first,
            reason: StoredCredentialReason.incremental)
        
        // WHEN
        card.verify()
            .withCurrency(CURRENCY)
            .withStoredCredential(storedCredential)
            .execute {
                creditStoreCredentialsResult = $0
                creditStoreCredentialsError = $1
                creditStoreCredentialsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditStoreCredentialsExpectation], timeout: 5.0)
        XCTAssertNil(creditStoreCredentialsError)
        XCTAssertNotNil(creditStoreCredentialsResult)
        XCTAssertEqual(EXPECTED_CODE, creditStoreCredentialsResult?.responseCode)
    }
    
    func test_credit_sale_with_stored_credentials() {
        // GIVEN
        let creditStoreCredentialsExpectation = expectation(description: "Credit Sale Store Credentials Expectation")
        var creditStoreCredentialsResult: Transaction?
        var creditStoreCredentialsError: Error?
        let storedCredential = StoredCredential(
            type: StoredCredentialType.subscription,
            initiator: StoredCredentialInitiator.cardHolder,
            sequence: StoredCredentialSequence.first,
            reason: StoredCredentialReason.incremental)
        
        // WHEN
        card.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withStoredCredential(storedCredential)
            .execute {
                creditStoreCredentialsResult = $0
                creditStoreCredentialsError = $1
                creditStoreCredentialsExpectation.fulfill()
            }
        
        // THEN
        wait(for: [creditStoreCredentialsExpectation], timeout: 10.0)
        XCTAssertNil(creditStoreCredentialsError)
        XCTAssertNotNil(creditStoreCredentialsResult)
        XCTAssertEqual(EXPECTED_CODE, creditStoreCredentialsResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, creditStoreCredentialsResult?.responseMessage)
    }
    
    func test_credit_verify_card_present() {
        // GIVEN
        let MER_ID: String = "MER_7e3e2c7df34f42819b3edee31022ee3f"
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        accessTokenInfo.tokenizationAccountName = "Tokenization"

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "zKxybfLqH7vAOtBQrApxD5AUpS3ITaPz",
            appKey: "GAMlgEojm6hxZTLI",
            channel: .cardPresent,
            accessTokenInfo: accessTokenInfo,
            merchantId: MER_ID
        ))
        
        let verifyCardPresentExpectation = expectation(description: "Verify Card Present Expectation")
        var verifyCardPresentResult: Transaction?
        var verifyCardPresentError: Error?
        
        card.cardPresent = true
        card.cvn = "123"
        
        // WHEN
        card.verify()
            .withCurrency(CURRENCY)
            .execute {
                verifyCardPresentResult = $0
                verifyCardPresentError = $1
                verifyCardPresentExpectation.fulfill()
            }
        
        // THEN
        wait(for: [verifyCardPresentExpectation], timeout: 10.0)
        XCTAssertNil(verifyCardPresentError)
        XCTAssertNotNil(verifyCardPresentResult)
        XCTAssertEqual(EXPECTED_CODE, verifyCardPresentResult?.responseCode)
        XCTAssertEqual(TransactionStatus.verified.rawValue, verifyCardPresentResult?.responseMessage)
    }
    
    func test_credit_sale_with_manual_entry_method() {
        // GIVEN
        let MER_ID: String = "MER_7e3e2c7df34f42819b3edee31022ee3f"
        let APP_ID: String = "zKxybfLqH7vAOtBQrApxD5AUpS3ITaPz"
        let APP_KEY: String = "GAMlgEojm6hxZTLI"
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        accessTokenInfo.tokenizationAccountName = "Tokenization"
        
        var creditSaleExpectations = [XCTestExpectation]()
        var manualEntryResults = [(Transaction?, Error?)]()
        
        // WHEN
        Channel.allCases.forEach { channel in
            ManualEntryMethod.allCases.forEach { manualEntryMethod in
                
                let entryMethodExpectation = expectation(description: "Manual Entry Expectation")
                creditSaleExpectations.append(entryMethodExpectation)
                
                try? ServicesContainer.configureService(config: GpApiConfig(
                    appId: APP_ID,
                    appKey: APP_KEY,
                    channel: channel,
                    accessTokenInfo: accessTokenInfo,
                    merchantId: MER_ID
                ))
                
                if channel == .cardPresent {
                    card.cardPresent = true
                }
                
                card.cvn = "123"
                card.entryMethod = manualEntryMethod
                
                card.charge(amount: AMOUNT)
                    .withCurrency(CURRENCY)
                    .execute {
                        manualEntryResults.append(($0,$1))
                        entryMethodExpectation.fulfill()
                    }
            }
        }
        
        // THEN
        wait(for: creditSaleExpectations, timeout: 10.0)
        manualEntryResults.forEach {
            XCTAssertNil($1)
            XCTAssertNotNil($0)
            XCTAssertEqual(EXPECTED_CODE, $0?.responseCode)
            XCTAssertEqual(TransactionStatus.captured.rawValue, $0?.responseMessage)
        }
    }
    
    func test_credit_sale_with_entry_method() {
        // GIVEN
        let MER_ID: String = "MER_7e3e2c7df34f42819b3edee31022ee3f"
        let APP_ID: String = "zKxybfLqH7vAOtBQrApxD5AUpS3ITaPz"
        let APP_KEY: String = "GAMlgEojm6hxZTLI"
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"
        accessTokenInfo.tokenizationAccountName = "Tokenization"
        
        var creditSaleExpectations = [XCTestExpectation]()
        var entryResults = [(Transaction?, Error?)]()
        
        // WHEN
        EntryMethod.allCases.forEach { entryMethod in
            
            let entryMethodExpectation = expectation(description: "Entry Method Expectation")
            creditSaleExpectations.append(entryMethodExpectation)
            
            try? ServicesContainer.configureService(config: GpApiConfig(
                appId: APP_ID,
                appKey: APP_KEY,
                channel: .cardPresent,
                accessTokenInfo: accessTokenInfo,
                merchantId: MER_ID
            ))
            
            let creditTrackData = CreditTrackData()
            creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
            creditTrackData.entryMethod = entryMethod
            
            creditTrackData.charge(amount: AMOUNT)
                .withCurrency(CURRENCY)
                .execute {
                    entryResults.append(($0,$1))
                    entryMethodExpectation.fulfill()
                }
        }
        
        // THEN
        wait(for: creditSaleExpectations, timeout: 10.0)
        entryResults.forEach {
            XCTAssertNil($1)
            XCTAssertNotNil($0)
            XCTAssertEqual(EXPECTED_CODE, $0?.responseCode)
            XCTAssertEqual(TransactionStatus.captured.rawValue, $0?.responseMessage)
        }
    }
    
    func test_credit_sale_with_stored_credentials_recurring_payment() {
        // GIVEN
        let tokenizedCardExpectation = expectation(description: "Tokenized Card Expectation")
        let tokenizedCard = CreditCardData()
        var tokenizedError: Error?
        
        // WHEN
        card.tokenize {
            tokenizedCard.token = $0
            tokenizedError = $1
            tokenizedCardExpectation.fulfill()
        }
        
        //THEN
        wait(for: [tokenizedCardExpectation], timeout: 10.0)
        XCTAssertNil(tokenizedError)
        XCTAssertNotNil(tokenizedCard.token)
        
        // GIVEN
        let secureEcomExpectation = expectation(description: "Tokenized Card Expectation")
        var secureEcomResult: ThreeDSecure?
        var secureEcomError: Error?
        
        // WHEN
        Secure3dService.checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(CURRENCY)
            .withAmount(AMOUNT)
            .withAuthenticationSource(.browser)
            .execute {
                secureEcomResult = $0
                secureEcomError = $1
                secureEcomExpectation.fulfill()
            }
        
        //THEN
        wait(for: [secureEcomExpectation], timeout: 10.0)
        XCTAssertNil(secureEcomError)
        XCTAssertNotNil(secureEcomResult)
        XCTAssertEqual("ENROLLED", secureEcomResult?.enrolled)
        XCTAssertEqual(Secure3dVersion.two, secureEcomResult?.version)
        XCTAssertEqual("AVAILABLE", secureEcomResult?.status)
        XCTAssertNotNil(secureEcomResult?.issuerAcsUrl)
        XCTAssertNotNil(secureEcomResult?.payerAuthenticationRequest)
        XCTAssertNotNil(secureEcomResult?.challengeReturnUrl)
        XCTAssertNotNil(secureEcomResult?.messageType)
        XCTAssertNotNil(secureEcomResult?.sessionDataFieldName)
        XCTAssertNil(secureEcomResult?.eci)
        
        // GIVEN
        let initAuthExpectation = expectation(description: "Init Auth Expectation")
        var initAuthResult: ThreeDSecure?
        var initAuthError: Error?
        
        let browserData = BrowserData()
        browserData.acceptHeader = "text/html,application/xhtml+xml,application/xml;q=9,image/webp,img/apng,*/*;q=0.8"
        browserData.colorDepth = .twentyFourBits
        browserData.ipAddress = "123.123.123.123"
        browserData.javaEnabled = true
        browserData.language = "en"
        browserData.screenHeight = 1080
        browserData.screenWidth = 1920
        browserData.challengeWindowSize = .windowed600x400
        browserData.timezone = "0"
        browserData.userAgent = "Mozilla/5.0 (Windows NT 6.1; Win64, x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36"
        
        // WHEN
        Secure3dService.initiateAuthentication(paymentMethod: tokenizedCard, secureEcom: secureEcomResult)
                        .withAmount(AMOUNT)
                        .withCurrency(CURRENCY)
                        .withAuthenticationSource(.browser)
                        .withBrowserData(browserData)
                        .withMethodUrlCompletion(.yes)
                        .withOrderCreateDate(Date())
                        .execute {
                            initAuthResult = $0
                            initAuthError = $1
                            initAuthExpectation.fulfill()
                        }
        
        // THEN
        wait(for: [initAuthExpectation], timeout: 10.0)
        XCTAssertNil(initAuthError)
        XCTAssertNotNil(initAuthResult)
        XCTAssertEqual("ENROLLED", initAuthResult?.enrolled)
        XCTAssertEqual(Secure3dVersion.two, initAuthResult?.version)
        XCTAssertEqual("SUCCESS_AUTHENTICATED", initAuthResult?.status)
        XCTAssertNotNil(initAuthResult?.issuerAcsUrl)
        XCTAssertNotNil(initAuthResult?.payerAuthenticationRequest)
        XCTAssertNotNil(initAuthResult?.challengeReturnUrl)
        XCTAssertNotNil(initAuthResult?.messageType)
        XCTAssertNotNil(initAuthResult?.sessionDataFieldName)
        
        // GIVEN
        let initChargeExpectation = expectation(description: "Init Charge Expectation")
        var initChargeResult: Transaction?
        var initChargeError: Error?
        tokenizedCard.threeDSecure = initAuthResult
        
        // WHEN
        tokenizedCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                initChargeResult = $0
                initChargeError = $1
                initChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [initChargeExpectation], timeout: 10.0)
        XCTAssertNil(initChargeError)
        XCTAssertNotNil(initChargeResult)
        XCTAssertEqual(EXPECTED_CODE, initChargeResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, initChargeResult?.responseMessage)
        XCTAssertNotNil(initChargeResult?.cardBrandTransactionId)
        
        // GIVEN
        let initCharge2Expectation = expectation(description: "Init Charge2 Expectation")
        var initCharge2Result: Transaction?
        var initCharge2Error: Error?
        
        let storedCredential = StoredCredential(
            type: StoredCredentialType.subscription,
            initiator: StoredCredentialInitiator.cardHolder,
            sequence: StoredCredentialSequence.first,
            reason: StoredCredentialReason.incremental)
        
        // WHEN
        tokenizedCard.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withStoredCredential(storedCredential)
            .execute {
                initCharge2Result = $0
                initCharge2Error = $1
                initCharge2Expectation.fulfill()
            }
        
        // THEN
        wait(for: [initCharge2Expectation], timeout: 10.0)
        XCTAssertNil(initCharge2Error)
        XCTAssertNotNil(initCharge2Result)
        XCTAssertEqual(EXPECTED_CODE, initCharge2Result?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, initCharge2Result?.responseMessage)
    }
}
