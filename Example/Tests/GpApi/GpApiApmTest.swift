import XCTest
import GlobalPayments_iOS_SDK

final class GpApiApmTest: XCTestCase {

    private var paymentMethod: AlternatePaymentMethod!
    private var shippingAddress: Address!
    
    private let CURRENCY = "USD"
    private let AMOUNT: NSDecimalNumber = 7.8

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "4gPqnGBkppGYvoE5UX9EWQlotTxGUDbs",
            appKey: "FQyJA5VuEQfcji2M",
            channel: .cardNotPresent
        ))
    }
    
    override func setUp() {
        super.setUp()
        paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .PAYPAL
        paymentMethod.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.cancelUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.descriptor = "Test Transaction"
        paymentMethod.country = "GB"
        paymentMethod.accountHolderName = "James Mason"

        // shipping address
        shippingAddress = Address()
        shippingAddress.streetAddress1 = "Apartment 852"
        shippingAddress.streetAddress2 = "Complex 741"
        shippingAddress.streetAddress3 = "no"
        shippingAddress.city = "Chicago"
        shippingAddress.postalCode = "5001"
        shippingAddress.state = "IL"
        shippingAddress.countryCode = "US"
    }
    
    public func test_pay_pal_charge_full_cycle() {
        // GIVEN
        let expectationCharge = expectation(description: "Paypal Charge Expectation")
        var responseCharge: Transaction?
        var errorCharge: Error?
        
        // WHEN
        paymentMethod.charge(amount: 1.34)
            .withCurrency(CURRENCY)
            .withDescription("New APM IOS")
            .execute {
                responseCharge = $0
                errorCharge = $1
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
        XCTAssertEqual("INITIATED", responseCharge?.responseMessage)
        print("copy the link and open it in a browser, do the login wih your paypal credentials and authorize the payment in the paypal form. You will be redirected to a blank page with a printed message like this: { \"success\": true }. This has to be done within a 25 seconds timeframe.")
        print(responseCharge?.alternativePaymentResponse?.redirectUrl ?? "no url")
        
        sleep(25)
        
        // GIVEN
        let expectationFind = expectation(description: "Paypal Find Expectation")
        var responseFind: PagedResult<TransactionSummary>?
        var errorFind: Error?
        let service = ReportingService.findTransactionsPaged(page: 1, pageSize: 1)
        let startDate = Date()
        
        // WHEN
        service.withTransactionId(responseCharge?.transactionId)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: startDate)
            .execute {
                responseFind = $0
                errorFind = $1
                expectationFind.fulfill()
            }
        
        // THEN
        wait(for: [expectationFind], timeout: 10.0)
        XCTAssertNil(errorFind)
        XCTAssertNotNil(responseFind)
        XCTAssertTrue(responseFind?.totalRecordCount ?? 0 > 0)
        
        if let transactionSummary = responseFind?.results.first {
            XCTAssertEqual(AlternativePaymentMethodType.PAYPAL.mapped(for: .gpApi), transactionSummary.alternativePaymentResponse?.providerName)
            XCTAssertEqual("PENDING", transactionSummary.transactionStatus?.mapped(for: .gpApi))
            XCTAssertNotNil(transactionSummary.alternativePaymentResponse?.providerReference)
            
            // GIVEN
            let expectationConfirm = expectation(description: "Paypal Confirm expectation")
            var responseConfirm: Transaction?
            var errorConfirm: Error?
            if let transactionId = transactionSummary.transactionId {
                let transaction = Transaction.fromId(transactionId: transactionId, paymentMethodType: .apm)
                transaction.alternativePaymentResponse = transactionSummary.alternativePaymentResponse
                
                // WHEN
                transaction.confirm()
                    .execute {
                        responseConfirm = $0
                        errorConfirm = $1
                        expectationConfirm.fulfill()
                    }
                
                // THEN
                wait(for: [expectationConfirm], timeout: 10.0)
                XCTAssertNil(errorConfirm)
                XCTAssertNotNil(responseConfirm)
                XCTAssertEqual("SUCCESS", responseConfirm?.responseCode)
                XCTAssertEqual("CAPTURED", responseConfirm?.responseMessage)
            }
        }
    }
    
    public func test_pay_pal_capture_full_cycle() {
        // GIVEN
        let expectationCharge = expectation(description: "Paypal Charge Expectation")
        var responseCharge: Transaction?
        var errorCharge: Error?
        
        // WHEN
        paymentMethod.authorize(amount: 1.34)
            .withCurrency(CURRENCY)
            .withDescription("New APM IOS")
            .execute {
                responseCharge = $0
                errorCharge = $1
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
        XCTAssertEqual("INITIATED", responseCharge?.responseMessage)
        print("copy the link and open it in a browser, do the login wih your paypal credentials and authorize the payment in the paypal form. You will be redirected to a blank page with a printed message like this: { \"success\": true }. This has to be done within a 25 seconds timeframe.")
        print(responseCharge?.alternativePaymentResponse?.redirectUrl ?? "no url")
        
        sleep(25)
        
        // GIVEN
        let expectationFind = expectation(description: "Paypal Find Expectation")
        var responseFind: PagedResult<TransactionSummary>?
        var errorFind: Error?
        let service = ReportingService.findTransactionsPaged(page: 1, pageSize: 1)
        let startDate = Date()
        
        // WHEN
        service.withTransactionId(responseCharge?.transactionId)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: startDate)
            .execute {
                responseFind = $0
                errorFind = $1
                expectationFind.fulfill()
            }
        
        // THEN
        wait(for: [expectationFind], timeout: 10.0)
        XCTAssertNil(errorFind)
        XCTAssertNotNil(responseFind)
        XCTAssertTrue(responseFind?.totalRecordCount ?? 0 > 0)
        
        if let transactionSummary = responseFind?.results.first {
            XCTAssertEqual(AlternativePaymentMethodType.PAYPAL.mapped(for: .gpApi), transactionSummary.alternativePaymentResponse?.providerName)
            XCTAssertEqual("PENDING", transactionSummary.transactionStatus?.mapped(for: .gpApi))
            XCTAssertNotNil(transactionSummary.alternativePaymentResponse?.providerReference)
            
            // GIVEN
            let expectationConfirm = expectation(description: "Paypal Confirm expectation")
            var responseConfirm: Transaction?
            var errorConfirm: Error?
            if let transactionId = transactionSummary.transactionId {
                let transaction = Transaction.fromId(transactionId: transactionId, paymentMethodType: .apm)
                transaction.alternativePaymentResponse = transactionSummary.alternativePaymentResponse
                
                // WHEN
                transaction.confirm()
                    .execute {
                        responseConfirm = $0
                        errorConfirm = $1
                        expectationConfirm.fulfill()
                    }
                
                // THEN
                wait(for: [expectationConfirm], timeout: 10.0)
                XCTAssertNil(errorConfirm)
                XCTAssertNotNil(responseConfirm)
                XCTAssertEqual("SUCCESS", responseConfirm?.responseCode)
                XCTAssertEqual("PREAUTHORIZED", responseConfirm?.responseMessage)
                
                // GIVEN
                let expectationCapture = expectation(description: "Paypal Capture expectation")
                var responseCapture: Transaction?
                var errorCapture: Error?
                
                // WHEN
                transaction.capture()
                    .execute {
                        responseCapture = $0
                        errorCapture = $1
                        expectationCapture.fulfill()
                    }

                // THEN
                wait(for: [expectationCapture], timeout: 10.0)
                XCTAssertNil(errorCapture)
                XCTAssertNotNil(responseCapture)
                XCTAssertEqual("SUCCESS", responseCapture?.responseCode)
                XCTAssertEqual("CAPTURED", responseCapture?.responseMessage)
            }
        }
    }
    
    public func test_pay_pal_refund_full_cycle() {
        // GIVEN
        let expectationCharge = expectation(description: "Paypal Charge Expectation")
        var responseCharge: Transaction?
        var errorCharge: Error?
        
        // WHEN
        paymentMethod.charge(amount: 1.34)
            .withCurrency(CURRENCY)
            .withDescription("New APM IOS")
            .execute {
                responseCharge = $0
                errorCharge = $1
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
        XCTAssertEqual("INITIATED", responseCharge?.responseMessage)
        print("copy the link and open it in a browser, do the login wih your paypal credentials and authorize the payment in the paypal form. You will be redirected to a blank page with a printed message like this: { \"success\": true }. This has to be done within a 25 seconds timeframe.")
        print(responseCharge?.alternativePaymentResponse?.redirectUrl ?? "no url")
        
        sleep(25)
        
        // GIVEN
        let expectationFind = expectation(description: "Paypal Find Expectation")
        var responseFind: PagedResult<TransactionSummary>?
        var errorFind: Error?
        let service = ReportingService.findTransactionsPaged(page: 1, pageSize: 1)
        let startDate = Date()
        
        // WHEN
        service.withTransactionId(responseCharge?.transactionId)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: startDate)
            .execute {
                responseFind = $0
                errorFind = $1
                expectationFind.fulfill()
            }
        
        // THEN
        wait(for: [expectationFind], timeout: 10.0)
        XCTAssertNil(errorFind)
        XCTAssertNotNil(responseFind)
        XCTAssertTrue(responseFind?.totalRecordCount ?? 0 > 0)
        
        if let transactionSummary = responseFind?.results.first {
            XCTAssertEqual(AlternativePaymentMethodType.PAYPAL.mapped(for: .gpApi), transactionSummary.alternativePaymentResponse?.providerName)
            XCTAssertEqual("PENDING", transactionSummary.transactionStatus?.mapped(for: .gpApi))
            XCTAssertNotNil(transactionSummary.alternativePaymentResponse?.providerReference)
            
            // GIVEN
            let expectationConfirm = expectation(description: "Paypal Confirm expectation")
            var responseConfirm: Transaction?
            var errorConfirm: Error?
            if let transactionId = transactionSummary.transactionId {
                let transaction = Transaction.fromId(transactionId: transactionId, paymentMethodType: .apm)
                transaction.alternativePaymentResponse = transactionSummary.alternativePaymentResponse
                
                // WHEN
                transaction.confirm()
                    .execute {
                        responseConfirm = $0
                        errorConfirm = $1
                        expectationConfirm.fulfill()
                    }
                
                // THEN
                wait(for: [expectationConfirm], timeout: 10.0)
                XCTAssertNil(errorConfirm)
                XCTAssertNotNil(responseConfirm)
                XCTAssertEqual("SUCCESS", responseConfirm?.responseCode)
                XCTAssertEqual("CAPTURED", responseConfirm?.responseMessage)
                
                // GIVEN
                let expectationRefund = expectation(description: "Paypal Refund expectation")
                var responseRefund: Transaction?
                var errorRefund: Error?
                
                // WHEN
                transaction.refund()
                    .withCurrency(CURRENCY)
                    .execute {
                        responseRefund = $0
                        errorRefund = $1
                        expectationRefund.fulfill()
                    }

                // THEN
                wait(for: [expectationRefund], timeout: 10.0)
                XCTAssertNil(errorRefund)
                XCTAssertNotNil(responseRefund)
                XCTAssertEqual("SUCCESS", responseRefund?.responseCode)
                XCTAssertEqual("CAPTURED", responseRefund?.responseMessage)
            }
        }
    }
    
    //Sandbox returning: Can't CAPTURE a Transaction that is already CAPTURED
    public func test_pay_pal_reverse_full_cycle() {
        // GIVEN
        let expectationCharge = expectation(description: "Paypal Charge Expectation")
        var responseCharge: Transaction?
        var errorCharge: Error?
        
        // WHEN
        paymentMethod.charge(amount: 1.34)
            .withCurrency(CURRENCY)
            .withDescription("New APM IOS")
            .execute {
                responseCharge = $0
                errorCharge = $1
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
        XCTAssertEqual("INITIATED", responseCharge?.responseMessage)
        print("copy the link and open it in a browser, do the login wih your paypal credentials and authorize the payment in the paypal form. You will be redirected to a blank page with a printed message like this: { \"success\": true }. This has to be done within a 25 seconds timeframe.")
        print(responseCharge?.alternativePaymentResponse?.redirectUrl ?? "no url")
        
        sleep(25)
        
        // GIVEN
        let expectationFind = expectation(description: "Paypal Find Expectation")
        var responseFind: PagedResult<TransactionSummary>?
        var errorFind: Error?
        let service = ReportingService.findTransactionsPaged(page: 1, pageSize: 1)
        let startDate = Date()
        
        // WHEN
        service.withTransactionId(responseCharge?.transactionId)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: startDate)
            .execute {
                responseFind = $0
                errorFind = $1
                expectationFind.fulfill()
            }
        
        // THEN
        wait(for: [expectationFind], timeout: 10.0)
        XCTAssertNil(errorFind)
        XCTAssertNotNil(responseFind)
        XCTAssertTrue(responseFind?.totalRecordCount ?? 0 > 0)
        
        if let transactionSummary = responseFind?.results.first {
            XCTAssertEqual(AlternativePaymentMethodType.PAYPAL.mapped(for: .gpApi), transactionSummary.alternativePaymentResponse?.providerName)
            XCTAssertEqual("PENDING", transactionSummary.transactionStatus?.mapped(for: .gpApi))
            XCTAssertNotNil(transactionSummary.alternativePaymentResponse?.providerReference)
            
            // GIVEN
            let expectationConfirm = expectation(description: "Paypal Confirm expectation")
            var responseConfirm: Transaction?
            var errorConfirm: Error?
            if let transactionId = transactionSummary.transactionId {
                let transaction = Transaction.fromId(transactionId: transactionId, paymentMethodType: .apm)
                transaction.alternativePaymentResponse = transactionSummary.alternativePaymentResponse
                
                // WHEN
                transaction.confirm()
                    .execute {
                        responseConfirm = $0
                        errorConfirm = $1
                        expectationConfirm.fulfill()
                    }
                
                // THEN
                wait(for: [expectationConfirm], timeout: 10.0)
                XCTAssertNil(errorConfirm)
                XCTAssertNotNil(responseConfirm)
                XCTAssertEqual("SUCCESS", responseConfirm?.responseCode)
                XCTAssertEqual("CAPTURED", responseConfirm?.responseMessage)
                
                // GIVEN
                let expectationReverse = expectation(description: "Paypal Reverse expectation")
                var responseReverse: Transaction?
                var errorReverse: Error?
                
                // WHEN
                transaction.reverse()
                    .withCurrency(CURRENCY)
                    .execute {
                        responseReverse = $0
                        errorReverse = $1
                        expectationReverse.fulfill()
                    }

                // THEN
                wait(for: [expectationReverse], timeout: 10.0)
                XCTAssertNil(errorReverse)
                XCTAssertNotNil(responseReverse)
                XCTAssertEqual("SUCCESS", responseReverse?.responseCode)
                XCTAssertEqual("REVERSED", responseReverse?.responseMessage)
            }
        }
    }
    
    public func test_pay_pal_multi_capture_full_cycle() {
        // GIVEN
        let expectationCharge = expectation(description: "Paypal Charge Expectation")
        var responseCharge: Transaction?
        var errorCharge: Error?
        
        // WHEN
        paymentMethod.authorize(amount: 1.34)
            .withCurrency(CURRENCY)
            .withMultiCapture(true)
            .withDescription("New APM IOS MultiCapture")
            .execute {
                responseCharge = $0
                errorCharge = $1
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 10.0)
        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
        XCTAssertEqual("INITIATED", responseCharge?.responseMessage)
        print("copy the link and open it in a browser, do the login wih your paypal credentials and authorize the payment in the paypal form. You will be redirected to a blank page with a printed message like this: { \"success\": true }. This has to be done within a 25 seconds timeframe.")
        print(responseCharge?.alternativePaymentResponse?.redirectUrl ?? "no url")
        
        sleep(25)
        
        // GIVEN
        let expectationFind = expectation(description: "Paypal Find Expectation")
        var responseFind: PagedResult<TransactionSummary>?
        var errorFind: Error?
        let service = ReportingService.findTransactionsPaged(page: 1, pageSize: 1)
        let startDate = Date()
        
        // WHEN
        service.withTransactionId(responseCharge?.transactionId)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: startDate)
            .execute {
                responseFind = $0
                errorFind = $1
                expectationFind.fulfill()
            }
        
        // THEN
        wait(for: [expectationFind], timeout: 10.0)
        XCTAssertNil(errorFind)
        XCTAssertNotNil(responseFind)
        XCTAssertTrue(responseFind?.totalRecordCount ?? 0 > 0)
        
        if let transactionSummary = responseFind?.results.first {
            XCTAssertEqual(AlternativePaymentMethodType.PAYPAL.mapped(for: .gpApi), transactionSummary.alternativePaymentResponse?.providerName)
            XCTAssertEqual("PENDING", transactionSummary.transactionStatus?.mapped(for: .gpApi))
            XCTAssertNotNil(transactionSummary.alternativePaymentResponse?.providerReference)
            
            // GIVEN
            let expectationConfirm = expectation(description: "Paypal Confirm expectation")
            var responseConfirm: Transaction?
            var errorConfirm: Error?
            if let transactionId = transactionSummary.transactionId {
                let transaction = Transaction.fromId(transactionId: transactionId, paymentMethodType: .apm)
                transaction.alternativePaymentResponse = transactionSummary.alternativePaymentResponse
                
                // WHEN
                transaction.confirm()
                    .execute {
                        responseConfirm = $0
                        errorConfirm = $1
                        expectationConfirm.fulfill()
                    }
                
                // THEN
                wait(for: [expectationConfirm], timeout: 10.0)
                XCTAssertNil(errorConfirm)
                XCTAssertNotNil(responseConfirm)
                XCTAssertEqual("SUCCESS", responseConfirm?.responseCode)
                XCTAssertEqual("PREAUTHORIZED", responseConfirm?.responseMessage)
                
                // GIVEN
                let expectationCapture = expectation(description: "Paypal Capture expectation")
                var responseCapture: Transaction?
                var errorCapture: Error?
                
                // WHEN
                transaction.capture()
                    .execute {
                        responseCapture = $0
                        errorCapture = $1
                        expectationCapture.fulfill()
                    }

                // THEN
                wait(for: [expectationCapture], timeout: 10.0)
                XCTAssertNil(errorCapture)
                XCTAssertNotNil(responseCapture)
                XCTAssertEqual("SUCCESS", responseCapture?.responseCode)
                XCTAssertEqual("CAPTURED", responseCapture?.responseMessage)
                
                // GIVEN
                let expectationCapture2 = expectation(description: "Paypal Capture2 expectation")
                var responseCapture2: Transaction?
                var errorCapture2: Error?
                
                // WHEN
                transaction.capture()
                    .execute {
                        responseCapture2 = $0
                        errorCapture2 = $1
                        expectationCapture2.fulfill()
                    }

                // THEN
                wait(for: [expectationCapture2], timeout: 10.0)
                XCTAssertNil(errorCapture2)
                XCTAssertNotNil(responseCapture2)
                XCTAssertEqual("SUCCESS", responseCapture2?.responseCode)
                XCTAssertEqual("CAPTURED", responseCapture2?.responseMessage)
            }
        }
    }
    
    func test_aliPay() {
        // GIVEN
        let expectationCharge = expectation(description: "AliPay charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ALIPAY
        paymentMethod.returnUrl = "https://example.com/returnUrl"
        paymentMethod.statusUpdateUrl = "https://example.com/statusUrl"
        paymentMethod.country = "US"
        paymentMethod.accountHolderName = "Jane Doe"
        var responseCharge: Transaction?
        var errorCharge: Error?

        // WHEN
        paymentMethod.charge(amount: 19.99)
            .withCurrency("HKD")
            .withMerchantCategory(.OTHER)
            .execute {
                responseCharge = $0
                errorCharge = $1
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 8.0)
        XCTAssertNil(errorCharge)
        XCTAssertNotNil(responseCharge)
        XCTAssertEqual("SUCCESS", responseCharge?.responseCode)
        XCTAssertEqual(TransactionStatus.initiated.rawValue, responseCharge?.responseMessage)
        XCTAssertNotNil(responseCharge?.alternativePaymentResponse?.redirectUrl)
        XCTAssertEqual(AlternativePaymentMethodType.ALIPAY.mapped(for: .gpApi), responseCharge?.alternativePaymentResponse?.providerName?.lowercased())
    }
    
    func test_alipay_missing_return_url() {
        // GIVEN
        let expectationCharge = expectation(description: "AliPay charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ALIPAY
        paymentMethod.statusUpdateUrl = "https://example.com/statusUrl"
        paymentMethod.country = "US"
        paymentMethod.accountHolderName = "Jane Doe"
        var responseCharge: Transaction?
        var errorCharge: BuilderException?

        // WHEN
        paymentMethod.charge(amount: 19.99)
            .withCurrency("HKD")
            .withMerchantCategory(.OTHER)
            .execute {
                responseCharge = $0
                if let error = $1 as? BuilderException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 8.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("paymentMethod.returnUrl cannot be nil for this rule", errorCharge?.message)
    }
    
    func test_alipay_missing_status_update_url() {
        // GIVEN
        let expectationCharge = expectation(description: "AliPay charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ALIPAY
        paymentMethod.returnUrl = "https://example.com/returnUrl"
        paymentMethod.country = "US"
        paymentMethod.accountHolderName = "Jane Doe"
        var responseCharge: Transaction?
        var errorCharge: BuilderException?

        // WHEN
        paymentMethod.charge(amount: 19.99)
            .withCurrency("HKD")
            .withMerchantCategory(.OTHER)
            .execute {
                responseCharge = $0
                if let error = $1 as? BuilderException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 8.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("paymentMethod.statusUpdateUrl cannot be nil for this rule", errorCharge?.message)
    }
    
    func test_alipay_missing_account_holderName() {
        // GIVEN
        let expectationCharge = expectation(description: "AliPay charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ALIPAY
        paymentMethod.returnUrl = "https://example.com/returnUrl"
        paymentMethod.statusUpdateUrl = "https://example.com/statusUrl"
        paymentMethod.country = "US"
        var responseCharge: Transaction?
        var errorCharge: BuilderException?

        // WHEN
        paymentMethod.charge(amount: 19.99)
            .withCurrency("HKD")
            .withMerchantCategory(.OTHER)
            .execute {
                responseCharge = $0
                if let error = $1 as? BuilderException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 8.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("paymentMethod.accountHolderName cannot be nil for this rule", errorCharge?.message)
    }
    
    func test_alipay_missing_currency() {
        // GIVEN
        let expectationCharge = expectation(description: "AliPay charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ALIPAY
        paymentMethod.returnUrl = "https://example.com/returnUrl"
        paymentMethod.statusUpdateUrl = "https://example.com/statusUrl"
        paymentMethod.country = "US"
        paymentMethod.accountHolderName = "Jane Doe"
        var responseCharge: Transaction?
        var errorCharge: BuilderException?

        // WHEN
        paymentMethod.charge(amount: 19.99)
            .withMerchantCategory(.OTHER)
            .execute {
                responseCharge = $0
                if let error = $1 as? BuilderException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 8.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("currency cannot be nil for this rule", errorCharge?.message)
    }
    
    func test_alipay_missing_merchant_category() {
        // GIVEN
        let expectationCharge = expectation(description: "AliPay charge Expectation")
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ALIPAY
        paymentMethod.returnUrl = "https://example.com/returnUrl"
        paymentMethod.statusUpdateUrl = "https://example.com/statusUrl"
        paymentMethod.country = "US"
        paymentMethod.accountHolderName = "Jane Doe"
        var responseCharge: Transaction?
        var errorCharge: GatewayException?

        // WHEN
        paymentMethod.charge(amount: 19.99)
            .withCurrency("HKD")
            .execute {
                responseCharge = $0
                if let error = $1 as? GatewayException {
                    errorCharge = error
                }
                expectationCharge.fulfill()
            }
        
        // THEN
        wait(for: [expectationCharge], timeout: 8.0)
        XCTAssertNotNil(errorCharge)
        XCTAssertNil(responseCharge)
        XCTAssertEqual("Status Code: 400 - Request expects the following fields merchant_category", errorCharge?.message)
    }
}
