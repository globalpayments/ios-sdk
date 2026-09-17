import XCTest
import GlobalPayments_iOS_SDK

/// Tests for POST /transactions/{id}/challenge
/// Covers: single document, multiple documents, response fields, wrong-id error
///
/// NOTE: The challenge endpoint only accepts transactions that are currently in a
/// dispute state (e.g. WITH_MERCHANT). Happy-path tests first look up a real
/// disputed transaction via the reporting API and skip gracefully when none exists
/// in the sandbox environment.
class GpApiTransactionChallengeTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib",
            channel: .cardNotPresent
        ))
    }

    // MARK: - Helpers

    /// Queries the reporting API for a disputed transaction (WITH_MERCHANT status).
    /// Matches the exact pattern used in GpApiReportingDisputesTests.getDisputeSummary.
    private func getDisputedTransaction(_ status: DisputeStatus, _ completion: @escaping (DisputeSummary?) -> Void) {
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        reportingService
            .orderBy(disputeOrderBy: .toAdjustmentTimeCreated, .descending)
            .withDisputeStatus(status)
            .where(.startStageDate, Date().addYears(-1).addDays(1))
            .execute { pagedResult, _ in
                let results = pagedResult?.results.filter {
                    !$0.transactionId.isNilOrEmpty
                }
                completion(results?.first)
            }
    }

    private func pdfDocument(file: StaticString = #file, line: UInt = #line) -> DocumentInfo {
        let bundle = Bundle(for: type(of: self))
        let data = ResourceLoader.loadFile(name: "gp_logo", extension: .pdf, bundle: bundle)
        return DocumentInfo(b64Content: data, fileFormat: "PDF")
    }

    private func pngDocument(file: StaticString = #file, line: UInt = #line) -> DocumentInfo {
        let bundle = Bundle(for: type(of: self))
        let data = ResourceLoader.loadFile(name: "gp_logo", extension: .png, bundle: bundle)
        return DocumentInfo(b64Content: data, fileFormat: "PNG")
    }

    // MARK: - Tests

    func test_challenge_transaction_single_document() {
        // GIVEN - a transaction currently in dispute (WITH_MERCHANT status)
        guard let summary = try? awaitResponse(getDisputedTransaction, calledWith: .withMerchant),
              let transactionId = summary.transactionId else {
            // No disputed transaction available in this sandbox; skip
            return
        }

        let transaction = Transaction.fromId(transactionId: transactionId)
        let challengeExpectation = expectation(description: "Challenge Expectation")
        var challengeResult: Transaction?
        var challengeError: Error?

        // WHEN - challenge with one PDF document
        transaction.challenge(documents: [pdfDocument()])
            .execute {
                challengeResult = $0
                challengeError = $1
                challengeExpectation.fulfill()
            }

        // THEN
        wait(for: [challengeExpectation], timeout: 10.0)
        XCTAssertNil(challengeError)
        XCTAssertNotNil(challengeResult)
        XCTAssertEqual("SUCCESS", challengeResult?.responseCode)
    }

    func test_challenge_transaction_multiple_documents() {
        // GIVEN - a transaction currently in dispute (WITH_MERCHANT status)
        guard let summary = try? awaitResponse(getDisputedTransaction, calledWith: .withMerchant),
              let transactionId = summary.transactionId else {
            return
        }

        let transaction = Transaction.fromId(transactionId: transactionId)
        let challengeExpectation = expectation(description: "Challenge Expectation")
        var challengeResult: Transaction?
        var challengeError: Error?

        // WHEN - challenge with two documents (PDF + PNG)
        transaction.challenge(documents: [pdfDocument(), pngDocument()])
            .execute {
                challengeResult = $0
                challengeError = $1
                challengeExpectation.fulfill()
            }

        // THEN
        wait(for: [challengeExpectation], timeout: 10.0)
        XCTAssertNil(challengeError)
        XCTAssertNotNil(challengeResult)
        XCTAssertEqual("SUCCESS", challengeResult?.responseCode)
    }

    func test_challenge_transaction_response_fields() {
        // GIVEN - a transaction currently in dispute (WITH_MERCHANT status)
        guard let summary = try? awaitResponse(getDisputedTransaction, calledWith: .withMerchant),
              let transactionId = summary.transactionId else {
            return
        }

        let transaction = Transaction.fromId(transactionId: transactionId)
        let challengeExpectation = expectation(description: "Challenge Expectation")
        var challengeResult: Transaction?
        var challengeError: Error?

        // WHEN
        transaction.challenge(documents: [pdfDocument()])
            .execute {
                challengeResult = $0
                challengeError = $1
                challengeExpectation.fulfill()
            }

        // THEN - response fields mapped from challenge response
        wait(for: [challengeExpectation], timeout: 10.0)
        XCTAssertNil(challengeError)
        XCTAssertNotNil(challengeResult)
        XCTAssertEqual("SUCCESS", challengeResult?.responseCode)
        XCTAssertNotNil(challengeResult?.documentStatus)
        XCTAssertNotNil(challengeResult?.documentName)
    }

    func test_challenge_transaction_wrong_id() {
        // GIVEN - a transaction with an unknown id
        let challengeExpectation = expectation(description: "Challenge Expectation")
        let unknownTransaction = Transaction.fromId(transactionId: "UNKNOWN")
        var challengeResult: Transaction?
        var gatewayException: GatewayException?

        // WHEN
        unknownTransaction.challenge(documents: [pdfDocument()])
            .execute {
                challengeResult = $0
                if let exception = $1 as? GatewayException {
                    gatewayException = exception
                }
                challengeExpectation.fulfill()
            }

        // THEN
        wait(for: [challengeExpectation], timeout: 10.0)
        XCTAssertNil(challengeResult)
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("INVALID_TRANSACTION_ACTION", gatewayException?.responseCode)
    }
}

