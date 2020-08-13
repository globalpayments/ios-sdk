import XCTest
import GlobalPayments_iOS_SDK

class BuilderValidationTests: XCTestCase {

    var card: CreditCardData!

    override func setUpWithError() throws {
        try super.setUpWithError()

        card = CreditCardData()
        card.number = "4111111111111111"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "123"
        card.cardHolderName = "Joe Smith"

        let config = GpApiConfig (
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA"
        )

        try ServicesContainer.configureService(config: config)
    }

    override func tearDown(){
        super.tearDown()

        card = nil
    }

    func test_credit_auth_no_amount() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        card.authorize()
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_credit_auth_no_currency() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        card.authorize(amount: 14)
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_credit_sale_no_amount() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        card.charge()
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_credit_sale_no_currency() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        card.charge(amount: 14.0)
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_credit_sale_no_paymentMethod() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        card.charge(amount: 14.0)
            .withCurrency("USD")
            .withPaymentMethod(nil)
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_credit_offline_no_amount() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        card.authorize()
            .withOfflineAuthCode("12345")
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_credit_offline_no_currency() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        card.authorize(amount: 14)
            .withOfflineAuthCode("12345")
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_gift_no_replacement_card() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?
        let giftCard = GiftCard()
        giftCard.alias = "1234567890"

        // WHEN
        giftCard.replaceWith(newCard: nil)
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_check_no_address() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        eCheck().charge(amount: 14)
            .withCurrency("USD")
            .execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }

    func test_report_transaction_detail_no_transactionId() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionSummaryResult: TransactionSummary?
        var transactionSummaryError: BuilderException?

        // WHEN
        ReportingService
            .transactionDetail(transactionId: nil)
            .execute { transactionSummary, error in
                transactionSummaryResult = transactionSummary
                transactionSummaryError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionSummaryResult)
        XCTAssertNotNil(transactionSummaryError)
    }

    func test_report_activity_with_transactionId() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionSummaryResult: [TransactionSummary]?
        var transactionSummaryError: BuilderException?

        // WHEN
        ReportingService
            .activity()
            .withTransactionId("1234567890")
            .execute { transactionSummary, error in
                transactionSummaryResult = transactionSummary
                transactionSummaryError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionSummaryResult)
        XCTAssertNotNil(transactionSummaryError)
    }

    func test_recurring_one_time_with_shipping_amount() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        var transactionResult: Transaction?
        var transactionError: BuilderException?

        // WHEN
        RecurringPaymentMethod()
            .charge(amount: 10)
            .withCurrency("USD")
            .withShippingAmt(3).execute { transaction, error in
                transactionResult = transaction
                transactionError = error as? BuilderException
                executeExpectation.fulfill()
        }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionResult)
        XCTAssertNotNil(transactionError)
    }
}
