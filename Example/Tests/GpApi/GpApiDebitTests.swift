import XCTest
import GlobalPayments_iOS_SDK

class GpApiDebitTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardPresent
            )
        )
    }

    func test_debit_sale_swipe() {
        // GIVEN
        let trackChargeExpectation = expectation(description: "Track Charge Expectation")
        let track = DebitTrackData()
        track.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        track.pinBlock = "32539F50C245A6A93D123412324000AA"
        track.entryMethod = .swipe
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        track.charge(amount: 17.01)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                trackChargeExpectation.fulfill()
        }

        // THEN
        wait(for: [trackChargeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }

    func test_debit_refund_swipe() {
        // GIVEN
        let debitRefundExpectation = expectation(description: "Debit Refund Expectation")
        let track = DebitTrackData()
        track.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        track.pinBlock = "32539F50C245A6A93D123412324000AA"
        track.entryMethod = .swipe
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        track.refund(amount: 12.99)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                debitRefundExpectation.fulfill()
        }

        // THEN
        wait(for: [debitRefundExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }

    func test_debit_refund_chip() {
        // GIVEN
        let debitExpectation = expectation(description: "test debit refund chip expectation")
        let track = DebitTrackData()
        track.trackData = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        track.entryMethod = .swipe
        let tagData = "9F4005F000F0A0019F02060000000025009F03060000000000009F2608D90A06501B48564E82027C005F3401019F360200029F0702FF009F0802008C9F0902008C9F34030403029F2701809F0D05F0400088009F0E0508000000009F0F05F0400098005F280208409F390105FFC605DC4000A800FFC7050010000000FFC805DC4004F8009F3303E0B8C89F1A0208409F350122950500000080005F2A0208409A031409109B02E8009F21030811539C01009F37045EED3A8E4F07A00000000310109F0607A00000000310108407A00000000310109F100706010A03A400029F410400000001"
        var transactionResponse: Transaction?
        var transactionError: Error?

        // WHEN
        track.refund(amount: 12.99)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withTagData(tagData)
            .execute {
                transactionResponse = $0
                transactionError = $1
                debitExpectation.fulfill()
            }

        // THEN
        wait(for: [debitExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_debit_reverse() {
        // GIVEN
        let debitReverseExpectation = expectation(description: "Debit Reverse Expectation")
        let track = DebitTrackData()
        track.value = "%B4012002000060016^VI TEST CREDIT^251210118039000000000396?;4012002000060016=25121011803939600000?"
        track.pinBlock = "32539F50C245A6A93D123412324000AA"
        track.entryMethod = .swipe
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        track.charge(amount: 4.99)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                debitReverseExpectation.fulfill()
        }

        // THEN
        wait(for: [debitReverseExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)

        // GIVEN
        let reverseExpectation = expectation(description: "reverse Expectation")
        var reverseTransactionResponse: Transaction?
        var reverseTransactionError: Error?
        var reverseTransactionStatusResponse: TransactionStatus?

        // WHEN
        transactionResponse?
            .reverse(amount: 4.99)
            .withCurrency("USD")
            .execute { transaction, error in
                reverseTransactionResponse = transaction
                reverseTransactionError = error
                if let responseMessage = transaction?.responseMessage {
                    reverseTransactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                reverseExpectation.fulfill()
        }

        // THEN
        wait(for: [reverseExpectation], timeout: 10.0)
        XCTAssertNotNil(reverseTransactionResponse)
        XCTAssertNil(reverseTransactionError)
        XCTAssertEqual(reverseTransactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(reverseTransactionStatusResponse, TransactionStatus.reversed)
    }

    func test_debit_sale_swipe_encrypted() {
        // GIVEN
        let debitSaleExpectation = expectation(description: "Debit Sale Expectation")
        let track = DebitTrackData()
        track.value = "&lt;E1050711%B4012001000000016^VI TEST CREDIT^251200000000000000000000?|LO04K0WFOmdkDz0um+GwUkILL8ZZOP6Zc4rCpZ9+kg2T3JBT4AEOilWTI|+++++++Dbbn04ekG|11;4012001000000016=25120000000000000000?|1u2F/aEhbdoPixyAPGyIDv3gBfF|+++++++Dbbn04ekG|00|||/wECAQECAoFGAgEH2wYcShV78RZwb3NAc2VjdXJlZXhjaGFuZ2UubmV0PX50qfj4dt0lu9oFBESQQNkpoxEVpCW3ZKmoIV3T93zphPS3XKP4+DiVlM8VIOOmAuRrpzxNi0TN/DWXWSjUC8m/PI2dACGdl/hVJ/imfqIs68wYDnp8j0ZfgvM26MlnDbTVRrSx68Nzj2QAgpBCHcaBb/FZm9T7pfMr2Mlh2YcAt6gGG1i2bJgiEJn8IiSDX5M2ybzqRT86PCbKle/XCTwFFe1X|&gt;"
        track.pinBlock = "32539F50C245A6A93D123412324000AA"
        track.entryMethod = .swipe
        track.encryptionData = EncryptionData.version1()
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        track.charge(amount: 17.01)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                debitSaleExpectation.fulfill()
        }

        // THEN
        wait(for: [debitSaleExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }

    func test_debit_sale_swipe_chip() {
        // GIVEN
        let debitSaleExpectation = expectation(description: "Debit Sale Expectation")
        let track = DebitTrackData()
        track.value = ";4024720012345671=18125025432198712345?"
        track.entryMethod = .swipe
        track.pinBlock = "AFEC374574FC90623D010000116001EE"
        let tagData = "82021C008407A0000002771010950580000000009A031709289C01005F280201245F2A0201245F3401019F02060000000010009F03060000000000009F080200019F090200019F100706010A03A420009F1A0201249F26089CC473F4A4CE18D39F2701809F3303E0F8C89F34030100029F3501229F360200639F370435EFED379F410400000019"
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        track.charge(amount: 15.99)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withTagData(tagData)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                debitSaleExpectation.fulfill()
        }

        // THEN
        wait(for: [debitSaleExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }

    func test_debit_sale_contactless_chip() {
        // GIVEN
        let debitSaleExpectation = expectation(description: "Debit Sale Expectation")
        let track = DebitTrackData()
        track.value = ";4024720012345671=18125025432198712345?"
        track.entryMethod = .proximity
        track.pinBlock = "AFEC374574FC90623D010000116001EE"
        let tagData = "82021C008407A0000002771010950580000000009A031709289C01005F280201245F2A0201245F3401019F02060000000010009F03060000000000009F080200019F090200019F100706010A03A420009F1A0201249F26089CC473F4A4CE18D39F2701809F3303E0F8C89F34030100029F3501229F360200639F370435EFED379F410400000019"
        var transactionResponse: Transaction?
        var transactionError: Error?
        var transactionStatusResponse: TransactionStatus?

        // WHEN
        track.charge(amount: 25.95)
            .withCurrency("USD")
            .withAllowDuplicates(true)
            .withTagData(tagData)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                if let responseMessage = transaction?.responseMessage {
                    transactionStatusResponse = TransactionStatus(rawValue: responseMessage)
                }
                debitSaleExpectation.fulfill()
        }

        // THEN
        wait(for: [debitSaleExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
    }
}
