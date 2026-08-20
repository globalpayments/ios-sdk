import XCTest
import GlobalPayments_iOS_SDK

/// Integration tests for Cashpresso BNPL payment method via GP-API.
/// Covers both the direct transaction initiation (/transactions) and HPP link creation (/links).
///
/// Note: E2E flow is NOT tested here. The SDK receives a redirect URL and the merchant
/// is responsible for redirecting the consumer. Only the initiation step is verified.
final class GpApiCashpressoTest: XCTestCase {

    // MARK: - Test credentials (QA)

    private let APP_ID = "hlZAokTftDazLlWDPe8E6VAz5g9rSDPg"
    private let APP_KEY = "ThDO2fISzzWCgkCZ"
    private let PAYER_ID = "PYR_992a3181a1bb493ead11474ce0fbd567"

    private let CASHPRESSO_ACCOUNT = "GPECOM_CASHPRESSO_APM_Transaction_Processing"
    private let CURRENCY = "EUR"
    private let COUNTRY = "DE"
    private let WEBHOOK_URL = "https://webhook.site/f5ee2f9d-76a6-4d8b-aa25-75dff93944fc"
    private let HPP_WEBHOOK_URL = "https://webhook.site/62511d22-b672-41ef-afc3-03b136069aeb"

    // MARK: - setUp

    override func setUp() {
        super.setUp()

        let config = GpApiConfig(
            appId: APP_ID,
            appKey: APP_KEY,
            channel: .cardNotPresent
        )
        config.environment = .qa
        config.country = COUNTRY

        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = CASHPRESSO_ACCOUNT
        config.accessTokenInfo = accessTokenInfo
        config.requestLogger = SampleRequestLogger(maskedItems: [])

        try? ServicesContainer.configureService(config: config)
    }

    // MARK: - /transactions tests

    /// Happy-path: initiate a Cashpresso sale with PAY_30_DAYS plan and verify redirect URL.
    func test_cashpresso_initiate_sale_pay30Days() {
        let expectation = expectation(description: "Cashpresso PAY_30_DAYS initiate")
        var response: Transaction?
        var responseError: Error?

        let apm = AlternatePaymentMethod()
        apm.alternativePaymentMethodType = .CASHPRESSO
        apm.paymentPlan = .PAY_30_DAYS
        apm.accountHolderName = "James Mason"
        apm.returnUrl = WEBHOOK_URL
        apm.statusUpdateUrl = WEBHOOK_URL
        apm.cancelUrl = WEBHOOK_URL

        let billingAddress = Address()
        billingAddress.streetAddress1 = "Marienplatz 8"
        billingAddress.streetAddress2 = "Suite 302, Commercial Center"
        billingAddress.streetAddress3 = "Old Town District"
        billingAddress.city = "München"
        billingAddress.postalCode = "80331"
        billingAddress.state = "BY"
        billingAddress.countryCode = "DE"

        let payerDetails = PayerDetails()
        payerDetails.email = "James.Mason82@gmail.com"

        let product = Product()
        product.productId = "Invoice No.68775"
        product.descriptionProduct = "Iphone 16"
        product.quantity = 1
        product.unitPrice = NSDecimalNumber(value: 100)   // 100.00 EUR, matches charge amount
        product.taxAmount = NSDecimalNumber(value: 0)

        apm.charge(amount: 100)
            .withCurrency(CURRENCY)
            .withClientTransactionId("REF-\(Int.random(in: 1000...9999))")
            .withDescription("CashpressoPayment-001")
            .withAddress(billingAddress, type: .billing)
            .withPayerDetails(payerDetails: payerDetails)
            .withPhoneNumber("+49", number: "609568831", type: .Home)
            .withApmShippingMethod(.POSTOFFICE)
            .withShippingDate("2026-08-30")
            .withOrderTaxAmount(Decimal(0))
            .withMiscProductData([product])
            .execute {
                response = $0
                responseError = $1
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 10.0)

        XCTAssertNil(responseError)
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertEqual(
            TransactionStatus.initiated.mapped(for: .gpApi),
            response?.responseMessage
        )
        XCTAssertNotNil(
            response?.alternativePaymentResponse?.redirectUrl,
            "Expected a Cashpresso redirect URL in the response"
        )
        XCTAssertEqual(
            "CASHPRESSO",
            response?.alternativePaymentResponse?.providerName?.uppercased()
        )
        XCTAssertEqual("BNPL", response?.alternativePaymentResponse?.category)
        XCTAssertEqual("PAY_30_DAYS", response?.alternativePaymentResponse?.paymentPlan)

        if let redirectUrl = response?.alternativePaymentResponse?.redirectUrl {
            print("Cashpresso redirect URL: \(redirectUrl)")
        }
    }

    /// Initiate a Cashpresso sale with PAY_IN_3_INSTALLMENTS plan.
    func test_cashpresso_initiate_sale_payIn3Installments() {
        let expectation = expectation(description: "Cashpresso PAY_IN_3_INSTALLMENTS initiate")
        var response: Transaction?
        var responseError: Error?

        let apm = AlternatePaymentMethod()
        apm.alternativePaymentMethodType = .CASHPRESSO
        apm.paymentPlan = .PAY_IN_3_INSTALLMENTS
        apm.accountHolderName = "James Mason"
        apm.returnUrl = WEBHOOK_URL
        apm.statusUpdateUrl = WEBHOOK_URL
        apm.cancelUrl = WEBHOOK_URL

        let billingAddress = Address()
        billingAddress.streetAddress1 = "Marienplatz 8"
        billingAddress.streetAddress2 = "Suite 302"
        billingAddress.streetAddress3 = "Old Town District"
        billingAddress.city = "München"
        billingAddress.postalCode = "80331"
        billingAddress.state = "BY"
        billingAddress.countryCode = "DE"

        let payerDetails = PayerDetails()
        payerDetails.email = "James.Mason82@gmail.com"

        let product = Product()
        product.productId = "Invoice No.68775"
        product.descriptionProduct = "Iphone 16"
        product.quantity = 1
        product.unitPrice = NSDecimalNumber(value: 150)  // 150 EUR = 15000 minor units (minimum for PAY_IN_3_INSTALLMENTS)
        product.taxAmount = NSDecimalNumber(value: 0)

        apm.charge(amount: 150)
            .withCurrency(CURRENCY)
            .withClientTransactionId("REF-\(Int.random(in: 1000...9999))")
            .withDescription("CashpressoPayment-PayIn3")
            .withAddress(billingAddress, type: .billing)
            .withPayerDetails(payerDetails: payerDetails)
            .withPhoneNumber("+49", number: "609568831", type: .Home)
            .withApmShippingMethod(.DELIVERY)
            .withShippingDate("2026-08-30")
            .withOrderTaxAmount(Decimal(0))
            .withMiscProductData([product])
            .execute {
                response = $0
                responseError = $1
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 10.0)

        XCTAssertNil(responseError)
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertEqual(
            TransactionStatus.initiated.mapped(for: .gpApi),
            response?.responseMessage
        )
        XCTAssertNotNil(
            response?.alternativePaymentResponse?.redirectUrl,
            "Expected a Cashpresso redirect URL in the response"
        )
        XCTAssertEqual(
            "CASHPRESSO",
            response?.alternativePaymentResponse?.providerName?.uppercased()
        )
        XCTAssertEqual("BNPL", response?.alternativePaymentResponse?.category)
        XCTAssertEqual("PAY_IN_3_INSTALLMENTS", response?.alternativePaymentResponse?.paymentPlan)

        if let redirectUrl = response?.alternativePaymentResponse?.redirectUrl {
            print("Cashpresso PAY_IN_3_INSTALLMENTS redirect URL: \(redirectUrl)")
        }
    }

    // MARK: - Negative tests (/transactions)

    /// Verifies that omitting returnUrl triggers a BuilderException before hitting the gateway.
    func test_cashpresso_missingReturnUrl() {
        // GIVEN
        let apm = AlternatePaymentMethod()
        apm.alternativePaymentMethodType = .CASHPRESSO
        apm.paymentPlan = .PAY_30_DAYS
        apm.accountHolderName = "James Mason"
        // returnUrl intentionally not set
        apm.statusUpdateUrl = WEBHOOK_URL
        apm.cancelUrl = WEBHOOK_URL

        let expectation = self.expectation(description: "Cashpresso Missing ReturnUrl")
        var response: Transaction?
        var builderError: BuilderException?

        // WHEN
        apm.charge(amount: 100)
            .withCurrency(CURRENCY)
            .execute {
                response = $0
                builderError = $1 as? BuilderException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(builderError)
        XCTAssertEqual(
            "paymentMethod.returnUrl cannot be nil for this rule",
            builderError?.message
        )
    }

    /// Verifies that omitting payment_plan triggers an SDK-level UnsupportedTransactionException.
    func test_cashpresso_missingPaymentPlan() {
        // GIVEN
        let apm = AlternatePaymentMethod()
        apm.alternativePaymentMethodType = .CASHPRESSO
        // paymentPlan intentionally not set
        apm.accountHolderName = "James Mason"
        apm.returnUrl = WEBHOOK_URL
        apm.statusUpdateUrl = WEBHOOK_URL
        apm.cancelUrl = WEBHOOK_URL

        let billingAddress = Address()
        billingAddress.streetAddress1 = "Marienplatz 8"
        billingAddress.streetAddress2 = "Suite 302, Commercial Center"
        billingAddress.streetAddress3 = "Old Town District"
        billingAddress.city = "München"
        billingAddress.postalCode = "80331"
        billingAddress.state = "BY"
        billingAddress.countryCode = "DE"

        let payerDetails = PayerDetails()
        payerDetails.email = "James.Mason82@gmail.com"

        let product = Product()
        product.productId = "Invoice No.68775"
        product.descriptionProduct = "Iphone 16"
        product.quantity = 1
        product.unitPrice = NSDecimalNumber(value: 100)
        product.taxAmount = NSDecimalNumber(value: 0)

        let expectation = self.expectation(description: "Cashpresso Missing PaymentPlan")
        var response: Transaction?
        var sdkError: UnsupportedTransactionException?

        // WHEN
        apm.charge(amount: 100)
            .withCurrency(CURRENCY)
            .withClientTransactionId("REF-\(Int.random(in: 1000...9999))")
            .withAddress(billingAddress, type: .billing)
            .withPayerDetails(payerDetails: payerDetails)
            .withPhoneNumber("+49", number: "609568831", type: .Home)
            .withApmShippingMethod(.DELIVERY)
            .withShippingDate("2026-08-30")
            .withOrderTaxAmount(Decimal(0))
            .withMiscProductData([product])
            .execute {
                response = $0
                sdkError = $1 as? UnsupportedTransactionException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(sdkError)
        XCTAssertEqual("Cashpresso requires payment_plan.", sdkError?.message)
    }

    /// Verifies that PAY_IN_3_INSTALLMENTS with an amount below the minimum triggers an SDK-level exception.
    func test_cashpresso_payIn3Installments_belowMinimumAmount() {
        // GIVEN
        let apm = AlternatePaymentMethod()
        apm.alternativePaymentMethodType = .CASHPRESSO
        apm.paymentPlan = .PAY_IN_3_INSTALLMENTS
        apm.accountHolderName = "James Mason"
        apm.returnUrl = WEBHOOK_URL
        apm.statusUpdateUrl = WEBHOOK_URL
        apm.cancelUrl = WEBHOOK_URL

        let billingAddress = Address()
        billingAddress.streetAddress1 = "Marienplatz 8"
        billingAddress.streetAddress2 = "Suite 302"
        billingAddress.streetAddress3 = "Old Town District"
        billingAddress.city = "München"
        billingAddress.postalCode = "80331"
        billingAddress.state = "BY"
        billingAddress.countryCode = "DE"

        let payerDetails = PayerDetails()
        payerDetails.email = "James.Mason82@gmail.com"

        let product = Product()
        product.productId = "Invoice No.68775"
        product.descriptionProduct = "Iphone 16"
        product.quantity = 1
        product.unitPrice = NSDecimalNumber(value: 100)  // below 15000 minimum
        product.taxAmount = NSDecimalNumber(value: 0)

        let expectation = self.expectation(description: "Cashpresso PAY_IN_3_INSTALLMENTS Below Minimum")
        var response: Transaction?
        var sdkError: UnsupportedTransactionException?

        // WHEN
        apm.charge(amount: 100)  // below 15000 minimum for PAY_IN_3_INSTALLMENTS
            .withCurrency(CURRENCY)
            .withClientTransactionId("REF-\(Int.random(in: 1000...9999))")
            .withAddress(billingAddress, type: .billing)
            .withPayerDetails(payerDetails: payerDetails)
            .withPhoneNumber("+49", number: "609568831", type: .Home)
            .withApmShippingMethod(.DELIVERY)
            .withShippingDate("2026-08-30")
            .withOrderTaxAmount(Decimal(0))
            .withMiscProductData([product])
            .execute {
                response = $0
                sdkError = $1 as? UnsupportedTransactionException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(sdkError)
        XCTAssertEqual(
            "Cashpresso PAY_IN_3_INSTALLMENTS requires amount of 15000 or more (minor units).",
            sdkError?.message
        )
    }

    /// Verifies that omitting shipping_method triggers an SDK-level UnsupportedTransactionException.
    func test_cashpresso_missingShippingMethod() {
        // GIVEN
        let apm = AlternatePaymentMethod()
        apm.alternativePaymentMethodType = .CASHPRESSO
        apm.paymentPlan = .PAY_30_DAYS
        apm.accountHolderName = "James Mason"
        apm.returnUrl = WEBHOOK_URL
        apm.statusUpdateUrl = WEBHOOK_URL
        apm.cancelUrl = WEBHOOK_URL

        let expectation = self.expectation(description: "Cashpresso Missing ShippingMethod")
        var response: Transaction?
        var sdkError: UnsupportedTransactionException?

        // WHEN — shipping_method intentionally not set
        apm.charge(amount: 100)
            .withCurrency(CURRENCY)
            .withShippingDate("2026-08-30")
            .execute {
                response = $0
                sdkError = $1 as? UnsupportedTransactionException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(sdkError)
        XCTAssertEqual("Cashpresso requires shipping_method.", sdkError?.message)
    }

    /// Verifies that omitting shipping_date triggers an SDK-level UnsupportedTransactionException.
    func test_cashpresso_missingShippingDate() {
        // GIVEN
        let apm = AlternatePaymentMethod()
        apm.alternativePaymentMethodType = .CASHPRESSO
        apm.paymentPlan = .PAY_30_DAYS
        apm.accountHolderName = "James Mason"
        apm.returnUrl = WEBHOOK_URL
        apm.statusUpdateUrl = WEBHOOK_URL
        apm.cancelUrl = WEBHOOK_URL

        let expectation = self.expectation(description: "Cashpresso Missing ShippingDate")
        var response: Transaction?
        var sdkError: UnsupportedTransactionException?

        // WHEN — shipping_date intentionally not set
        apm.charge(amount: 100)
            .withCurrency(CURRENCY)
            .withApmShippingMethod(.DELIVERY)
            .execute {
                response = $0
                sdkError = $1 as? UnsupportedTransactionException
                expectation.fulfill()
            }

        // THEN
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(response)
        XCTAssertNotNil(sdkError)
        XCTAssertEqual("Cashpresso requires shipping_date.", sdkError?.message)
    }

    // MARK: - /links (HPP) tests

    /// Happy-path: create a Cashpresso HPP pay-by-link and verify a URL is returned.
    func test_cashpresso_hpp_create_link_allPlans() {
        let expectation = expectation(description: "Cashpresso HPP link creation")
        var response: Transaction?
        var responseError: Error?

        let payByLinkData = PayByLinkData()
        payByLinkData.type = .hosted_payment_page
        payByLinkData.usageMode = .single
        payByLinkData.usageLimit = "1"
        payByLinkData.name = "Mobile Bill Payment"
        payByLinkData.isShippable = false
        payByLinkData.expirationDate = Date().addDays(30)
        payByLinkData.returnUrl = HPP_WEBHOOK_URL
        payByLinkData.statusUpdateUrl = HPP_WEBHOOK_URL
        payByLinkData.cancelUrl = HPP_WEBHOOK_URL

        // Allow both CARD and CASHPRESSO on the HPP
        payByLinkData.allowedPaymentMethods = [.card, .cashpresso]

        // Cashpresso HPP order fields
        payByLinkData.shippingDate = "2026-08-30"
        payByLinkData.shippingMethod = .DELIVERY
        payByLinkData.taxAmount = NSDecimalNumber(value: 0)

        // Order item
        let item = Product()
        item.productName = "Iphone 16"
        item.productId = "IPH65434"
        item.quantity = 1
        item.unitPrice = NSDecimalNumber(value: 650)   // 650 EUR → "65000"
        item.taxAmount = NSDecimalNumber(value: 0)
        payByLinkData.orderItems = [item]

        // payment_method_configuration with Cashpresso APM configurations
        let pmConfig = PaymentMethodConfiguration()
        pmConfig.entryMode = .ecom
        pmConfig.storageMode = .always
        pmConfig.challengeRequestIndicator = .noChallengeRequested

        pmConfig.digitalWalletProviders = [.googlePay, .applePay]

        let cashpressoApmConfig = ApmProviderConfiguration(
            provider: .CASHPRESSO,
            paymentPlans: [.PAY_IN_3_INSTALLMENTS, .PAY_30_DAYS]
        )
        pmConfig.apmConfigurations = [cashpressoApmConfig]
        payByLinkData.configuration = pmConfig

        // DisplayConfiguration
        let displayConfig = DisplayConfiguration()
        displayConfig.iframeDimensionsDomain = "https://www.example.com"
        displayConfig.iframeResponseDomain = "https://www.example.com"
        displayConfig.cardholderName = "YES"
        displayConfig.cvv = "YES"
        payByLinkData.displayConfiguration  = displayConfig

        // Payer
        let customer = Customer()
        customer.id = PAYER_ID
        customer.firstName = "James"
        customer.lastName = "Mason"
        customer.language = "en"
        customer.email = "James.Mason8286@example.com"
        customer.status = "ACTIVE"
        customer.isShippingAddressSameAsBilling = false
        let phone = PhoneNumber()
        phone.countryCode = "+49"
        phone.number = "609568831"
        customer.phoneNumber = phone

        let billingAddress = Address()
        billingAddress.streetAddress1 = "Hauptstraße 25"
        billingAddress.streetAddress2 = "Apartment 12"
        billingAddress.streetAddress3 = "Gebäude C"
        billingAddress.city = "Munich"
        billingAddress.postalCode = "80331"
        billingAddress.state = "BY"
        billingAddress.countryCode = "DE"

        let shippingAddress = Address()
        shippingAddress.streetAddress1 = "100 main st"
        shippingAddress.streetAddress2 = "Guly2"
        shippingAddress.streetAddress3 = "Kop Straße 1892"
        shippingAddress.city = "Frankfurt"
        shippingAddress.postalCode = "60329"
        shippingAddress.state = "HE"
        shippingAddress.countryCode = "DE"

        let shippingPhone = PhoneNumber()
        shippingPhone.countryCode = "+49"
        shippingPhone.number = "609568831"

        // Build and execute
        let builder = AuthorizationBuilder(transactionType: .create)
        builder.withPayByLinkData(payByLinkData)
            .withCurrency(CURRENCY)
            .withAmount(650)
            .withClientTransactionId("TRANS-\(Int.random(in: 10000...99999))")
            .withDescription("February and March Invoice")
            .withCustomerData(customer)
            .withAddress(billingAddress, type: .billing)
            .withAddress(shippingAddress, type: .shipping)

        builder.withPhoneNumber(shippingPhone.countryCode ?? "", number: shippingPhone.number ?? "", type: .Shipping)

        builder.execute { txn, error in
            response = txn
            responseError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)

        XCTAssertNil(responseError)
        XCTAssertNotNil(response)
        XCTAssertEqual("SUCCESS", response?.responseCode)
        XCTAssertNotNil(
            response?.payByLinkResponse?.url,
            "Expected an HPP URL in the response"
        )
        XCTAssertEqual("ACTIVE", response?.payByLinkResponse?.status?.rawValue.uppercased())
        XCTAssertNotNil(response?.payByLinkResponse?.id)
        XCTAssertEqual(NSDecimalNumber(value: 650), response?.balanceAmount)

        if let hppUrl = response?.payByLinkResponse?.url {
            print("Cashpresso HPP URL: \(hppUrl)")
        }
    }
}
