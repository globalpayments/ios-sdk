import XCTest
import GlobalPayments_iOS_SDK

class GpApiReportingTransactionsTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "GkwdYGzQrEy1SdTz7S10P8uRjFMlEsJg",
            appKey: "zvXE2DmmoxPbQ6d0",
            channel: .cardNotPresent
        ))
    }

    // MARK: - Transactions

    func test_report_transaction_detail() {
        guard let transactionId = try? await(getTransactionSummary)?.transactionId else {
            XCTFail("transactionId cannot be nil")
            return
        }

        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        var transactionSummaryResponse: TransactionSummary?
        var transactionSummaryError: Error?

        // WHEN
        ReportingService
            .transactionDetail(transactionId: transactionId)
            .execute { transactionSummary, error in
                transactionSummaryResponse = transactionSummary
                transactionSummaryError = error
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryResponse)
        XCTAssertNil(transactionSummaryError)
        XCTAssertEqual(transactionId, transactionSummaryResponse?.transactionId)
    }

    func test_report_transaction_detail_wrong_id() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let transactionId = UUID().uuidString
        var transactionSummaryResponse: TransactionSummary?
        var transactionSummaryError: GatewayException?

        // WHEN
        ReportingService
            .transactionDetail(transactionId: transactionId)
            .execute {
                transactionSummaryResponse = $0
                if let error = $1 as? GatewayException {
                    transactionSummaryError = error
                }
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionSummaryResponse)
        XCTAssertNotNil(transactionSummaryError)
        XCTAssertEqual(transactionSummaryError?.responseCode, "RESOURCE_NOT_FOUND")
        XCTAssertEqual(transactionSummaryError?.responseMessage, "40118")
        if let message = transactionSummaryError?.message {
            XCTAssertTrue(message.contains("Status Code: 404 - Transactions"))
            XCTAssertTrue(message.contains("not found at this"))
        } else {
            XCTFail("transactionSummaryError?.message cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_start_date_and_end_date() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let startDate = Date().addDays(-30)
        let endDate = Date().addDays(-10)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [Date]?
        var sortedTransactionsSummaryResponse: [Date]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .execute {
                transactionsSummaryResponse = $0?.results.compactMap { $0.transactionDate }
                sortedTransactionsSummaryResponse = $0?.results.compactMap { $0.transactionDate }.sorted(by: >)
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertEqual(transactionsSummaryResponse, sortedTransactionsSummaryResponse)
    }

    func test_report_find_transactions_paged_by_id() {
        guard let transactionId = try? await(getTransactionSummary)?.transactionId else {
            XCTFail("transactionId cannot be nil")
            return
        }

        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .withTransactionId(transactionId)
            .where(.startDate, startDate)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertEqual(transactionsSummaryResponse?.count, 1)
        if let responseList = transactionsSummaryResponse {
            for transaction in responseList {
                XCTAssertEqual(transaction.transactionId, transactionId)
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_wrong_id() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let transactionId = UUID().uuidString
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: GatewayException?

        // WHEN
        reportingService
            .withTransactionId(transactionId)
            .where(.startDate, startDate)
            .execute {
                transactionsSummaryResponse = $0?.results
                if let error = $1 as? GatewayException {
                    transactionsSummaryError = error
                }
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertEqual(transactionsSummaryResponse?.count, .zero)
    }

    func test_report_find_transactions_paged_by_batchId() {
        guard let batchSequenceNumber = try? await(getTransactionSummary)?.batchSequenceNumber else {
            XCTFail("batchSequenceNumber cannot be nil")
            return
        }

        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.batchId, batchSequenceNumber)
            .and(searchCriteria: .startDate, value: startDate)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let responseList = transactionsSummaryResponse {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.batchSequenceNumber, batchSequenceNumber)
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_type() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let paymentType = PaymentType.sale
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(paymentType)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let responseList = transactionsSummaryResponse {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.transactionType, paymentType.mapped(for: .gpApi))
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_amount_and_currency_and_country() {
        guard let transactionSummary = try? await(getTransactionSummary),
              let expectedCurrency = transactionSummary.currency,
              let expectedCountry = transactionSummary.country else {
            XCTFail("currency && country cannot be nil")
            return
        }

        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedAmount: NSDecimalNumber = transactionSummary.amount ?? 0.45
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 50)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .amount, value: expectedAmount)
            .and(dataServiceCriteria: .currency, value: expectedCurrency)
            .and(dataServiceCriteria: .country, value: expectedCountry)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 20.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let responseList = transactionsSummaryResponse {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.amount, expectedAmount)
                XCTAssertEqual(transaction.currency, expectedCurrency)
                XCTAssertEqual(transaction.country, expectedCountry)
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_channel() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedChannel: Channel = .cardNotPresent
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(expectedChannel)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let responseList = transactionsSummaryResponse {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.channel, expectedChannel.mapped(for: .gpApi))
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_status() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedStatus: TransactionStatus = .captured
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(expectedStatus)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let responseList = transactionsSummaryResponse {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.transactionStatus, expectedStatus)
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_card_brand_and_auth_code() {
        guard let transactionSummary = try? await(getTransactionSummary),
              let expectedCardBrand = transactionSummary.cardType,
              let expectedAuthCode = transactionSummary.authCode else {
            XCTFail("cardType & authCode cannot be nil")
            return
        }

        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.cardBrand, expectedCardBrand)
            .and(searchCriteria: .authCode, value: expectedAuthCode)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let responseList = transactionsSummaryResponse {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.cardType, expectedCardBrand)
                XCTAssertEqual(transaction.authCode, expectedAuthCode)
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_reference() {
        guard let referenceNumber = try? await(getTransactionSummary)?.referenceNumber else {
            XCTFail("referenceNumber cannot be nil")
            return
        }

        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.referenceNumber, referenceNumber)
            .and(searchCriteria: .startDate, value: startDate)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
        if let responseList = transactionSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                guard let referenceNumber = transaction.referenceNumber else {
                    XCTFail("referenceNumber cannot be nil")
                    return
                }
                XCTAssertTrue(referenceNumber.contains(referenceNumber))
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_brand_reference() {
        guard let brandReference = try? await(getTransactionSummary)?.brandReference else {
            XCTFail("brandReference cannot be nil")
            return
        }

        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.brandReference, brandReference)
            .and(searchCriteria: .startDate, value: startDate)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
        if let responseList = transactionSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.brandReference, brandReference)
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_entry_mode() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedPaymentEntryMode: PaymentEntryMode = .ecom
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(expectedPaymentEntryMode)
            .execute {
                transactionsSummaryResponse = $0?.results
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let responseList = transactionsSummaryResponse {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.entryMode, expectedPaymentEntryMode.mapped(for: .gpApi))
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_number_first6_and_number_last4() {
        guard let maskedCardNumber = try? await(getTransactionSummary)?.maskedCardNumber else {
            XCTFail("maskedCardNumber cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findTransactionsPaged(page: 1, pageSize: 100)
        let firstSix = String(maskedCardNumber.prefix(6))
        let lastFour = String(maskedCardNumber.suffix(4))
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .cardNumberFirstSix, value: firstSix)
            .and(searchCriteria: .cardNumberLastFour, value: lastFour)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.maskedCardNumber }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertTrue($0.contains(firstSix))
            XCTAssertTrue($0.contains(lastFour))
        }
    }

    func test_report_find_transactions_paged_by_name() {
        guard let cardHolderName = try? await(getTransactionSummary)?.cardHolderName else {
            XCTFail("cardHolderName cannot be nil")
            return
        }

        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.name, cardHolderName)
            .and(searchCriteria: .startDate, value: startDate)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
        if let responseList = transactionSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.cardHolderName, cardHolderName)
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
    }

    func test_report_find_transactions_paged_by_start_date_order_by_time_created_ascending() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let startDate = Date().addDays(-30)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [Date]?
        var sortedTransactionsSummaryResponse: [Date]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .ascending)
            .where(.startDate, startDate)
            .execute {
                transactionsSummaryResponse = $0?.results.compactMap { $0.transactionDate }
                sortedTransactionsSummaryResponse = $0?.results.compactMap { $0.transactionDate }.sorted(by: <)
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertEqual(transactionsSummaryResponse, sortedTransactionsSummaryResponse)
    }

    func test_report_find_transactions_paged_by_start_date_order_by_id_ascending() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "Reporting Execute Expectation")
        let startDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummaryResponse: [String]?
        var sortedTransactionsSummaryResponse: [String]?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .id, .ascending)
            .where(.startDate, startDate)
            .execute {
                transactionsSummaryResponse = $0?.results.compactMap { $0.transactionId }
                sortedTransactionsSummaryResponse = $0?.results.compactMap { $0.transactionId }.sorted(by: <)
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNotNil(sortedTransactionsSummaryResponse)
        XCTAssertEqual(transactionsSummaryResponse, sortedTransactionsSummaryResponse)
    }

    func test_report_find_transactions_paged_order_by_type_ascending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 50)
        var transactionSummaryList: [String]?
        var expectedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .status, .ascending)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionType }
                expectedTransactionSummaryList = $0?.results.compactMap { $0.transactionType }
                    .sorted(by: { $0.compare($1) == .orderedAscending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_paged_order_by_time_created_ascending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 50)
        var transactionSummaryList: [Date]?
        var expectedTransactionSummaryList: [Date]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .ascending)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionDate }
                expectedTransactionSummaryList = $0?.results.compactMap { $0.transactionDate }
                    .sorted(by: { $0.compare($1) == .orderedAscending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_paged_order_by_time_created_descending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 50)
        var transactionSummaryList: [Date]?
        var expectedTransactionSummaryList: [Date]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionDate }
                expectedTransactionSummaryList = $0?.results.compactMap { $0.transactionDate }
                    .sorted(by: { $0.compare($1) == .orderedDescending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_paged_order_by_id_ascending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 50)
        var transactionSummaryList: [String]?
        var expectedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .id, .ascending)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionId }
                expectedTransactionSummaryList = $0?.results.compactMap { $0.transactionId }
                    .sorted(by: { $0.compare($1) == .orderedAscending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_paged_order_by_id_descending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 50)
        var transactionSummaryList: [String]?
        var expectedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .id, .descending)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionId }
                expectedTransactionSummaryList = $0?.results.compactMap { $0.transactionId }
                    .sorted(by: { $0.compare($1) == .orderedDescending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_paged_order_by_type_descending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 50)
        var transactionSummaryList: [String]?
        var expectedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .status, .descending)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionType }
                expectedTransactionSummaryList = $0?.results.compactMap { $0.transactionType }
                    .sorted(by: { $0.compare($1) == .orderedDescending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_no_criteria() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportingService
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
    }

    // MARK: - Settlement Transactions

    func test_report_find_settlement_transactions_paged_by_start_date_and_end_date() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addDays(-30)
        let endDate = Date().addDays(-10)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        if let transactionSummaryList = transactionSummaryList {
            for transaction in transactionSummaryList {
                guard let transactionDate = transaction.transactionDate else {
                    XCTFail("transactionDate cannot be nil")
                    return
                }
                XCTAssertTrue(transactionDate >= startDate)
                XCTAssertTrue(transactionDate <= endDate)
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
        XCTAssertNotNil(transactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_start_date_order_by_time_created_ascending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [Date]?
        var sortedTransactionSummaryList: [Date]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .ascending)
            .where(.startDate, startDate)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionDate }
                sortedTransactionSummaryList = $0?.results.compactMap { $0.transactionDate }.sorted(by: <)
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNotNil(sortedTransactionSummaryList)
        XCTAssertEqual(transactionSummaryList, sortedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_start_date_order_by_time_created_descending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [Date]?
        var sortedTransactionSummaryList: [Date]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionDate }
                sortedTransactionSummaryList = $0?.results.compactMap { $0.transactionDate }.sorted(by: >)
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNotNil(sortedTransactionSummaryList)
        XCTAssertEqual(transactionSummaryList, sortedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_start_date_order_by_status_ascending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var sortedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .status, .ascending)
            .where(.startDate, startDate)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionStatus?.rawValue }
                sortedTransactionSummaryList = $0?.results.compactMap { $0.transactionStatus?.rawValue }.sorted(by: <)
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNotNil(sortedTransactionSummaryList)
        XCTAssertEqual(transactionSummaryList, sortedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_start_date_order_by_status_descending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var sortedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .status, .descending)
            .where(.startDate, startDate)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionStatus?.rawValue }
                sortedTransactionSummaryList = $0?.results.compactMap { $0.transactionStatus?.rawValue }.sorted(by: >)
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNotNil(sortedTransactionSummaryList)
        XCTAssertEqual(transactionSummaryList, sortedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_start_date_order_by_type_ascending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var sortedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .type, .ascending)
            .where(.startDate, startDate)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionType }
                sortedTransactionSummaryList = $0?.results.compactMap { $0.transactionType }.sorted(by: <)
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNotNil(sortedTransactionSummaryList)
        XCTAssertEqual(transactionSummaryList, sortedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_start_date_order_by_type_descending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var sortedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .type, .descending)
            .where(.startDate, startDate)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionType }
                sortedTransactionSummaryList = $0?.results.compactMap { $0.transactionType }.sorted(by: >)
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNotNil(sortedTransactionSummaryList)
        XCTAssertEqual(transactionSummaryList, sortedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_start_date_order_by_deposit_id_ascending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var sortedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .depositId, .ascending)
            .where(.startDate, startDate)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.depositReference }
                sortedTransactionSummaryList = $0?.results.compactMap { $0.depositReference }.sorted(by: <)
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNotNil(sortedTransactionSummaryList)
        XCTAssertEqual(transactionSummaryList, sortedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_start_date_order_by_deposit_id_descending() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var sortedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .depositId, .descending)
            .where(.startDate, startDate)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.depositReference }
                sortedTransactionSummaryList = $0?.results.compactMap { $0.depositReference }.sorted(by: >)
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNotNil(sortedTransactionSummaryList)
        XCTAssertEqual(transactionSummaryList, sortedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_paged_by_number_first6_and_number_last4() {
        guard let maskedCardNumber = try? await(getSettlementTransactionSummary)?.maskedCardNumber else {
            XCTFail("maskedCardNumber cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let firstSix = String(maskedCardNumber.prefix(6))
        let lastFour = String(maskedCardNumber.suffix(4))
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .cardNumberFirstSix, value: firstSix)
            .and(searchCriteria: .cardNumberLastFour, value: lastFour)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.maskedCardNumber }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertTrue($0.contains(firstSix))
            XCTAssertTrue($0.contains(lastFour))
        }
    }

    func test_report_find_settlement_transactions_paged_by_card_brand() {
        guard let cardBrand = try? await(getSettlementTransactionSummary)?.cardType else {
            XCTFail("maskedCardNumber cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .cardBrand, value: cardBrand)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.cardType }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertEqual($0, cardBrand)
        }
    }

    func test_report_find_settlement_transactions_paged_by_invalid_card_brand() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let invalidCardBrand = "UNKNOWN"
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .cardBrand, value: invalidCardBrand)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.cardType }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList?.count, .zero)
    }

    func test_report_find_settlement_transactions_paged_by_deposit_status() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let depositStatus = DepositStatus.delayed
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [DepositStatus]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(depositStatus: depositStatus)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.depositStatus }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertEqual($0, depositStatus)
        }
    }

    func test_report_find_settlement_transactions_paged_by_arn() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let arn = "UNKNOWN"
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .aquirerReferenceNumber, value: arn)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.aquirerReferenceNumber }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList?.count, .zero)
    }

    func test_report_find_settlement_transactions_paged_by_brand_reference() {
        guard let brandReference = try? await(getSettlementTransactionSummary)?.brandReference else {
            XCTFail("brandReference cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .brandReference, value: brandReference)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.brandReference }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertEqual($0, brandReference)
        }
    }

    func test_report_find_settlement_transactions_paged_by_brand_wrong_reference() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let brandReference = "UNKNOWN"
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .brandReference, value: brandReference)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.brandReference }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList?.count, .zero)
    }

    func test_report_find_settlement_transactions_paged_by_card_brand_and_auth_code() {
        guard let transactionSummary = try? await(getSettlementTransactionSummary) else {
            XCTFail("transactionSummary cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .cardBrand, value: transactionSummary.cardType)
            .and(searchCriteria: .authCode, value: transactionSummary.authCode)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertEqual($0.cardType, transactionSummary.cardType)
            XCTAssertEqual($0.authCode, transactionSummary.authCode)
        }
    }

    func test_report_find_settlement_transactions_paged_by_reference() {
        guard let referenceNumber = try? await(getSettlementTransactionSummary)?.referenceNumber else {
            XCTFail("referenceNumber cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .referenceNumber, value: referenceNumber)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertEqual($0.referenceNumber, referenceNumber)
        }
    }

    func test_report_find_settlement_transactions_paged_by_random_reference() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let referenceNumber = UUID().uuidString
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .referenceNumber, value: referenceNumber)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList?.count, .zero)
    }

    func test_report_find_settlement_transactions_paged_by_status() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let status = TransactionStatus.rejected
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionStatus]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(transactionStatus: status)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.transactionStatus }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertEqual($0, status)
        }
    }

    func test_report_find_settlement_transactions_paged_by_deposit_reference() {
        guard let depositReference = try? await(getSettlementTransactionSummary)?.depositReference else {
            XCTFail("depositReference cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .depositReference, value: depositReference)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertEqual($0.depositReference, depositReference)
        }
    }

    func test_report_find_settlement_transactions_paged_by_random_deposit_reference() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let depositReference = UUID().uuidString
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .depositReference, value: depositReference)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList?.count, .zero)
    }

    func test_report_find_settlement_transactions_paged_by_from_deposit_time_created_and_to_deposit_time_created() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addDays(-90)
        let startDateDeposit = Date().addDays(-89)
        let endDateDeposit = Date().addDays(-1)
        var transactionSummaryList: [Date]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .startDepositDate, value: startDateDeposit)
            .and(dataServiceCriteria: .endDepositDate, value: endDateDeposit)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.depositDate }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertTrue($0 >= startDateDeposit)
            XCTAssertTrue($0 <= endDateDeposit)
        }
    }

    func test_report_find_settlement_transactions_paged_by_from_batch_time_created_and_to_batch_time_created() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addDays(-90)
        let startDateDeposit = Date().addDays(-89)
        let endDateDeposit = Date().addDays(-1)
        var transactionSummaryList: [Date]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .startBatchDate, value: startDateDeposit)
            .and(dataServiceCriteria: .endBatchDate, value: endDateDeposit)
            .execute {
                transactionSummaryList = $0?.results.compactMap { $0.batchCloseDate }
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertTrue($0 >= startDateDeposit)
            XCTAssertTrue($0 <= endDateDeposit)
        }
    }

    func test_report_find_settlement_transactions_paged_by_merchant_id_and_system_hierarchy() {
        guard let transactionSummary = try? await(getSettlementTransactionSummary) else {
            XCTFail("transactionSummary cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .merchantId, value: transactionSummary.merchantId)
            .and(dataServiceCriteria: .systemHierarchy, value: transactionSummary.merchantHierarchy)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        transactionSummaryList?.forEach {
            XCTAssertEqual($0.merchantId, transactionSummary.merchantId)
            XCTAssertEqual($0.merchantHierarchy, transactionSummary.merchantHierarchy)
        }
    }

    func test_report_find_settlement_transactions_paged_by_non_existent_merchant_id() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let merchantId = "100023947222"
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .merchantId, value: merchantId)
            .execute {
                transactionSummaryList = $0?.results
                transactionError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList?.count, .zero)
    }

    func test_report_find_settlement_transactions_paged_by_random_system_hierarchy() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let systemHierarchy = UUID().uuidString
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: GatewayException?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .systemHierarchy, value: systemHierarchy)
            .execute {
                transactionSummaryList = $0?.results
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionSummaryList)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(transactionError?.responseMessage, "40105")
        if let message = transactionError?.message {
            XCTAssertEqual(message, "Status Code: 400 - Invalid Value provided in the input field - system.hierarchy")
        } else {
            XCTFail("transactionError?.message cannot be nil")
        }
    }

    func test_report_find_settlement_transactions_paged_by_invalid_merchant_id() {
        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let reportService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        let merchantId = UUID().uuidString
        let startDate = Date().addYears(-1)
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: GatewayException?

        // WHEN
        reportService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .merchantId, value: merchantId)
            .execute {
                transactionSummaryList = $0?.results
                if let error = $1 as? GatewayException {
                    transactionError = error
                }
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(transactionSummaryList)
        XCTAssertNotNil(transactionError)
        XCTAssertEqual(transactionError?.responseCode, "INVALID_REQUEST_DATA")
        XCTAssertEqual(transactionError?.responseMessage, "40100")
        if let message = transactionError?.message {
            XCTAssertEqual(message, "Status Code: 400 - Invalid Value provided in the input field - system.mid")
        } else {
            XCTFail("transactionError?.message cannot be nil")
        }
    }

    // MARK: - Utils

    private func getTransactionSummary(_ completion: @escaping ((TransactionSummary?) -> Void)) {
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 100)
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, Date().addYears(-2).addDays(1))
            .execute { pagedResult, _ in
                let results = pagedResult?.results
                    .filter {
                        !$0.transactionId.isNilOrEmpty &&
                        !$0.batchSequenceNumber.isNilOrEmpty &&
                        !$0.currency.isNilOrEmpty &&
                        !$0.country.isNilOrEmpty &&
                        !$0.cardType.isNilOrEmpty &&
                        !$0.authCode.isNilOrEmpty &&
                        !$0.referenceNumber.isNilOrEmpty &&
                        !$0.brandReference.isNilOrEmpty &&
                        !$0.cardHolderName.isNilOrEmpty &&
                        $0.amount != nil
                    }

                completion(results?.first)
            }
    }

    private func getSettlementTransactionSummary(_ completion: @escaping ((TransactionSummary?) -> Void)) {
        let reportingService = ReportingService.findSettlementTransactionsPaged(page: 1, pageSize: 100)
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, Date().addYears(-2).addDays(1))
            .execute { pagedResult, _ in
                let results = pagedResult?.results
                    .filter {
                        !$0.maskedCardNumber.isNilOrEmpty &&
                        !$0.cardType.isNilOrEmpty &&
                        !$0.aquirerReferenceNumber.isNilOrEmpty &&
                        !$0.brandReference.isNilOrEmpty &&
                        !$0.authCode.isNilOrEmpty &&
                        !$0.referenceNumber.isNilOrEmpty &&
                        !$0.depositReference.isNilOrEmpty &&
                        !$0.merchantId.isNilOrEmpty &&
                        !$0.merchantHierarchy.isNilOrEmpty
                    }

                completion(results?.first)
            }
    }
}
