import XCTest
import GlobalPayments_iOS_SDK

final class GpApiOpenBankingTest: XCTestCase {

    private let CURRENCY = "GBP"
    private let AMOUNT: NSDecimalNumber = 10.99

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "4gPqnGBkppGYvoE5UX9EWQlotTxGUDbs",
            appKey: "FQyJA5VuEQfcji2M",
            channel: .cardNotPresent
        ))
    }
    
    func test_faster_payments_charge() {
        // GIVEN
        let bankPayment = fasterPaymentsConfig()
        let expectationFaster = expectation(description: "Faster payments expectation")
        var response: Transaction?
        var error: Error?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                error = $1
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        assertOpenBankingResponse(response)
        sleep(5)
        
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "Report transaction detail expectation")
        var transactionSummaryResponse: TransactionSummary?
        var transactionSummaryError: Error?

        // WHEN
        ReportingService
            .transactionDetail(transactionId: response?.transactionId ?? "")
            .execute {
                transactionSummaryResponse = $0
                transactionSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }
        
        //THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionSummaryError)
        XCTAssertNotNil(transactionSummaryResponse)
        XCTAssertEqual(transactionSummaryResponse?.transactionId, response?.transactionId)
        XCTAssertNotNil(transactionSummaryResponse?.bankPaymentResponse?.sortCode)
        XCTAssertNil(transactionSummaryResponse?.bankPaymentResponse?.iban)
        XCTAssertNotNil(transactionSummaryResponse?.bankPaymentResponse?.accountNumber)
    }
    
    func test_report_find_open_banking_transactions_by_startDate_and_endDate() {
        // GIVEN
        let findExpectation = expectation(description: "Report find transactions expectation")
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionSummaryResult: [TransactionSummary]?
        var transactionSummaryError: Error?
        let startDate = Date().addDays(-30)
        let endDate = Date()
        
        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(paymentProvider: .OPEN_BANKING)
            .execute {
                transactionSummaryResult = $0?.results
                transactionSummaryError = $1
                findExpectation.fulfill()
            }

        // THEN
        wait(for: [findExpectation], timeout: 10.0)
        XCTAssertNil(transactionSummaryError)
        XCTAssertNotNil(transactionSummaryResult)
        
        transactionSummaryResult?.forEach({
            XCTAssertEqual(PaymentMethodName.bankPayment.rawValue, $0.paymentType?.uppercased())
            XCTAssertTrue(endDate >= $0.transactionDate ?? Date())
            XCTAssertTrue(startDate <= $0.transactionDate ?? Date())
        })
    }
    
    func test_SEPA_charge() {
        // GIVEN
        let bankPayment = sepaConfig()
        let expectationFaster = expectation(description: "SEPA payments expectation")
        var response: Transaction?
        var error: Error?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency("EUR")
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                error = $1
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        assertOpenBankingResponse(response)
        sleep(5)
        
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "Report transaction detail expectation")
        var transactionSummaryResponse: TransactionSummary?
        var transactionSummaryError: Error?

        // WHEN
        ReportingService
            .transactionDetail(transactionId: response?.transactionId ?? "")
            .execute {
                transactionSummaryResponse = $0
                transactionSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }
        
        //THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionSummaryError)
        XCTAssertNotNil(transactionSummaryResponse)
        XCTAssertEqual(transactionSummaryResponse?.transactionId, response?.transactionId)
        XCTAssertNil(transactionSummaryResponse?.bankPaymentResponse?.sortCode)
        XCTAssertNotNil(transactionSummaryResponse?.bankPaymentResponse?.iban)
        XCTAssertNil(transactionSummaryResponse?.bankPaymentResponse?.accountNumber)
    }
    
    func test_faster_payments_charge_then_refund() {
        // GIVEN
        let bankPayment = fasterPaymentsConfig()
        let expectationFaster = expectation(description: "Faster payments expectation")
        var response: Transaction?
        var error: Error?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                error = $1
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        assertOpenBankingResponse(response)
        sleep(5)
        
        // GIVEN
        let expectationRefundFaster = expectation(description: "Faster payments refund expectation")
        var responseRefund: Transaction?
        var errorRefund: GatewayException?
        
        // WHEN
        response?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                responseRefund = $0
                if let error = $1 as? GatewayException {
                    errorRefund = error
                }
                expectationRefundFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationRefundFaster], timeout: 10.0)
        XCTAssertNil(responseRefund)
        XCTAssertNotNil(errorRefund)
        XCTAssertEqual(errorRefund?.responseCode, "INVALID_TRANSACTION_ACTION")
        XCTAssertEqual(errorRefund?.responseMessage, "40038")
        XCTAssertEqual(errorRefund?.message, "Status Code: 400 - Can\'t REFUND a Transaction that does not have a Status of CAPTURED")
    }
    
    func test_sepa_payments_charge_then_refund() {
        // GIVEN
        let bankPayment = sepaConfig()
        let expectationFaster = expectation(description: "SEPA payments expectation")
        var response: Transaction?
        var error: Error?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency("EUR")
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                error = $1
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(error)
        XCTAssertNotNil(response)
        assertOpenBankingResponse(response)
        sleep(5)
        
        // GIVEN
        let expectationRefundSepa = expectation(description: "Sepa payments refund expectation")
        var responseRefund: Transaction?
        var errorRefund: GatewayException?
        
        // WHEN
        response?.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .execute {
                responseRefund = $0
                if let error = $1 as? GatewayException {
                    errorRefund = error
                }
                expectationRefundSepa.fulfill()
            }
        
        // THEN
        wait(for: [expectationRefundSepa], timeout: 10.0)
        XCTAssertNil(responseRefund)
        XCTAssertNotNil(errorRefund)
        XCTAssertEqual(errorRefund?.responseCode, "INVALID_TRANSACTION_ACTION")
        XCTAssertEqual(errorRefund?.responseMessage, "40038")
        XCTAssertEqual(errorRefund?.message, "Status Code: 400 - Can\'t REFUND a Transaction that does not have a Status of CAPTURED")
    }
    
    func test_faster_payments_missing_return_url() {
        // GIVEN
        let bankPayment = fasterPaymentsConfig()
        bankPayment.returnUrl = nil
        let expectationFaster = expectation(description: "Faster payments expectation")
        var response: Transaction?
        var errorReturnUrl: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorReturnUrl = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorReturnUrl)
        XCTAssertEqual(errorReturnUrl?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorReturnUrl?.responseMessage, "50046")
        XCTAssertEqual(errorReturnUrl?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_faster_payments_missing_status_url() {
        // GIVEN
        let bankPayment = fasterPaymentsConfig()
        bankPayment.statusUpdateUrl = nil
        let expectationFaster = expectation(description: "Faster payments expectation")
        var response: Transaction?
        var errorMissingData: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorMissingData = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorMissingData)
        XCTAssertEqual(errorMissingData?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorMissingData?.responseMessage, "50046")
        XCTAssertEqual(errorMissingData?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_faster_payments_missing_account_number() {
        // GIVEN
        let bankPayment = fasterPaymentsConfig()
        bankPayment.accountNumber = nil
        let expectationFaster = expectation(description: "Faster payments expectation")
        var response: Transaction?
        var errorMissingData: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorMissingData = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorMissingData)
        XCTAssertEqual(errorMissingData?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorMissingData?.responseMessage, "50046")
        XCTAssertEqual(errorMissingData?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_faster_payments_missing_account_name() {
        // GIVEN
        let bankPayment = fasterPaymentsConfig()
        bankPayment.accountName = nil
        let expectationFaster = expectation(description: "Faster payments expectation")
        var response: Transaction?
        var errorMissingData: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorMissingData = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorMissingData)
        XCTAssertEqual(errorMissingData?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorMissingData?.responseMessage, "50046")
        XCTAssertEqual(errorMissingData?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_faster_payments_missing_sort_code() {
        // GIVEN
        let bankPayment = fasterPaymentsConfig()
        bankPayment.sortCode = nil
        let expectationFaster = expectation(description: "Faster payments expectation")
        var response: Transaction?
        var errorMissingData: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorMissingData = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorMissingData)
        XCTAssertEqual(errorMissingData?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorMissingData?.responseMessage, "50046")
        XCTAssertEqual(errorMissingData?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_faster_payments_invalid_currency() {
        // GIVEN
        let bankPayment = fasterPaymentsConfig()
        let expectationFaster = expectation(description: "Faster payments expectation")
        var response: Transaction?
        var errorInvalidCurrency: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency("EUR")
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorInvalidCurrency = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorInvalidCurrency)
        XCTAssertEqual(errorInvalidCurrency?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorInvalidCurrency?.responseMessage, "50046")
        XCTAssertEqual(errorInvalidCurrency?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_sepa_payments_invalid_cad_currency() {
        // GIVEN
        let bankPayment = sepaConfig()
        let expectationFaster = expectation(description: "Sepa payments expectation")
        var response: Transaction?
        var errorInvalidCurrency: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency("CAD")
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorInvalidCurrency = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorInvalidCurrency)
        XCTAssertEqual(errorInvalidCurrency?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorInvalidCurrency?.responseMessage, "50046")
        XCTAssertEqual(errorInvalidCurrency?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_sepa_payments_missing_account_name() {
        // GIVEN
        let bankPayment = sepaConfig()
        bankPayment.accountName = nil
        let expectationFaster = expectation(description: "Sepa payments expectation")
        var response: Transaction?
        var errorInvalidCurrency: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency("EUR")
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorInvalidCurrency = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorInvalidCurrency)
        XCTAssertEqual(errorInvalidCurrency?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorInvalidCurrency?.responseMessage, "50046")
        XCTAssertEqual(errorInvalidCurrency?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_sepa_payments_missing_iban() {
        // GIVEN
        let bankPayment = sepaConfig()
        bankPayment.iban = nil
        let expectationFaster = expectation(description: "Sepa payments expectation")
        var response: Transaction?
        var errorInvalidCurrency: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency("EUR")
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorInvalidCurrency = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorInvalidCurrency)
        XCTAssertEqual(errorInvalidCurrency?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorInvalidCurrency?.responseMessage, "50046")
        XCTAssertEqual(errorInvalidCurrency?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    func test_sepa_payments_invalid_currency() {
        // GIVEN
        let bankPayment = sepaConfig()
        let expectationFaster = expectation(description: "Sepa payments expectation")
        var response: Transaction?
        var errorInvalidCurrency: GatewayException?
        
        // WHEN
        bankPayment.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute {
                response = $0
                if let error = $1 as? GatewayException {
                    errorInvalidCurrency = error
                }
                expectationFaster.fulfill()
            }
        
        // THEN
        wait(for: [expectationFaster], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(errorInvalidCurrency)
        XCTAssertEqual(errorInvalidCurrency?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
        XCTAssertEqual(errorInvalidCurrency?.responseMessage, "50046")
        XCTAssertEqual(errorInvalidCurrency?.message, "Status Code: 502 - Unable to process your request due to an error with a system down stream.")
    }
    
    private func assertOpenBankingResponse(_ transaction: Transaction?) {
        XCTAssertEqual(TransactionStatus.initiated.rawValue, transaction?.responseMessage)
        XCTAssertNotNil(transaction?.transactionId)
        XCTAssertNotNil(transaction?.bankPaymentResponse?.redirectUrl)
    }
    
    private func fasterPaymentsConfig() -> BankPayment {
        let bankPayment = BankPayment()
        bankPayment.accountNumber = "99999999"
        bankPayment.sortCode = "407777"
        bankPayment.accountName = "Minal"
        bankPayment.countries = ["GB", "IE"]
        bankPayment.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        bankPayment.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        return bankPayment
    }
    
    private func sepaConfig() -> BankPayment {
        let bankPayment = BankPayment()
        bankPayment.iban = "GB33BUKB20201555555555"
        bankPayment.accountName = "AccountName"
        bankPayment.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        bankPayment.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        return bankPayment
    }
}
