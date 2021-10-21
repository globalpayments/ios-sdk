import XCTest
import GlobalPayments_iOS_SDK

class GpApiStoredPaymentMethodReportingTests: XCTestCase {

    private var token: String!

    private lazy var card: CreditCardData = {
        let card = CreditCardData()
        card.number = "4111111111111111"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "123"
        return card
    }()

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg",
            appKey: "ockJr6pv6KFoGiZA"
        ))
    }

    override func setUp() {
        super.setUp()

        let tokenizeExpectation = expectation(description: "Tokenize exception")
        var expectedError: Error?

        // WHEN
        card.tokenize(completion: { [weak self] token, error in
            self?.token = token
            expectedError = error
            tokenizeExpectation.fulfill()
        })

        // THEN
        wait(for: [tokenizeExpectation], timeout: 20.0)
        XCTAssertNil(expectedError)
        XCTAssertNotNil(token)
    }

    override func tearDown() {
        super.tearDown()

        // GIVEN
        let deleteTokenExpectation = expectation(description: "Delete Token Expectation")
        var result: Bool?
        var error: Error?
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = token

        // WHEN
        tokenizedCard.deleteToken {
            result = $0
            error = $1
            deleteTokenExpectation.fulfill()
        }

        // THEN
        wait(for: [deleteTokenExpectation], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, true)
    }

    func test_report_stored_payment_method_detail() {
        // GIVEN
        let reportingService = ReportingService.storedPaymentMethodDetail(storedPaymentMethodId: token)
        let executeExpecatation = expectation(description: "Execute Expecatation")
        var storedPaymentMethodSummary: StoredPaymentMethodSummary?
        var storedPaymentMethodSummaryError: Error?

        // WHEN
        reportingService.execute {
            storedPaymentMethodSummary = $0
            storedPaymentMethodSummaryError = $1
            executeExpecatation.fulfill()
        }

        // THEN
        wait(for: [executeExpecatation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodSummaryError)
        XCTAssertNotNil(storedPaymentMethodSummary)
        XCTAssertEqual(storedPaymentMethodSummary?.id, token)
    }

    func test_report_stored_payment_method_detail_with_random_id() {
        // GIVEN
        let storedPaymentMethodId = "PMT_\(UUID().uuidString)"
        let reportingService = ReportingService.storedPaymentMethodDetail(storedPaymentMethodId: storedPaymentMethodId)
        let executeExpecatation = expectation(description: "Execute Expecatation")
        var storedPaymentMethodSummary: StoredPaymentMethodSummary?
        var storedPaymentMethodSummaryError: GatewayException?

        // WHEN
        reportingService.execute {
            storedPaymentMethodSummary = $0
            if let error = $1 as? GatewayException {
                storedPaymentMethodSummaryError = error
            }
            executeExpecatation.fulfill()
        }

        // THEN
        wait(for: [executeExpecatation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodSummary)
        XCTAssertNotNil(storedPaymentMethodSummaryError)
        XCTAssertEqual(storedPaymentMethodSummaryError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(storedPaymentMethodSummaryError?.responseMessage, "40118")
        if let message = storedPaymentMethodSummaryError?.message {
            XCTAssertEqual(message, "Status Code: 404 - PAYMENT_METHODS \(storedPaymentMethodId) not found at this /ucp/payment-methods/\(storedPaymentMethodId)")
        } else {
            XCTFail("storedPaymentMethodSummaryError?.message cannot be nil")
        }
    }

    func test_report_find_stored_payment_methods_paged_by_id() {
        // GIVEN
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        var storedPaymentMethodArray: [StoredPaymentMethodSummary]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService
            .where(.storedPaymentMethodId, token)
            .execute {
                storedPaymentMethodArray = $0?.results
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        storedPaymentMethodArray?.forEach {
            XCTAssertEqual($0.id, token)
        }
    }

    func test_find_stored_payment_method_by_id() {
        guard let paymentMethodId = try? awaitResponse(getStoredPaymentMethodSummary)?.id else {
            XCTFail("paymentMethodId cannot be nil")
            return
        }

        // GIVEN
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        var storedPaymentMethodArray: [StoredPaymentMethodSummary]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService.orderBy(storedPaymentMethodOrderBy: .timeCreated, .ascending)
            .where(.storedPaymentMethodId, paymentMethodId)
            .execute {
                storedPaymentMethodArray = $0?.results
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        storedPaymentMethodArray?.forEach {
            XCTAssertEqual($0.id, paymentMethodId)
        }
    }

    func test_find_stored_payment_method_by_random_id() {
        // GIVEN
        let paymentMethodId = "PMT_\(UUID().uuidString)"
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        var storedPaymentMethodArray: [StoredPaymentMethodSummary]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService.orderBy(storedPaymentMethodOrderBy: .timeCreated, .ascending)
            .where(.storedPaymentMethodId, paymentMethodId)
            .execute {
                storedPaymentMethodArray = $0?.results
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        XCTAssertEqual(storedPaymentMethodArray?.count, .zero)
    }

    func test_report_find_stored_payment_methods_paged_by_number_last_4() {
        // GIVEN
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        let lastFour = String(card.number!.suffix(4))
        var storedPaymentMethodArray: [StoredPaymentMethodSummary]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService
            .where(.cardNumberLastFour, lastFour)
            .execute {
                storedPaymentMethodArray = $0?.results
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        storedPaymentMethodArray?.forEach {
            XCTAssertEqual(String($0.cardLast4!.suffix(4)), lastFour)
        }
    }

    func test_report_find_stored_payment_methods_paged_by_number_reference() {

        // Get reference

        // GIVEN
        let storedPaymentMethodDetailExpectation = expectation(description: "Stored Payment Method Detail Expectation")
        var response: StoredPaymentMethodSummary?
        var responseError: Error?

        // WHEN
        ReportingService
            .storedPaymentMethodDetail(storedPaymentMethodId: token)
            .execute {
                response = $0
                responseError = $1
                storedPaymentMethodDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [storedPaymentMethodDetailExpectation], timeout: 10.0)
        XCTAssertNil(responseError)
        XCTAssertNotNil(response)
        XCTAssertNotNil(response?.reference)

        // Find by reference

        // GIVEN
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        var storedPaymentMethodArray: [StoredPaymentMethodSummary]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService
            .where(.referenceNumber, response?.reference)
            .execute {
                storedPaymentMethodArray = $0?.results
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        storedPaymentMethodArray?.forEach {
            XCTAssertEqual($0.reference, response?.reference)
        }
    }

    func test_report_find_stored_payment_methods_paged_by_status() {
        // GIVEN
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        let status = StoredPaymentMethodStatus.active
        var storedPaymentMethodArray: [StoredPaymentMethodSummary]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService
            .where(status)
            .execute {
                storedPaymentMethodArray = $0?.results
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        storedPaymentMethodArray?.forEach {
            XCTAssertEqual($0.status, status.mapped(for: .gpApi))
        }
    }

    func test_report_find_stored_payment_methods_paged_by_start_date_and_end_date() {
        // GIVEN
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        let startDate = Date().addYears(-1)
        let endDate = Date().addDays(-1)
        var storedPaymentMethodArray: [StoredPaymentMethodSummary]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .execute {
                storedPaymentMethodArray = $0?.results
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        storedPaymentMethodArray?.forEach {
            guard let timeCreated = $0.timeCreated else {
                XCTFail("timeCreated cannot be nil")
                return
            }
            XCTAssertTrue(timeCreated.format() >= startDate.format())
            XCTAssertTrue(timeCreated.format() <= endDate.format())
        }
    }

    func test_report_find_stored_payment_methods_paged_order_by_time_created_ascending() {
        // GIVEN
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        var storedPaymentMethodArray: [Date]?
        var sortedStoredPaymentMethodArray: [Date]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService
            .orderBy(storedPaymentMethodOrderBy: .timeCreated, .ascending)
            .execute {
                storedPaymentMethodArray = $0?.results.compactMap { $0.timeCreated }
                sortedStoredPaymentMethodArray = $0?.results.compactMap { $0.timeCreated }.sorted(by: <)
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        XCTAssertNotNil(sortedStoredPaymentMethodArray)
        XCTAssertEqual(storedPaymentMethodArray, sortedStoredPaymentMethodArray)
    }

    func test_report_find_stored_payment_methods_paged_order_by_time_created_descending() {
        // GIVEN
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        let executeExpectation = expectation(description: "Execute Expectation")
        var storedPaymentMethodArray: [Date]?
        var sortedStoredPaymentMethodArray: [Date]?
        var storedPaymentMethodError: Error?

        // WHEN
        reportingService
            .orderBy(storedPaymentMethodOrderBy: .timeCreated, .descending)
            .execute {
                storedPaymentMethodArray = $0?.results.compactMap { $0.timeCreated }
                sortedStoredPaymentMethodArray = $0?.results.compactMap { $0.timeCreated }.sorted(by: >)
                storedPaymentMethodError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(storedPaymentMethodError)
        XCTAssertNotNil(storedPaymentMethodArray)
        XCTAssertNotNil(sortedStoredPaymentMethodArray)
        XCTAssertEqual(storedPaymentMethodArray, sortedStoredPaymentMethodArray)
    }

    private func getStoredPaymentMethodSummary(_ completion: @escaping ((StoredPaymentMethodSummary?) -> Void)) {
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: 1, pageSize: 100)
        reportingService
            .orderBy(storedPaymentMethodOrderBy: .timeCreated, .descending)
            .where(.startDate, Date().addYears(-2).addDays(1))
            .execute { pagedResult, _ in
                let results = pagedResult?.results
                    .filter {
                        !$0.id.isNilOrEmpty
                    }

                completion(results?.first)
            }
    }
}
