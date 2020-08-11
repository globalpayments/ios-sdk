import XCTest
import GlobalPayments_iOS_SDK

class GpApiDebitTests: XCTestCase {

    override func setUpWithError() throws {
        try ServicesContainer.configureService(config: GpApiConfig(
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
                transactionStatusResponse = TransactionStatus(rawValue: transaction!.responseMessage!)
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
                transactionStatusResponse = TransactionStatus(rawValue: transaction!.responseMessage!)
                debitRefundExpectation.fulfill()
        }

        // THEN
        wait(for: [debitRefundExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionStatusResponse, TransactionStatus.captured)
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
                transactionStatusResponse = TransactionStatus(rawValue: transaction!.responseMessage!)
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
                transactionStatusResponse = TransactionStatus(rawValue: transaction!.responseMessage!)
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
                transactionStatusResponse = TransactionStatus(rawValue: transaction!.responseMessage!)
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
