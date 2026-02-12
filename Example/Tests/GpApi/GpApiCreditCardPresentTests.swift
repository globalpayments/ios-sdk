import XCTest
import GlobalPayments_iOS_SDK

class GpApiCreditCardPresentTests: XCTestCase {
    var card: CreditCardData!
    var creditTrackData: CreditTrackData?

    let amount: NSDecimalNumber = 12.02
    let currency = "USD"
    let expectedResponseCode = "SUCCESS"

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib",
            channel: .cardPresent
        ))
    }

    override func setUp() {
        super.setUp()

        card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = 5
        card.expYear = 2025
        card.cvn = "852"
    }

    override func tearDown() {
        super.tearDown()

        card = nil
    }

    func test_credit_charge_with_chip() {
        // GIVEN
        let creditTrackData = CreditTrackData()
        creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData.entryMethod = .swipe

        let creditChargeExpectation = expectation(description: "Credit Charge Expectation")
        var chargeResult: Transaction?
        var chargeStatus: String?
        var chargeError: Error?

        // WHEN
        creditTrackData
            .charge(amount: 19)
            .withCurrency("GBP")
            .withEmvLastChipRead(.successful)
            .withAllowDuplicates(true)
            .execute {
                chargeResult = $0
                chargeError = $1
                chargeStatus = $0?.responseMessage
                creditChargeExpectation.fulfill()
            }

        // THEN
        wait(for: [creditChargeExpectation], timeout: 10)
        XCTAssertNil(chargeError)
        XCTAssertNotNil(chargeResult)
        XCTAssertNotNil(chargeStatus)
        XCTAssertEqual(chargeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeStatus, TransactionStatus.captured.rawValue)
    }

    func test_credit_authorize() {
        // GIVEN
        let creditTrackData = CreditTrackData()
        creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData.entryMethod = .swipe

        let creditAuthorizeExpectation = expectation(description: "Credit Authorize Expectation")
        var authorizeResult: Transaction?
        var authorizeStatus: String?
        var authorizeError: Error?

        // WHEN
        creditTrackData
            .authorize(amount: 14)
            .withCurrency("GBP")
            .withOrderId("124214-214221")
            .withAllowDuplicates(true)
            .execute {
                authorizeResult = $0
                authorizeError = $1
                authorizeStatus = $0?.responseMessage
                creditAuthorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [creditAuthorizeExpectation], timeout: 10)
        XCTAssertNil(authorizeError)
        XCTAssertNotNil(authorizeResult)
        XCTAssertNotNil(authorizeStatus)
        XCTAssertEqual(authorizeResult?.responseCode, "SUCCESS")
        XCTAssertEqual(authorizeStatus, TransactionStatus.preauthorized.rawValue)
    }

    func test_credit_authorization_and_capture() {
        // GIVEN
        let creditTrackData = CreditTrackData()
        creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData.entryMethod = .swipe

        let authorizeExpectation = expectation(description: "Authorize Expectation")
        var creditAuthorize: Transaction?
        var creditAuthorizeStatus: String?
        var creditAuthorizeError: Error?

        // WHEN
        creditTrackData
            .authorize(amount: 14)
            .withCurrency("GBP")
            .withAllowDuplicates(true)
            .execute {
                creditAuthorize = $0
                creditAuthorizeError = $1
                creditAuthorizeStatus = $0?.responseMessage
                authorizeExpectation.fulfill()
            }

        // THEN
        wait(for: [authorizeExpectation], timeout: 10)
        XCTAssertNil(creditAuthorizeError)
        XCTAssertNotNil(creditAuthorize)
        XCTAssertNotNil(creditAuthorizeStatus)
        XCTAssertEqual(creditAuthorize?.responseCode, "SUCCESS")
        XCTAssertEqual(creditAuthorizeStatus, TransactionStatus.preauthorized.rawValue)

        // GIVEN
        let transactionCaptureExpectation = expectation(description: "Transaction Capture Expectation")
        var captureResponse: Transaction?
        var captureError: Error?
        var captureStatus: String?

        // WHEN
        creditAuthorize?
            .capture(amount: 14)
            .withCurrency("GBP")
            .execute(completion: {
                captureResponse = $0
                captureError = $1
                captureStatus = $0?.responseMessage
                transactionCaptureExpectation.fulfill()
            })

        // THEN
        wait(for: [transactionCaptureExpectation], timeout: 10.0)
        XCTAssertNil(captureError)
        XCTAssertNotNil(captureResponse)
        XCTAssertEqual(captureStatus, TransactionStatus.captured.rawValue)
    }

    func test_credit_refund() {
        // GIVEN
        let creditTrackData = CreditTrackData()
        creditTrackData.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData.entryMethod = .swipe

        let creditRefundExpectation = expectation(description: "Credit Refund Expectation")
        var refundResult: Transaction?
        var refundStatus: String?
        var refundError: Error?

        // WHEN
        creditTrackData
            .refund(amount: 15.99)
            .withCurrency("GBP")
            .withAllowDuplicates(true)
            .execute {
                refundResult = $0
                refundError = $1
                refundStatus = $0?.responseMessage
                creditRefundExpectation.fulfill()
            }

        // THEN
        wait(for: [creditRefundExpectation], timeout: 10)
        XCTAssertNil(refundError)
        XCTAssertNotNil(refundResult)
        XCTAssertNotNil(refundStatus)
        XCTAssertEqual(refundResult?.responseCode, "SUCCESS")
        XCTAssertEqual(refundStatus, TransactionStatus.captured.rawValue)
    }

    func test_credit_verify() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card?.cvn = "123"
        card?.cardPresent = true
        card?.verify()
            .withCurrency("GBP")
            .execute(completion: {
                transactionResult = $0
                transactionError = $1
                verifyExpectation.fulfill()
            })

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, "VERIFIED")
    }

    func test_credit_verify_cvn_not_matched() {
        // GIVEN
        let verifyExpectation = expectation(description: "Verify Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card?.number = "30450000000985"
        card?.cvn = "098"
        card?.cardPresent = true
        card?.verify()
            .withCurrency("GBP")
            .execute(completion: {
                transactionResult = $0
                transactionError = $1
                verifyExpectation.fulfill()
            })

        // THEN
        wait(for: [verifyExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "NOT_VERIFIED")
        XCTAssertEqual(transactionResult?.responseMessage, "NOT_VERIFIED")
    }

    func test_incremental_auth() {
        // GIVEN
        let incrementalExpectation = expectation(description: "Incremental Expectation")
        var incrementalResult: Transaction?
        var incrementalError: Error?

        card?.number = "4263970000005262"
        card?.cvn = "123"
        card?.cardPresent = true

        // WHEN
        card?.authorize()
            .withAmount(amount)
            .withCurrency(currency)
            .execute(completion: {
                incrementalResult = $0
                incrementalError = $1
                incrementalExpectation.fulfill()
            })

        // THEN
        wait(for: [incrementalExpectation], timeout: 10.0)
        XCTAssertNil(incrementalError)
        XCTAssertNotNil(incrementalResult)
        XCTAssertEqual(expectedResponseCode, incrementalResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, incrementalResult?.responseMessage)

        // GIVEN
        let additionalExpectation = expectation(description: "Additional Expectation")
        var additionalResult: Transaction?
        var additionalError: Error?

        let lodgingInfo = LodgingData()
        lodgingInfo.bookingReference = "s9RpaDwXq1sPRkbP"
        lodgingInfo.stayDuration = 10
        lodgingInfo.checkInDate = Date()
        lodgingInfo.checkOutDate = Date().addDays(7)
        lodgingInfo.rate = 1349

        let item1 = LodgingItem()
        item1.types = LodgingItemType.NO_SHOW.rawValue
        item1.reference = "item_1"
        item1.totalAmount = "1349"
        item1.paymentMethodProgramCodes = [PaymentMethodProgram.ASSURED_RESERVATION.rawValue]
        lodgingInfo.items = [item1]

        // WHEN
        incrementalResult?.additionalAuth(amount: 10)
            .withCurrency(currency)
            .withLodgingData(lodgingInfo)
            .execute(completion: {
                additionalResult = $0
                additionalError = $1
                additionalExpectation.fulfill()
            })

        // THEN
        wait(for: [additionalExpectation], timeout: 10.0)
        XCTAssertNil(additionalError)
        XCTAssertNotNil(additionalResult)
        XCTAssertEqual(expectedResponseCode, additionalResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, additionalResult?.responseMessage)
        XCTAssertEqual(12.12, additionalResult?.authorizedAmount)

        // GIVEN
        let captureExpectation = expectation(description: "Capture Expectation")
        var captureResult: Transaction?
        var captureError: Error?

        // WHEN
        additionalResult?.capture()
            .execute(completion: {
                captureResult = $0
                captureError = $1
                captureExpectation.fulfill()
            })

        // THEN
        wait(for: [captureExpectation], timeout: 10.0)
        XCTAssertNil(captureError)
        XCTAssertNotNil(captureResult)
        XCTAssertEqual(expectedResponseCode, captureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, captureResult?.responseMessage)
    }

    func test_adjust_sale_transaction() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        var adjustSaleResponse: Transaction?
        var adjustSaleError: Error?
        let card = CreditTrackData()
        card.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        card.entryMethod = .proximity

        let tagData = "9F4005F000F0A0019F02060000000025009F03060000000000009F2608D90A06501B48564E82027C005F3401019F360200029F0702FF009F0802008C9F0902008C9F34030403029F2701809F0D05F0400088009F0E0508000000009F0F05F0400098005F280208409F390105FFC605DC4000A800FFC7050010000000FFC805DC4004F8009F3303E0B8C89F1A0208409F350122950500000080005F2A0208409A031409109B02E8009F21030811539C01009F37045EED3A8E4F07A00000000310109F0607A00000000310108407A00000000310109F100706010A03A400029F410400000001"

        // WHEN
        card.charge(amount: 10.0)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withTagData(tagData)
            .execute {
                adjustSaleResponse = $0
                adjustSaleError = $1
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleError)
        assertTransactionResponse(transaction: adjustSaleResponse, transactionStatus: .captured)

        // GIVEN
        let adjustEditExpectation = expectation(description: "Ajust Edit Expectation")
        var adjustEditResponse: Transaction?
        var adjustEditError: Error?

        // WHEN
        adjustSaleResponse?.edit()
            .withAmount(10.01)
            .withTagData(tagData)
            .withGratuity(5.01)
            .execute {
                adjustEditResponse = $0
                adjustEditError = $1
                adjustEditExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustEditExpectation], timeout: 10.0)
        XCTAssertNil(adjustEditError)
        assertTransactionResponse(transaction: adjustEditResponse, transactionStatus: .captured)
    }

    func test_adjust_auth_transaction() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        var adjustSaleResponse: Transaction?
        var adjustSaleError: Error?
        initCreditTrackData(.proximity)

        let tagData = "9F4005F000F0A0019F02060000000025009F03060000000000009F2608D90A06501B48564E82027C005F3401019F360200029F0702FF009F0802008C9F0902008C9F34030403029F2701809F0D05F0400088009F0E0508000000009F0F05F0400098005F280208409F390105FFC605DC4000A800FFC7050010000000FFC805DC4004F8009F3303E0B8C89F1A0208409F350122950500000080005F2A0208409A031409109B02E8009F21030811539C01009F37045EED3A8E4F07A00000000310109F0607A00000000310108407A00000000310109F100706010A03A400029F410400000001"

        // WHEN
        creditTrackData?.authorize(amount: 10.0)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withTagData(tagData)
            .execute {
                adjustSaleResponse = $0
                adjustSaleError = $1
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleError)
        assertTransactionResponse(transaction: adjustSaleResponse, transactionStatus: .preauthorized)

        // GIVEN
        let adjustEditExpectation = expectation(description: "Ajust Edit Expectation")
        var adjustEditResponse: Transaction?
        var adjustEditError: Error?

        // WHEN
        adjustSaleResponse?.edit()
            .withAmount(10.01)
            .withTagData(tagData)
            .withGratuity(5.01)
            .withMultiCapture(sequence: 1, paymentCount: 1)
            .execute {
                adjustEditResponse = $0
                adjustEditError = $1
                adjustEditExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustEditExpectation], timeout: 10.0)
        XCTAssertNil(adjustEditError)
        assertTransactionResponse(transaction: adjustEditResponse, transactionStatus: .preauthorized)
    }

    func test_adjust_sale_transaction_adjust_amount_higher_than_sale() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        var adjustSaleResponse: Transaction?
        var adjustSaleError: Error?
        initCreditTrackData()

        // WHEN
        creditTrackData?.charge(amount: 10.0)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute {
                adjustSaleResponse = $0
                adjustSaleError = $1
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleError)
        assertTransactionResponse(transaction: adjustSaleResponse, transactionStatus: .captured)

        // GIVEN
        let adjustEditExpectation = expectation(description: "Ajust Edit Expectation")
        var adjustEditResponse: Transaction?
        var adjustEditError: Error?

        // WHEN
        adjustSaleResponse?.edit()
            .withAmount(12.0)
            .execute {
                adjustEditResponse = $0
                adjustEditError = $1
                adjustEditExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustEditExpectation], timeout: 10.0)
        XCTAssertNil(adjustEditError)
        assertTransactionResponse(transaction: adjustEditResponse, transactionStatus: .captured)
    }

    func test_adjust_sale_transaction_adjust_only_tag() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        var adjustSaleResponse: Transaction?
        var adjustSaleError: Error?
        initCreditTrackData(.proximity)

        let tagData = "9F4005F000F0A0019F02060000000025009F03060000000000009F2608D90A06501B48564E82027C005F3401019F360200029F0702FF009F0802008C9F0902008C9F34030403029F2701809F0D05F0400088009F0E0508000000009F0F05F0400098005F280208409F390105FFC605DC4000A800FFC7050010000000FFC805DC4004F8009F3303E0B8C89F1A0208409F350122950500000080005F2A0208409A031409109B02E8009F21030811539C01009F37045EED3A8E4F07A00000000310109F0607A00000000310108407A00000000310109F100706010A03A400029F410400000001"

        // WHEN
        creditTrackData?.charge(amount: 10.0)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withTagData(tagData)
            .execute {
                adjustSaleResponse = $0
                adjustSaleError = $1
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleError)
        assertTransactionResponse(transaction: adjustSaleResponse, transactionStatus: .captured)

        // GIVEN
        let adjustEditExpectation = expectation(description: "Ajust Edit Expectation")
        var adjustEditResponse: Transaction?
        var adjustEditError: Error?

        // WHEN
        adjustSaleResponse?.edit()
            .withTagData(tagData)
            .execute {
                adjustEditResponse = $0
                adjustEditError = $1
                adjustEditExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustEditExpectation], timeout: 10.0)
        XCTAssertNil(adjustEditError)
        assertTransactionResponse(transaction: adjustEditResponse, transactionStatus: .captured)
    }

    func test_adjust_sale_transaction_adjust_only_gratuity() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        var adjustSaleResponse: Transaction?
        var adjustSaleError: Error?
        initCreditTrackData()

        // WHEN
        creditTrackData?.charge(amount: 10.0)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withChipCondition(EmvChipCondition.chipFailPreviousSuccess)
            .execute {
                adjustSaleResponse = $0
                adjustSaleError = $1
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleError)
        assertTransactionResponse(transaction: adjustSaleResponse, transactionStatus: .captured)

        // GIVEN
        let adjustEditExpectation = expectation(description: "Ajust Edit Expectation")
        var adjustEditResponse: Transaction?
        var adjustEditError: Error?

        // WHEN
        adjustSaleResponse?.edit()
            .withGratuity(1.0)
            .execute {
                adjustEditResponse = $0
                adjustEditError = $1
                adjustEditExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustEditExpectation], timeout: 10.0)
        XCTAssertNil(adjustEditError)
        assertTransactionResponse(transaction: adjustEditResponse, transactionStatus: .captured)
    }

    func test_adjust_sale_transaction_adjust_amount_zero() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        var adjustSaleResponse: Transaction?
        var adjustSaleError: Error?
        initCreditTrackData()

        // WHEN
        creditTrackData?.charge(amount: 10.0)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withChipCondition(EmvChipCondition.chipFailPreviousSuccess)
            .execute {
                adjustSaleResponse = $0
                adjustSaleError = $1
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleError)
        assertTransactionResponse(transaction: adjustSaleResponse, transactionStatus: .captured)

        // GIVEN
        let adjustEditExpectation = expectation(description: "Ajust Edit Expectation")
        var adjustEditResponse: Transaction?
        var adjustEditError: Error?

        // WHEN
        adjustSaleResponse?.edit()
            .withAmount(0.0)
            .execute {
                adjustEditResponse = $0
                adjustEditError = $1
                adjustEditExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustEditExpectation], timeout: 10.0)
        XCTAssertNil(adjustEditError)
        assertTransactionResponse(transaction: adjustEditResponse, transactionStatus: .captured)
    }

    func test_adjust_sale_transaction_adjust_gratuity_to_zero() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        var adjustSaleResponse: Transaction?
        var adjustSaleError: Error?
        initCreditTrackData()

        // WHEN
        creditTrackData?.charge(amount: 10.0)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withEmvLastChipRead(.successful)
            .execute {
                adjustSaleResponse = $0
                adjustSaleError = $1
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleError)
        assertTransactionResponse(transaction: adjustSaleResponse, transactionStatus: .captured)

        // GIVEN
        let adjustEditExpectation = expectation(description: "Ajust Edit Expectation")
        var adjustEditResponse: Transaction?
        var adjustEditError: Error?

        // WHEN
        adjustSaleResponse?.edit()
            .withGratuity(0.0)
            .execute {
                adjustEditResponse = $0
                adjustEditError = $1
                adjustEditExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustEditExpectation], timeout: 10.0)
        XCTAssertNil(adjustEditError)
        assertTransactionResponse(transaction: adjustEditResponse, transactionStatus: .captured)
    }

    func test_adjust_sale_transaction_without_mandatory() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        var adjustSaleResponse: Transaction?
        var adjustSaleError: Error?
        initCreditTrackData()

        // WHEN
        creditTrackData?.charge(amount: 10.0)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withEmvLastChipRead(.successful)
            .execute {
                adjustSaleResponse = $0
                adjustSaleError = $1
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleError)
        assertTransactionResponse(transaction: adjustSaleResponse, transactionStatus: .captured)

        // GIVEN
        let adjustEditExpectation = expectation(description: "Ajust Edit Expectation")
        var adjustEditResponse: Transaction?
        var adjustEditError: GatewayException?

        // WHEN
        adjustSaleResponse?.edit()
            .execute {
                adjustEditResponse = $0
                if let error = $1 as? GatewayException {
                    adjustEditError = error
                }
                adjustEditExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustEditExpectation], timeout: 10.0)
        XCTAssertNil(adjustEditResponse)
        XCTAssertNotNil(adjustEditError)
        XCTAssertEqual("40005", adjustEditError?.responseMessage)
        XCTAssertEqual("Status Code: 400 - Request expects the following fields [amount or tag or gratuityAmount]", adjustEditError?.message)
    }

    func test_adjust_sale_transaction_not_found() {
        // GIVEN
        let adjustSaleExpectation = expectation(description: "Adjust Sale Expectation")
        let transactionId = UUID().uuidString
        var adjustSaleResponse: Transaction? = Transaction()
        adjustSaleResponse?.transactionId = transactionId
        var adjustSaleError: GatewayException?

        // WHEN
        adjustSaleResponse?.edit()
            .execute {
                adjustSaleResponse = $0
                if let error = $1 as? GatewayException {
                    adjustSaleError = error
                }
                adjustSaleExpectation.fulfill()
            }

        // THEN
        wait(for: [adjustSaleExpectation], timeout: 10.0)
        XCTAssertNil(adjustSaleResponse)
        XCTAssertNotNil(adjustSaleError)
        XCTAssertEqual("40008", adjustSaleError?.responseMessage)
        XCTAssertEqual("Status Code: 404 - Transaction \(transactionId) not found at this location.", adjustSaleError?.message)
    }
    
    func test_credit_track_data_swipe_encrypted() {
        // GIVEN
        let trackDataChargeExpectation = expectation(description: "Track Data Charge Expectation")
        var trackDataChargeResponse: Transaction?
        var trackDataChargeError: Error?
        let card = CreditTrackData()
        card.value = "&lt;E1050711%B4012001000000016^VI TEST CREDIT^251200000000000000000000?|LO04K0WFOmdkDz0um+GwUkILL8ZZOP6Zc4rCpZ9+kg2T3JBT4AEOilWTI|+++++++Dbbn04ekG|11;4012001000000016=25120000000000000000?|1u2F/aEhbdoPixyAPGyIDv3gBfF|+++++++Dbbn04ekG|00|||/wECAQECAoFGAgEH2wYcShV78RZwb3NAc2VjdXJlZXhjaGFuZ2UubmV0PX50qfj4dt0lu9oFBESQQNkpoxEVpCW3ZKmoIV3T93zphPS3XKP4+DiVlM8VIOOmAuRrpzxNi0TN/DWXWSjUC8m/PI2dACGdl/hVJ/imfqIs68wYDnp8j0ZfgvM26MlnDbTVRrSx68Nzj2QAgpBCHcaBb/FZm9T7pfMr2Mlh2YcAt6gGG1i2bJgiEJn8IiSDX5M2ybzqRT86PCbKle/XCTwFFe1X|&gt;"
        card.encryptionData = .version1()
        
        // WHEN
        card.charge(amount: 10.0)
            .withCurrency("USD")
            .execute {
                trackDataChargeResponse = $0
                trackDataChargeError = $1
                trackDataChargeExpectation.fulfill()
            }
        
        // THEN
        wait(for: [trackDataChargeExpectation], timeout: 10.0)
        XCTAssertNil(trackDataChargeError)
        XCTAssertNotNil(trackDataChargeResponse)
        XCTAssertEqual("DECLINED", trackDataChargeResponse?.responseCode)
        XCTAssertEqual(TransactionStatus.declined.mapped(for: .gpApi), trackDataChargeResponse?.responseMessage)
        XCTAssertEqual("14", trackDataChargeResponse?.cardIssuerResponse?.result)
    }
    
    func testShouldReturnLevel2CommercialLevel_WhenLevelIIDataProvided() {
        
        setupLevelIIConfig()
        let expectationCreditSaleForInstallment = expectation(description: " Commercial LEVEL_2 ")
        var responseCharge: Transaction?
        let orderDetails =  OrderDetails()
        let payerDetails = PayerDetails()
        var errorResponse: Error?
        let card = CreditTrackData()
        card.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        card.entryMethod = .swipe
        card.category = "CORPORATE"
        card.avsPostalcode = "75024"

        let commercialData = CommercialData(taxType: TaxType.salesTax, commercialIndicator: CommercialIndicator.level_II)
        commercialData.poNumber = "67098765"
        commercialData.taxAmounts = NSDecimalNumber(string: "100")
        commercialData.merchantId = "MER_df9b8b21f7b74caabc804ceea35e611f"
        // add extra fields for commercial payload
        commercialData.taxMode = "SALES_TAX"
        // payment method details
        let pmCard = CommercialCard(category: "CORPORATE", avsPostalCode: "75024")
        let pm = CommercialPaymentMethod(firstName: "Jane", lastName: "Doe", card: pmCard)
        commercialData.paymentMethod = pm as? any PaymentMethod
        
        // order details
        let taxes = [
            Tax(type: "GST", amount: "10"),
            Tax(type: "HST", amount: "10"),
            Tax(type: "PST", amount: "10"),
            Tax(type: "QST", amount: "10")
        ]
        
        orderDetails.taxes = taxes
        orderDetails.localTaxPercentage = "10"
        orderDetails.buyerRecipientName = "john john"
        orderDetails.stateTaxIdReference = "12344"
        orderDetails.merchantTaxIdReference = "122345"
        
        // payer details
        let addr = Address(streetAddress1: "3550", streetAddress2: "Lenox Road", city: "Atlanta", province: "GA", postalCode: "30326", country: "USA")
        
        payerDetails.taxIdReference = "12345"
        payerDetails.name = "Sushant Deshmukh"
        payerDetails.landlinePhone = "7708298755"
        payerDetails.country = "US"
        payerDetails.email = "sushantd@gp.com"
        payerDetails.billingAddress = addr
        payerDetails.mobilePhone = "7708298755"
        
        card.charge(amount: 10.0)
            .withCurrency("USD")
            .withCommercialRequest(true)
            .withCommercialData(commercialData)
            .withPayerDetails(payerDetails: payerDetails)
            .withOrderDetails(orderDetails: orderDetails)
            .execute {transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectationCreditSaleForInstallment.fulfill()
            }

        wait(for: [expectationCreditSaleForInstallment], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(responseCharge?.commercialLevel, "LEVEL_2")
    }
    
    func testShouldReturnLevel1CommercialLevel_WhenNoCommercialLevelDataProvided() {
        setupLevelIIConfig()
        let expectationCreditSaleForInstallment = expectation(description: " Commercial LEVEL_1 ")
        var responseCharge: Transaction?
        var errorResponse: Error?
        let card = CreditTrackData()
        card.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        card.entryMethod = .swipe
        card.category = "CORPORATE"
        card.avsPostalcode = "75024"

        
        
        card.charge(amount: 10.0)
            .withCurrency("USD")
            .withCommercialRequest(true)
            .execute {transactionResult, error in
                responseCharge = transactionResult
                errorResponse = error
                expectationCreditSaleForInstallment.fulfill()
            }

        wait(for: [expectationCreditSaleForInstallment], timeout: 10.0)
        
        XCTAssertNotNil(responseCharge)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(responseCharge?.commercialLevel, "LEVEL_1")
    }
    
    private func setupLevelIIConfig() {
        let appIdLevelII = "inWHoqkWgfSz7AxYmq1FhijeiAHanlx2"
        let appKeyLevelII = "oDDqEZre9pn5TUgZ"
        let gpApiConfig = GpApiConfig(
            appId: appIdLevelII,
            appKey: appKeyLevelII,
            channel: .cardPresent
        )
        
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "GP API Exchange Retail"
        accessTokenInfo.riskAssessmentAccountName = "EOS_RiskAssessment"
        gpApiConfig.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: gpApiConfig)
    }
    
    private func initCreditTrackData(_ entryMethod: EntryMethod? = .swipe) {
        creditTrackData = CreditTrackData()
        creditTrackData?.value =
            "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        creditTrackData?.entryMethod = entryMethod
    }

    private func assertTransactionResponse(transaction: Transaction?, transactionStatus: TransactionStatus?) {
        XCTAssertNotNil(transaction)
        XCTAssertEqual(expectedResponseCode, transaction?.responseCode)
        XCTAssertEqual(transactionStatus?.rawValue, transaction?.responseMessage)
    }
}
