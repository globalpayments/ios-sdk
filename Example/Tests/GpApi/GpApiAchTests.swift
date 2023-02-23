import XCTest
import GlobalPayments_iOS_SDK

final class GpApiAchTests: XCTestCase {

    private var eCheckData: eCheck!
    private var address: Address!
    private var customer: Customer!

    private let CURRENCY = "USD"
    private let AMOUNT: NSDecimalNumber = 10.0

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent
        ))
    }

    override func setUp() {
        super.setUp()

        address = Address()
        address.streetAddress1 = "Apartment 852"
        address.streetAddress2 = "Complex 741"
        address.streetAddress3 = "no"
        address.city = "Chicago"
        address.postalCode = "5001"
        address.state = "IL"
        address.countryCode = "US"

        let bankAddress = Address()
        bankAddress.streetAddress1 = "12000 Smoketown Rd"
        bankAddress.streetAddress2 = "Apt 3B"
        bankAddress.streetAddress3 = "no"
        bankAddress.city = "Mesa"
        bankAddress.postalCode = "22192"
        bankAddress.state = "AZ"
        bankAddress.countryCode = "US"

        eCheckData = eCheck()
        eCheckData.accountNumber = "1234567890"
        eCheckData.routingNumber = "122000030"
        eCheckData.accountType = .saving
        eCheckData.secCode = SecCode.web.mapped(for: .gpApi)
        eCheckData.checkReference = "123"
        eCheckData.merchantNotes = "123"
        eCheckData.bankName = "First Union"
        eCheckData.checkHolderName = "Jane Doe"
        eCheckData.bankAddress = bankAddress

        customer = Customer()
        customer.id = "e193c21a-ce64-4820-b5b6-8f46715de931"
        customer.firstName = "James"
        customer.lastName = "Mason"
        customer.dateOfBirth = "1980-01-01"
        customer.mobilePhone = "+35312345678"
        customer.homePhone = "+11234589"
    }

    func test_check_sale() {
        // GIVEN
        let expectation = expectation(description: "eCheck Charge Expectation")
        var response: Transaction?
        var error: Error?

        // WHEN
        eCheckData.charge(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withAddress(address)
            .withCustomer(customer)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        assertResponse(response, transactionStatus: .captured)
    }

    func test_check_refund() {
        // GIVEN
        let expectation = expectation(description: "eCheck Charge Expectation")
        var response: Transaction?
        var error: Error?

        // WHEN
        eCheckData.refund(amount: AMOUNT)
            .withCurrency(CURRENCY)
            .withAddress(address)
            .execute {
                response = $0
                error = $1
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error)
        assertResponse(response, transactionStatus: .captured)
    }

    func test_check_refund_existing_sale() {
        // GIVEN
        let amount: NSDecimalNumber = 1.29
        let reportingExecuteExpectation = expectation(description: "Check Refund Expectation")
        let startDate = Date().addYears(-1)
        let endDate = Date().addDays(-2)
        let paymentType = PaymentType.sale
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        var transactionsSummary: TransactionSummary?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(paymentType)
            .and(searchCriteria: .startDate, value: startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(searchCriteria: .paymentMethodName, value: PaymentMethodName.bankTransfer)
            .and(dataServiceCriteria: .amount, value: amount)
            .execute {
                transactionsSummary = $0?.results.first
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertNotNil(transactionsSummary)
        XCTAssertEqual(amount, transactionsSummary?.amount)

        // GIVEN
        let refundExpectation = expectation(description: "Refund Expectation")
        var response: Transaction?
        var error: Error?
        let transaction = Transaction()
        transaction.transactionId = transactionsSummary?.transactionId
        transaction.paymentMethodType = .ach

        // WHEN
        transaction.refund()
            .withCurrency(CURRENCY)
            .execute {
                response = $0
                error = $1
                refundExpectation.fulfill()
            }

        // THEN
        wait(for: [refundExpectation], timeout: 10.0)
        XCTAssertNil(error)
        assertResponse(response, transactionStatus: .captured)
    }

    func test_check_reauthorize() {
        // GIVEN
        let reportingExecuteExpectation = expectation(description: "Reauth Check Expectation")
        let startDate = Date().addYears(-1)
        let endDate = Date().addDays(-2)
        let paymentType = PaymentType.sale
        let reportingService = ReportingService.findTransactionsPaged(page: 1, pageSize: 10)
        let eCheckReauth = eCheck()
        eCheckReauth.secCode = SecCode.ppd.mapped(for: .gpApi)
        eCheckReauth.accountNumber = "051904524"
        eCheckReauth.routingNumber = "123456780"
        let amount: NSDecimalNumber = 1.29

        var transactionsSummary: TransactionSummary?
        var transactionsSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .where(paymentType)
            .and(searchCriteria: .startDate, value: startDate)
            .and(searchCriteria: .endDate, value: endDate)
            .and(searchCriteria: .paymentMethodName, value: PaymentMethodName.bankTransfer)
            .and(dataServiceCriteria: .amount, value: amount)
            .execute {
                transactionsSummary = $0?.results.first
                transactionsSummaryError = $1
                reportingExecuteExpectation.fulfill()
            }

        // THEN
        wait(for: [reportingExecuteExpectation], timeout: 10.0)
        XCTAssertNil(transactionsSummaryError)
        XCTAssertNotNil(transactionsSummary)
        XCTAssertEqual(amount, transactionsSummary?.amount)

        // GIVEN
        let reauthExpectation = expectation(description: "Reauth Expectation")
        var response: Transaction?
        var error: Error?
        let transaction = Transaction()
        transaction.transactionId = transactionsSummary?.transactionId
        transaction.paymentMethodType = .ach

        // WHEN
        transaction.reauthorize()
            .withDescription("Resubmitting \(transaction.referenceNumber ?? "")")
            .WithBankTransferData(eCheckReauth)
            .execute {
                response = $0
                error = $1
                reauthExpectation.fulfill()
            }

        // THEN
        wait(for: [reauthExpectation], timeout: 10.0)
        XCTAssertNil(error)
        assertResponse(response, transactionStatus: .captured)
    }

    private func assertResponse(_ response: Transaction?, transactionStatus: TransactionStatus) {
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertEqual(transactionStatus.rawValue, response?.responseMessage)
    }
}
