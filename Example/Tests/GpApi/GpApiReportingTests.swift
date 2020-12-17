import XCTest
import GlobalPayments_iOS_SDK

class GpApiReportingTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig (
            appId: "GkwdYGzQrEy1SdTz7S10P8uRjFMlEsJg",
            appKey: "zvXE2DmmoxPbQ6d0",
            channel: .cardNotPresent
        ))
    }

    // MARK: - Transactions

    func test_report_transaction_detail() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let transactionId = "TRN_TvY1QFXxQKtaFSjNaLnDVdo3PZ7ivz"
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

    func test_report_find_transactions_by_startDate_and_endDate() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
                reportingExecuteExpectation.fulfill()
        }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let response = transactionsSummaryResponse {
            XCTAssertEqual(response.isEmpty, false)
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_by_Id() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let transactionId = "TRN_ccNw4SOBX0dFtE93O46jLgIoiazbsj"
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .withTransactionId(transactionId)
            .where(.startDate, startDate)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
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

    func test_report_find_transactions_by_batchId() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let batchId = "BAT_845591"
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(.batchId, batchId)
            .and(searchCriteria: .startDate, value: startDate)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
                reportingExecuteExpectation.fulfill()
        }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionsSummaryResponse)
        XCTAssertNil(transactionsSummaryError)
        if let responseList = transactionsSummaryResponse {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.batchSequenceNumber, batchId)
            }
        } else {
            XCTFail("transactionsSummaryResponse cannot be nil")
        }
    }

    func test_report_find_transactions_by_type() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let paymentType = PaymentType.sale
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(paymentType)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
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

    func test_report_find_transactions_by_amount_and_currency_and_country() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedAmount: NSDecimalNumber = 0.45
        let expectedCurrency = "USD"
        let expectedCountry = "US"
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 50)
            .where(.startDate, startDate)
            .and(dataServiceCriteria: .amount, value: expectedAmount)
            .and(dataServiceCriteria: .currency, value: expectedCurrency)
            .and(dataServiceCriteria: .country, value: expectedCountry)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
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

    func test_report_find_transactions_by_channel() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedChannel: Channel = .cardNotPresent
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(expectedChannel)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
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

    func test_report_find_transactions_by_status() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedStatus: TransactionStatus = .captured
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(expectedStatus)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
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

    func test_report_find_transactions_by_cardBrand_and_authCode() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedCardBrand = "VISA"
        let expectedAuthCode = "12345"
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(.cardBrand, expectedCardBrand)
            .and(searchCriteria: .authCode, value: expectedAuthCode)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
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

    func test_report_find_transactions_by_entryMode() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "ReportTransactionDetail")
        let expectedPaymentEntryMode: PaymentEntryMode = .ecom
        var transactionsSummaryResponse: [TransactionSummary]?
        var transactionsSummaryError: Error?

        // WHEN
        ReportingService.findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(expectedPaymentEntryMode)
            .execute { transactionsSummary, error in
                transactionsSummaryResponse = transactionsSummary
                transactionsSummaryError = error
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

    func test_report_find_transactions_no_criteria() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .execute { list, error in
                transactionSummaryList = list
                transactionError = error
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
    }

    func test_report_find_transactions_by_reference() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        let expectedReferenceNumber = "e1f2f968-e9cc-45b2-b41f-61cad13754aa"
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(.referenceNumber, expectedReferenceNumber)
            .and(searchCriteria: .startDate, value: startDate)
            .execute { list, error in
                transactionSummaryList = list
                transactionError = error
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
        if let responseList = transactionSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.referenceNumber, expectedReferenceNumber)
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
    }

    func test_report_find_transactions_by_brandReference() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        let expectedBrandReference = "D5v2Nv8h91Me3DTh"
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(.brandReference, expectedBrandReference)
            .and(searchCriteria: .startDate, value: startDate)
            .execute { list, error in
                transactionSummaryList = list
                transactionError = error
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
        if let responseList = transactionSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.brandReference, expectedBrandReference)
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
    }

    func test_report_find_transactions_by_name() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        let expectedName = "James Mason"
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(.name, expectedName)
            .and(searchCriteria: .startDate, value: startDate)
            .execute { list, error in
                transactionSummaryList = list
                transactionError = error
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
        if let responseList = transactionSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for transaction in responseList {
                XCTAssertEqual(transaction.cardHolderName, expectedName)
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
    }

    func test_report_find_transactions_order_by_time_created_ascending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        var transactionSummaryList: [Date]?
        var expectedTransactionSummaryList: [Date]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .ascending)
            .withPaging(1, 30)
            .execute {
                transactionSummaryList = $0?.compactMap { $0.transactionDate }
                expectedTransactionSummaryList = $0?.compactMap { $0.transactionDate }.sorted(by: { $0.compare($1) == .orderedAscending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_order_by_time_created_descending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        var transactionSummaryList: [Date]?
        var expectedTransactionSummaryList: [Date]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withPaging(1, 30)
            .execute {
                transactionSummaryList = $0?.compactMap { $0.transactionDate }
                expectedTransactionSummaryList = $0?.compactMap { $0.transactionDate }.sorted(by: { $0.compare($1) == .orderedDescending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_order_by_status_ascending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        var transactionSummaryList: [String]?
        var expectedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .status, .ascending)
            .withPaging(1, 30)
            .execute {
                transactionSummaryList = $0?.compactMap { $0.status }
                expectedTransactionSummaryList = $0?.compactMap { $0.status }.sorted(by: { $0.compare($1) == .orderedAscending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_order_by_status_descending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        var transactionSummaryList: [String]?
        var expectedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .status, .descending)
            .withPaging(1, 30)
            .execute {
                transactionSummaryList = $0?.compactMap { $0.status }
                expectedTransactionSummaryList = $0?.compactMap { $0.status }.sorted(by: { $0.compare($1) == .orderedDescending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_order_by_type_ascending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        var transactionSummaryList: [String]?
        var expectedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .status, .ascending)
            .withPaging(1, 30)
            .execute {
                transactionSummaryList = $0?.compactMap { $0.transactionType }
                expectedTransactionSummaryList = $0?.compactMap { $0.transactionType }.sorted(by: { $0.compare($1) == .orderedAscending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_transactions_order_by_type_descending() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "find transactions expectation")
        var transactionSummaryList: [String]?
        var expectedTransactionSummaryList: [String]?
        var transactionError: Error?

        // WHEN
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: .status, .descending)
            .withPaging(1, 30)
            .execute {
                transactionSummaryList = $0?.compactMap { $0.transactionType }
                expectedTransactionSummaryList = $0?.compactMap { $0.transactionType }.sorted(by: { $0.compare($1) == .orderedDescending })
                transactionError = $1
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertEqual(transactionSummaryList, expectedTransactionSummaryList)
    }

    func test_report_find_settlement_transactions_with_criteria() {
        // GIVEN
        let findTransactionsExpectation = expectation(description: "FindTransactionsExpectation")
        let thirtyDaysBefore = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        var transactionSummaryList: [TransactionSummary]?
        var transactionError: Error?

        // WHEN
        ReportingService.findSettlementTransactions()
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, thirtyDaysBefore)
            .execute { summaryList, error in
                transactionSummaryList = summaryList
                transactionError = error
                findTransactionsExpectation.fulfill()
            }

        // THEN
        wait(for: [findTransactionsExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionSummaryList)
        XCTAssertNil(transactionError)
    }

    // MARK: - Deposits

    func test_report_deposit_detail() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposit With id")
        let expectedDepositId = "DEP_2342423423"
        var depositSummary: DepositSummary?
        var depositError: Error?

        // WHEN
        ReportingService
            .depositDetail(depositId: expectedDepositId)
            .execute { summary, error in
                depositSummary = summary
                depositError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummary)
        XCTAssertEqual(depositSummary?.depositId, expectedDepositId)
    }

    func test_report_deposit_detail_invalid_id() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposit With id")
        let depositId = "INVALID_ID"
        var depositSummary: DepositSummary?
        var depositError: GatewayException?

        // WHEN
        ReportingService
            .depositDetail(depositId: depositId)
            .execute { summary, error in
                depositSummary = summary
                if let gatewayException = error as? GatewayException {
                    depositError = gatewayException
                }
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        XCTAssertNil(depositSummary)
        XCTAssertNotNil(depositError)
        XCTAssertEqual(depositError?.responseCode, "RESOURCE_NOT_FOUND")
    }

    func test_report_find_deposits_by_startDate() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        var depositSummaryList: [DepositSummary]?
        var depositError: Error?
        
        // WHEN
        ReportingService.findDeposits()
            .orderBy(depositOrderBy: .timeCreated, .descending)
            .withPaging(1, 10)
            .where(.startDate, startDate)
            .execute { list, error in
                depositSummaryList = list
                depositError = error
                summaryExpectation.fulfill()
            }
            
        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
        if let responseList = depositSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for deposit in responseList {
                guard let depositDate = deposit.depositDate else {
                    XCTFail("depositDate cannot be nil")
                    return
                }
                XCTAssertTrue(depositDate >= startDate)
            }
        } else {
            XCTFail("transactionSummaryList cannot be nil")
        }
    }

    func test_report_find_deposits_order_by_depositId() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        var depositSummaryList: [String]?
        var sortedDepositSummaryList: [String]?
        var depositError: Error?

        // WHEN
        ReportingService.findDeposits()
            .orderBy(depositOrderBy: .depositId, .descending)
            .withPaging(1, 10)
            .where(.startDate, startDate)
            .execute { list, error in
                depositSummaryList = list?.compactMap { $0.depositId }
                sortedDepositSummaryList = list?.compactMap { $0.depositId }.sorted(by: > )
                depositError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
        XCTAssertEqual(depositSummaryList, sortedDepositSummaryList)
    }

    func test_report_find_deposits_order_by_status() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        var depositSummaryList: [DepositSummary]?
        var depositError: Error?

        // WHEN
        ReportingService.findDeposits()
            .orderBy(depositOrderBy: .status, .ascending)
            .withPaging(1, 10)
            .where(.startDate, startDate)
            .execute {
                depositSummaryList = $0
                depositError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
    }

    func test_report_find_deposits_order_by_type() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Deposits With Criteria")
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        var depositSummaryList: [DepositSummary]?
        var depositError: Error?

        // WHEN
        ReportingService.findDeposits()
            .orderBy(depositOrderBy: .type, .ascending)
            .withPaging(1, 10)
            .where(.startDate, startDate)
            .execute {
                depositSummaryList = $0
                depositError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(depositError)
        XCTAssertNotNil(depositSummaryList)
    }

    // MARK: - DISPUTES

    func test_report_find_disputes_with_multiple_criteria() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let expectedDisputeStage = DisputeStage.compliance
        let expectedAdjustmentFunding = AdjustmentFunding.debit
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .brand, .ascending)
            .withPaging(1, 10)
            .withDisputeStage(expectedDisputeStage)
            .withAdjustmentFunding(expectedAdjustmentFunding)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryList = summaryList
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseStage = dispute.caseStage else {
                    XCTFail("caseStage cannot be nil")
                    return
                }
                guard let adjustmentFunding = dispute.lastAdjustmentFunding else {
                    XCTFail("adjustmentFunding cannot be nil")
                    return
                }
                XCTAssertEqual(caseStage, expectedDisputeStage)
                XCTAssertEqual(adjustmentFunding, expectedAdjustmentFunding)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_by_status() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let expectedDisputeStatus: DisputeStatus = .underReview
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .and(disputeStatus: expectedDisputeStatus)
            .execute {
                disputeSummaryList = $0
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseStatus = dispute.caseStatus else {
                    XCTFail("caseStatus cannot be nil")
                    return
                }
                XCTAssertEqual(caseStatus, expectedDisputeStatus.mapped(for: .gpApi))
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_by_arn() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let expectedArn = "135091790340196"
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .and(searchCriteria: .aquirerReferenceNumber, value: expectedArn)
            .execute {
                disputeSummaryList = $0
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let transactionARN = dispute.transactionARN else {
                    XCTFail("caseStatus cannot be nil")
                    return
                }
                XCTAssertEqual(transactionARN, expectedArn)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_by_stage() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let expectedDisputeStage = DisputeStage.chargeback
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .and(disputeStage: expectedDisputeStage)
            .execute {
                disputeSummaryList = $0
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseStage = dispute.caseStage else {
                    XCTFail("caseStage cannot be nil")
                    return
                }
                XCTAssertEqual(caseStage, expectedDisputeStage)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_by_merchantId_and_systemHierarchy() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let expectedMerchantId = "8593872"
        let expectedSystemHierarchy = "111-23-099-002-005"
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .and(dataServiceCriteria: .merchantId, value: expectedMerchantId)
            .and(dataServiceCriteria: .systemHierarchy, value: expectedSystemHierarchy)
            .execute {
                disputeSummaryList = $0
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseMerchantId = dispute.caseMerchantId else {
                    XCTFail("caseMerchantId cannot be nil")
                    return
                }
                guard let merchantHierarchy = dispute.merchantHierarchy else {
                    XCTFail("merchantHierarchy cannot be nil")
                    return
                }
                XCTAssertEqual(caseMerchantId, expectedMerchantId)
                XCTAssertEqual(merchantHierarchy, expectedSystemHierarchy)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }


    func test_report_find_disputes_order_by_id() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryIds: [String]?
        var disputeSummaryError: Error?
        var expectedSortedIds: [String]?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .id, .descending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryIds = summaryList?.compactMap { $0.caseId }
                expectedSortedIds = summaryList?.compactMap { $0.caseId }.sorted(by: >)
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryIds, expectedSortedIds)
    }

    func test_report_find_disputes_order_by_brand() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryTypes: [String]?
        var disputeSummaryError: Error?
        var expectedSortedTypes: [String]?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .brand, .descending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryTypes = summaryList?.compactMap { $0.transactionCardType }
                expectedSortedTypes = summaryList?.compactMap { $0.transactionCardType }.sorted(by: >)
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryTypes, expectedSortedTypes)
    }

    func test_report_find_disputes_order_by_status() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryStatuses: [String]?
        var disputeSummaryError: Error?
        var expectedSortedStatuses: [String]?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .status, .descending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryStatuses = summaryList?.compactMap { $0.caseStatus }
                expectedSortedStatuses = summaryList?.compactMap { $0.caseStatus }.sorted(by: >)
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryStatuses, expectedSortedStatuses)
    }

    func test_report_find_disputes_order_by_stage() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryStages: [String]?
        var disputeSummaryError: Error?
        var expectedSortedStages: [String]?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .stage, .descending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryStages = summaryList?.compactMap { $0.caseStage?.rawValue }
                expectedSortedStages = summaryList?.compactMap { $0.caseStage?.rawValue }.sorted(by: >)
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryStages, expectedSortedStages)
    }

    func test_report_find_disputes_order_by_arn() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let oneMonthBefore = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        var disputeSummaryArns: [String]?
        var disputeSummaryError: Error?
        var expectedSortedArns: [String]?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .arn, .descending)
            .withPaging(1, 40)
            .where(.startStageDate, oneYearBefore)
            // EndStageDate must be set in order to be able to sort by ARN
            .and(dataServiceCriteria: .endStageDate, value: oneMonthBefore)
            .execute { summaryList, error in
                disputeSummaryArns = summaryList?.compactMap { $0.transactionARN }
                expectedSortedArns = summaryList?.compactMap { $0.transactionARN }.sorted(by: >)
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryArns, expectedSortedArns)
    }

    func test_report_find_disputes_order_by_from_stage_time_created() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryDates: [Date]?
        var disputeSummaryError: Error?
        var expectedSortedDates: [Date]?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .fromStageTimeCreated, .descending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryDates = summaryList?.compactMap { $0.caseIdTime }
                expectedSortedDates = summaryList?.compactMap { $0.caseIdTime }.sorted(by: { $0.compare($1) == .orderedAscending })
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryDates, expectedSortedDates)
    }

    func test_report_find_disputes_order_by_to_stage_time_created() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .toStageTimeCreated, .ascending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryList = summaryList
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
    }

    func test_report_find_disputes_order_by_adjustment_funding() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryFundings: [String]?
        var disputeSummaryError: Error?
        var expectedSortedFundings: [String]?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .adjustmentFunding, .descending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryFundings = summaryList?.compactMap { $0.lastAdjustmentFunding?.rawValue }
                expectedSortedFundings = summaryList?.compactMap { $0.lastAdjustmentFunding?.rawValue }.sorted(by: >)
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryFundings, expectedSortedFundings)
    }

    func test_report_find_disputes_order_by_id_with_brand_visa() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let expectedCardBrand = "VISA"
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .id, .ascending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .and(searchCriteria: .cardBrand, value: expectedCardBrand)
            .execute { summaryList, error in
                disputeSummaryList = summaryList
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        if let disputeSummaryList = disputeSummaryList {
            XCTAssertFalse(disputeSummaryList.isEmpty)
            for dispute in disputeSummaryList {
                XCTAssertEqual(dispute.transactionCardType, expectedCardBrand)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_order_by_id_with_status_under_review() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .id, .ascending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .and(disputeStatus: .underReview)
            .execute { summaryList, error in
                disputeSummaryList = summaryList
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
    }

    func test_report_find_disputes_order_by_id_with_stage_chargeback() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let expectedStage = DisputeStage.chargeback
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findDisputes()
            .orderBy(disputeOrderBy: .id, .ascending)
            .withPaging(1, 10)
            .where(.startStageDate, oneYearBefore)
            .and(disputeStage: .chargeback)
            .execute { summaryList, error in
                disputeSummaryList = summaryList
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNil(disputeSummaryError)
        if let disputeSummaryList = disputeSummaryList {
            for dispute in disputeSummaryList {
                XCTAssertEqual(dispute.caseStage, expectedStage)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_dispute_by_given_id() {
        // GIVEN
        let summaryExpectation = expectation(description: "Find Dispute By Given ID")
        let disputeId = "DIS_SAND_abcd1253"
        var disputeSummary: DisputeSummary?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService
            .disputeDetail(disputeId: disputeId)
            .execute {
                disputeSummary = $0
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummary)
    }

    func test_report_find_settlement_disputes_with_criteria() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Settlement Disputes With Criteria")
        let oneYearBefore = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService.findSettlementDisputes()
            .orderBy(disputeOrderBy: .brand, .ascending)
            .withPaging(1, 10)
            .withDisputeStatus(.underReview)
            .withDisputeStage(.chargeback)
            .withAdjustmentFunding(.debit)
            .where(.startStageDate, oneYearBefore)
            .execute { summaryList, error in
                disputeSummaryList = summaryList
                disputeSummaryError = error
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
    }

    func test_report_accept_dispute_success() {
        // GIVEN
        let summaryExpectation = expectation(description: "Accept Dispute")
        let disputeId = "DIS_SAND_abcd1234"
        var disputeAction: DisputeAction?
        var disputeActionError: Error?

        // WHEN
        ReportingService
            .acceptDispute(id: disputeId)
            .execute {
                disputeAction = $0
                disputeActionError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNotNil(disputeAction)
        XCTAssertNil(disputeActionError)
    }

    func test_report_accept_dispute_failure() {
        // GIVEN
        let summaryExpectation = expectation(description: "Accept Dispute")
        let disputeId = "UNKNOWN"
        var disputeAction: DisputeAction?
        var disputeActionError: GatewayException?

        // WHEN
        ReportingService
            .acceptDispute(id: disputeId)
            .execute { action, error in
                disputeAction = action
                if let gatewayError = error as? GatewayException {
                    disputeActionError = gatewayError
                }
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        XCTAssertNil(disputeAction)
        XCTAssertNotNil(disputeActionError)
        XCTAssertEqual(disputeActionError?.responseCode, "INVALID_DISPUTE_ACTION")
    }

    func test_report_challange_dispute_success() {
        // GIVEN
        let challangeExpectation = expectation(description: "Challange Expectation")
        let disputeId = "DIS_SAND_abcd1234"
        let bundle = Bundle(for: type(of: self))
        let disputeDocuments = [
            DocumentInfo(
                type: .proofOfDelivery,
                b64Content: ResourceLoader.loadFile(name: "gp_logo", extension: .pdf, bundle: bundle)
            )
        ]
        var disputeAction: DisputeAction?
        var disputeActionError: Error?

        // WHEN
        ReportingService
            .challangeDispute(id: disputeId, documents: disputeDocuments)
            .execute { action, error in
                disputeAction = action
                disputeActionError = error
                challangeExpectation.fulfill()
            }

        // THEN
        wait(for: [challangeExpectation], timeout: 20.0)
        XCTAssertNotNil(disputeAction)
        XCTAssertNil(disputeActionError)
    }

    func test_report_find_dispute_document_success() {
        // GIVEN
        let documetExpectation = expectation(description: "Find document expectation")
        let disputeId = "DIS_SAND_abcd1235"
        let documentId = "DOC_MyEvidence_234234AVCDE-1"
        var documentMetadata: DocumentMetadata?
        var documentError: Error?

        // WHEN
        ReportingService
            .findDisputeDocument(id: documentId, disputeId: disputeId)
            .execute { metadata, error in
                documentMetadata = metadata
                documentError = error
                documetExpectation.fulfill()
            }

        // THEN
        wait(for: [documetExpectation], timeout: 10.0)
        XCTAssertNil(documentError)
        XCTAssertNotNil(documentMetadata)
        XCTAssertEqual(documentMetadata?.id, documentId)
    }

    func test_report_find_dispute_document_failure() {
        // GIVEN
        let documetExpectation = expectation(description: "Find document expectation")
        let disputeId = "UNKNOWN"
        let documentId = "UNKNOWN"
        var documentMetadata: DocumentMetadata?
        var documentError: GatewayException?

        // WHEN
        ReportingService
            .findDisputeDocument(id: documentId, disputeId: disputeId)
            .execute { metadata, error in
                documentMetadata = metadata
                if let gatewayException = error as? GatewayException {
                    documentError = gatewayException
                }
                documetExpectation.fulfill()
            }

        // THEN
        wait(for: [documetExpectation], timeout: 10.0)
        XCTAssertNil(documentMetadata)
        XCTAssertNotNil(documentError)
        XCTAssertEqual(documentError?.responseCode, "INVALID_REQUEST_DATA")
    }

    // MARK: - Settlement Disputes

    func test_report_settlement_dispute_detail() {
        // GIVEN
        let disputeDetailExpectation = expectation(description: "Dispute Detail Expectation")
        let expectedSettlementDisputeId = "DIS_810"
        var disputeSummary: DisputeSummary?
        var disputeError: Error?

        // WHEN
        ReportingService
            .settlementDisputeDetail(disputeId: expectedSettlementDisputeId)
            .execute {
                disputeSummary = $0
                disputeError = $1
                disputeDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [disputeDetailExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        XCTAssertNotNil(disputeSummary)
        XCTAssertEqual(disputeSummary?.caseId, expectedSettlementDisputeId)
    }

    func test_report_find_settlement_disputes_order_by_id() {
        // GIVEN
        let disputeDetailExpectation = expectation(description: "Dispute Detail Expectation")
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryListIds: [String]?
        var expectedDisputeSummaryListIds: [String]?
        var disputeError: Error?

        // WHEN
        ReportingService
            .findSettlementDisputes()
            .orderBy(disputeOrderBy: .id, .descending)
            .withPaging(1, 10)
            .where(.startStageDate, startDate)
            .execute {
                disputeSummaryListIds = $0?.compactMap { $0.caseId }
                expectedDisputeSummaryListIds = $0?.compactMap { $0.caseId }.sorted(by: > )
                disputeError = $1
                disputeDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [disputeDetailExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        XCTAssertNotNil(disputeSummaryListIds)
        XCTAssertEqual(disputeSummaryListIds, expectedDisputeSummaryListIds)
    }

    func test_report_find_settlement_disputes_order_by_arn() {
        // GIVEN
        let disputeDetailExpectation = expectation(description: "Dispute Detail Expectation")
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        var disputeSummaryList: [DisputeSummary]?
        var disputeError: Error?

        // WHEN
        ReportingService
            .findSettlementDisputes()
            .orderBy(disputeOrderBy: .arn, .descending)
            .withPaging(1, 10)
            .where(.startStageDate, startDate)
            .execute {
                disputeSummaryList = $0
                disputeError = $1
                disputeDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [disputeDetailExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        XCTAssertNotNil(disputeSummaryList)
    }

    func test_report_find_settlement_disputes_order_by_id_with_status_underReview() {
        // GIVEN
        let disputeDetailExpectation = expectation(description: "Dispute Detail Expectation")
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        let expectedDisputeStatus: DisputeStatus = .underReview
        var disputeSummaryList: [DisputeSummary]?
        var disputeError: Error?

        // WHEN
        ReportingService
            .findSettlementDisputes()
            .orderBy(disputeOrderBy: .id, .ascending)
            .withPaging(1, 10)
            .where(.startStageDate, startDate)
            .and(disputeStatus: expectedDisputeStatus)
            .execute {
                disputeSummaryList = $0
                disputeError = $1
                disputeDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [disputeDetailExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseStatus = dispute.caseStatus else {
                    XCTFail("caseStatus cannot be nil")
                    return
                }
                XCTAssertEqual(caseStatus, expectedDisputeStatus.mapped(for: .gpApi))
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    // MARK: - Other

    func test_load_test_resources() {
        // GIVEN
        let bundle = Bundle(for: type(of: self))

        //WHEN
        let pdfData = ResourceLoader.loadFile(
            name: "gp_logo",
            extension: .pdf,
            bundle: bundle
        )
        let pngData = ResourceLoader.loadFile(
            name: "gp_logo",
            extension: .png,
            bundle: bundle
        )

        // THEN
        XCTAssertNotNil(pdfData)
        XCTAssertNotNil(pngData)
    }
}
