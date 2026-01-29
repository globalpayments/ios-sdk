//
//  GpApiHPPPayByLinksTests.swift
//  GlobalPayments-iOS-SDK_Tests
//

import XCTest
import GlobalPayments_iOS_SDK

final class GpApiHPPPayByLinksTests: XCTestCase {

    private let APP_ID = "hkjrcsGDhWiDt8GEhoDMKy3pzFz5R0Bo"
    private let APP_KEY = "cQOKHoAAvNIcEN8s"
    private let billingAddress = Address()
    private let shippingAddress = Address()
    private let newCustomer = Customer()
    private let returnUrl = "https://www.example.com/returnUrl"
    private let statusUrl = "https://www.example.com/statusUrl"
    private let amount: NSDecimalNumber = 10.0
    
    override func setUp() {
        super.setUp()
        configuration()
    }
    
    func configuration() {
        let maskedItems = [
            MaskedItem(value: "payment_method.card.expiry_month", start: 0, end: 0),
            MaskedItem(value: "payment_method.card.number", start: 12, end: 0),
            MaskedItem(value: "payment_method.card.expiry_year", start: 0, end: 0),
            MaskedItem(value: "payment_method.card.cvv", start: 0, end: 0)
        ]
        
        let config = GpApiConfig(
            appId: APP_ID,
            appKey: APP_KEY)
        config.country = "US"
        
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "GPECOM_HPP_Transaction_Processing"
        config.accessTokenInfo = accessTokenInfo
        
        config.requestLogger = SampleRequestLogger(maskedItems: maskedItems)
        try? ServicesContainer.configureService(config: config)
        
        billingAddress.streetAddress1 = "Apartment 852"
        billingAddress.streetAddress2 = "Complex 741"
        billingAddress.streetAddress3 = "no"
        billingAddress.city = "Chicago"
        billingAddress.postalCode = "50001"
        billingAddress.state = "IL"
        billingAddress.country = "US"
        
        shippingAddress.streetAddress1 = "Apartment 852"
        shippingAddress.streetAddress2 = "Complex 741"
        shippingAddress.streetAddress3 = "no"
        shippingAddress.city = "Chicago"
        shippingAddress.postalCode = "50001"
        shippingAddress.state = "IL"
        shippingAddress.country = "US"
        
        newCustomer.email = "JAMESMASON@EXAMPLE.COM"
        newCustomer.firstName = "JAMES"
        newCustomer.lastName = "Smith"
        newCustomer.language = "EN"
        newCustomer.isShippingAddressSameAsBilling = true
        newCustomer.status = "NEW"
        newCustomer.phoneNumber = PhoneNumber()
        newCustomer.phoneNumber?.countryCode = "44"
        newCustomer.phoneNumber?.number = "7853283864"
    }
    
    func testCreateHPPPayByLinkWithNewCustomerReturnsSuccess() {
        let payByLinkData = PayByLinkData()
        payByLinkData.type = .hosted_payment_page
        payByLinkData.usageMode = .single
        payByLinkData.allowedPaymentMethods = [.card, .bankPayment]
        payByLinkData.usageLimit = "1"
        payByLinkData.name = "Mobile Bill Payment"
        payByLinkData.isShippable = false
        payByLinkData.shippingAmount = 100
        
        payByLinkData.expirationDate =  Date().addDays(10)
        payByLinkData.returnUrl = returnUrl
        payByLinkData.statusUpdateUrl = statusUrl
        payByLinkData.cancelUrl = returnUrl
        
        let paymentMethodConfiguration = PaymentMethodConfiguration()
        paymentMethodConfiguration.isAddressOverrideAllowed = false
        paymentMethodConfiguration.isShippingAddressEnabled = true
        paymentMethodConfiguration.challengeRequestIndicator = .challengePreferred
        paymentMethodConfiguration.exemptStatus  = .lowValue
        paymentMethodConfiguration.isBillingAddressRequired = true
        paymentMethodConfiguration.storageMode = .off
        payByLinkData.configuration = paymentMethodConfiguration
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        PayByLinkService.create(payByLink: payByLinkData, amount: amount)
            .withCurrency("USD")
            .withClientTransactionId("TestOrder-123")
            .withAddress(shippingAddress, type: .shipping)
            .withAddress(billingAddress, type: .billing)
            .withCustomerData(newCustomer)
            .withDescription("HPP_Links_Test")
            .withPhoneNumber("99", number: "1801555999", type: .Shipping)
            .execute { transacation, error in
                XCTAssertNil(error)
                XCTAssertNotNil(transacation)
                XCTAssertEqual(PayByLinkStatus.ACTIVE.rawValue, transacation?.payByLinkResponse?.status?.rawValue)
                XCTAssertNotNil(transacation?.payByLinkResponse?.url)
                XCTAssertNotNil(transacation?.payByLinkResponse?.id)
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
    }

    func testCreateHPPPayByLinkWithExistingActiveCustomerReturnsSuccess() {
        newCustomer.id = "PYR_4f23b94af9294efb8b839e9d1b3f74e1"
        newCustomer.status = "ACTIVE"
        
        let payByLinkData = PayByLinkData()
        payByLinkData.type = .hosted_payment_page
        payByLinkData.usageMode = .single
        payByLinkData.allowedPaymentMethods = [.card, .bankTransfer]
        payByLinkData.usageLimit = "1"
        payByLinkData.name = "Mobile Bill Payment"
        payByLinkData.isShippable = false
        payByLinkData.shippingAmount = 100
        
        payByLinkData.expirationDate =  Date().addDays(10)
        payByLinkData.returnUrl = returnUrl
        payByLinkData.statusUpdateUrl = statusUrl
        payByLinkData.cancelUrl = returnUrl
        
        let paymentMethodConfiguration = PaymentMethodConfiguration()
        paymentMethodConfiguration.isAddressOverrideAllowed = false
        paymentMethodConfiguration.isShippingAddressEnabled = true
        paymentMethodConfiguration.challengeRequestIndicator = .noChallengeRequested
        paymentMethodConfiguration.exemptStatus  = .lowValue
        paymentMethodConfiguration.isBillingAddressRequired = false
        paymentMethodConfiguration.storageMode = .off
        payByLinkData.configuration = paymentMethodConfiguration
        
        let expectation = XCTestExpectation(description: "Wait for execution...")
        
        PayByLinkService.create(payByLink: payByLinkData, amount: amount)
            .withCurrency("USD")
            .withClientTransactionId(UUID().uuidString)
            .withAddress(shippingAddress, type: .shipping)
            .withAddress(billingAddress, type: .billing)
            .withCustomerData(newCustomer)
            .withDescription("HPP_Links_Test")
            .withPhoneNumber("99", number: "1801555999", type: .Shipping)
            .execute { transacation, error in
                XCTAssertNil(error)
                XCTAssertNotNil(transacation)
                XCTAssertEqual(PayByLinkStatus.ACTIVE.rawValue, transacation?.payByLinkResponse?.status?.rawValue)
                XCTAssertNotNil(transacation?.payByLinkResponse?.url)
                XCTAssertNotNil(transacation?.payByLinkResponse?.id)
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 120.0)
    }
}
