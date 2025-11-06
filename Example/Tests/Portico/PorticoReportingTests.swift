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
    
    func test_ReportFindTransactionWithTransactionId() {
        let executeExpectation = expectation(description: "Find Transaction WithTransactionId")
        
        let reportingService = ReportingService.findTransactions(transactionId: "2045823572")
        var transactionsSummaryResponse: [TransactionSummary]?
        
        reportingService
            .execute { tresaction, error in
                XCTAssertNotNil(tresaction)
                transactionsSummaryResponse = tresaction
                executeExpectation.fulfill()
            }
        
        wait(for: [executeExpectation], timeout: 10.0)
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
            .execute { tresaction, error in
                XCTAssertNotNil(tresaction)
                transactionsSummaryResponse = tresaction
                expectationCharge.fulfill()
            }
        
        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNotNil(reportingService)
        XCTAssertNotNil(transactionsSummaryResponse)
    }
}
