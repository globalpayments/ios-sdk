import XCTest
import GlobalPayments_iOS_SDK

final class PorticoReportingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        porticoConfiguration()
    }
    
    func porticoConfiguration() {
        let config = PorticoConfig()
        config.secretApiKey = "skapi_cert_MTeSAQAfG1UA9qQDrzl-kz4toXvARyieptFwSKP24w"
        config.serviceUrl = "https://cert.api2.heartlandportico.com"
        try? ServicesContainer.configureService(config: config)
    }
    
    func configuration() {
        let config = PorticoConfig()
        config.secretApiKey = PorticoTestConstants.secretApiKey
        config.serviceUrl = PorticoTestConstants.serviceUrl
        try? ServicesContainer.configureService(config: config)
    }
    
    func test_ReportFindTransactionWithTransactionId() {
        let executeExpectation = expectation(description: "Find Transaction WithTransactionId")
        
        let reportingService = ReportingService.findTransactions(transactionId: "2045823572")
        var transactionsSummaryResponse: [TransactionSummary]?
        
        reportingService
            .execute { transactio, error in
                XCTAssertNotNil(transactio)
                transactionsSummaryResponse = transactio
                executeExpectation.fulfill()
            }
        
        wait(for: [executeExpectation], timeout: 60.0)
        XCTAssertNotNil(reportingService)
        XCTAssertNotNil(transactionsSummaryResponse)
    }
    
    func test_FindTransactionReport() {
        let startDate = Date().addDays(-3)
        
        let expectationCharge = expectation(description: "ReportTransactionDetail")
        let reportingService = ReportingService.findTransactions()
        var transactionsSummaryResponse: [TransactionSummary]?
        
        reportingService
            .withStartDate(startDate)
            .withEndDate(Date())
            .execute { transaction, error in
                XCTAssertNotNil(transaction)
                transactionsSummaryResponse = transaction
                expectationCharge.fulfill()
            }
        
        wait(for: [expectationCharge], timeout: 60.0)
        XCTAssertNotNil(reportingService)
        XCTAssertNotNil(transactionsSummaryResponse)
    }
    
    func testTransactionDetailUnknownTransactionReturnsError() {
        configuration()
        
        let executeExpectation = expectation(description: "Find Transaction WithTransactionId")
        
        let reportingService = ReportingService.transactionDetail(transactionId: "0")
        var transactionSummaryResponse: TransactionSummary?
        
        reportingService
            .execute { transaction, error in
                XCTAssertNotNil(transaction)
                transactionSummaryResponse = transaction
                executeExpectation.fulfill()
            }
        
        wait(for: [executeExpectation], timeout: 60.0)
        XCTAssertNotNil(reportingService)
        XCTAssertNotNil(transactionSummaryResponse)
        XCTAssertEqual("10", transactionSummaryResponse?.gatewayResponseCode)
    }
    
    func testFindTransactionsWithUnknownClientTransactionIdReturnsEmptyList() {
        configuration()
        
        let executeExpectation = expectation(description: "Find Transaction WithTransactionId")
        
        let reportingService = ReportingService.findTransactions(transactionId: "0")
        var transactionSummaryResponse: [TransactionSummary]?
        
        reportingService
            .execute { transaction, error in
                XCTAssertNotNil(transaction)
                transactionSummaryResponse = transaction
                executeExpectation.fulfill()
            }
        
        wait(for: [executeExpectation], timeout: 60.0)
        XCTAssertNotNil(reportingService)
        XCTAssertNotNil(transactionSummaryResponse)
        XCTAssertTrue(transactionSummaryResponse?.count == 0)
    }
}
