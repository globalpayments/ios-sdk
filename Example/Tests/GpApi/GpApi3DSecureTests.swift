import XCTest
import GlobalPayments_iOS_SDK

class GpApi3DSecureTests: XCTestCase {

    private let AVAILABLE: String = "AVAILABLE"
    private let FAILED: String = "FAILED"
    private let NOT_AUTHENTICATED: String = "NOT_AUTHENTICATED"
    private let CHALLENGE_REQUIRED: String = "CHALLENGE_REQUIRED"
    private let ENROLLED: String = "ENROLLED"
    private let NOT_ENROLLED: String = "NOT_ENROLLED"
    private let SUCCESS_AUTHENTICATED: String = "SUCCESS_AUTHENTICATED"
    private let SUCCESS_ATTEMPT_MADE: String = "SUCCESS_ATTEMPT_MADE"

    var card: CreditCardData!
    var currency: String!
    var amount: NSDecimalNumber!
    var shippingAddress: Address!
    var billingAddress: Address!
    var browserData: BrowserData!

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib",
            channel: .cardNotPresent,
            country: "GB",
            challengeNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            methodNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            merchantContactUrl: "https://enp4qhvjseljg.x.pipedream.net/"
        ))
    }

    override func setUp() {
        super.setUp()

        // General
        currency = "GBP"
        amount = 10.01

        // Card
        card = CreditCardData()
        card.expMonth = 12
        card.expYear = Date().currentYear + 1
        card.cardHolderName = "James Mason"

        // Shipping Address
        shippingAddress = Address()
        shippingAddress.streetAddress1 = "Apartment 852"
        shippingAddress.streetAddress2 = "Complex 741"
        shippingAddress.streetAddress3 = "no"
        shippingAddress.city = "Chicago"
        shippingAddress.postalCode = "5001"
        shippingAddress.state = "IL"
        shippingAddress.countryCode = "840"

        // Billing Address
        billingAddress = Address()
        billingAddress.streetAddress1 = "Flat 456"
        billingAddress.streetAddress2 = "House 789"
        billingAddress.streetAddress3 = "no"
        billingAddress.city = "Halifax"
        billingAddress.postalCode = "W5 9HR"
        billingAddress.countryCode = "826"

        // Browser Data
        browserData = BrowserData()
        browserData.acceptHeader = "text/html,application/xhtml+xml,application/xml;q=9,image/webp,img/apng,*/*;q=0.8"
        browserData.colorDepth = .twentyFourBits
        browserData.ipAddress = "123.123.123.123"
        browserData.javaEnabled = true
        browserData.javaScriptEnabled = true
        browserData.language = "en"
        browserData.screenHeight = 1920
        browserData.screenWidth = 1080
        browserData.challengeWindowSize = .fullScreen
        browserData.timezone = "0"
        browserData.userAgent = "Mozilla/5.0 (Windows NT 6.1; Win64, x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36"
    }

    override func tearDown() {
        super.tearDown()

        currency = nil
        amount = nil
        card = nil
        shippingAddress = nil
        billingAddress = nil
        browserData = nil
    }

    // MARK: - V1

    func test_card_holder_enrolled_challenge_required_authentication_successful_full_cycle_v1() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardholderEnrolledV1
        let storedCredentials = StoredCredential(type: .unscheduled, initiator: .cardHolder, sequence: .first, reason: .noShow)
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment enrolled challenge Expectation")
        var secureEcom: ThreeDSecure?
        var secureEcomError: BuilderException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .withAuthenticationSource(.browser)
            .withChallengeRequestIndicator(.challengeMandated)
            .withStoredCredential(storedCredentials)
            .execute(version: .one) {
                secureEcom = $0
                
                if let error = $1 as? BuilderException {
                    secureEcomError = error
                }
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(secureEcom)
        XCTAssertNotNil(secureEcomError)
        XCTAssertEqual("3D Secure One is no longer supported!", secureEcomError?.message)
    }

    func test_card_holder_enrolled_challenge_required_authentication_successful_full_cycle_v1_with_tokenized_payment_method() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardholderEnrolledV1
        let tokenizeExpectation = expectation(description: "Tokenize exception")
        var tokenizedCard: CreditCardData?
        var expectedError: Error?

        // WHEN
        card.tokenize { token, error in
            let creditCardData = CreditCardData()
            creditCardData.token = token
            tokenizedCard = creditCardData
            expectedError = error
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(expectedError)
        XCTAssertNotNil(tokenizedCard?.token)

        // GIVEN
        let enrollmentExpectation = expectation(description: "Check Enrollment Required Expectation")
        enrollmentExpectation.assertForOverFulfill = true
        var secureEcom: ThreeDSecure?
        var secureEcomError: BuilderException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .execute(version: .one) {
                secureEcom = $0
                
                if let error = $1 as? BuilderException {
                    secureEcomError = error
                }
                
                enrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [enrollmentExpectation], timeout: 20.0)
        XCTAssertNil(secureEcom)
        XCTAssertNotNil(secureEcomError)
        XCTAssertEqual("3D Secure One is no longer supported!", secureEcomError?.message)
    }

    func test_card_holder_enrolled_challenge_required_V1() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardholderNotEnrolledV1
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: BuilderException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute(version: .one) {
                threeDSecureResult = $0
                
                if let error = $1 as? BuilderException {
                    threeDSecureError = error
                }
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureResult)
        XCTAssertNotNil(threeDSecureError)
        XCTAssertEqual("3D Secure One is no longer supported!", threeDSecureError?.message)
    }

    func test_card_holder_enrolled_challenge_required_authetication_unavailable_V1() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardholderEnrolledV1
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: BuilderException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute(version: .one) {
                threeDSecureResult = $0
                
                if let error = $1 as? BuilderException {
                    threeDSecureError = error
                }
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureResult)
        XCTAssertNotNil(threeDSecureError)
        XCTAssertEqual("3D Secure One is no longer supported!", threeDSecureError?.message)
    }

    func test_card_holder_enrolled_challenge_required_authentication_attempt_acknowledge_V1() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardholderEnrolledV1
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: BuilderException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute(version: .one) {
                threeDSecureResult = $0
                
                if let error = $1 as? BuilderException {
                    threeDSecureError = error
                }
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureResult)
        XCTAssertNotNil(threeDSecureError)
        XCTAssertEqual("3D Secure One is no longer supported!", threeDSecureError?.message)
    }

    func test_card_holder_enrolled_challenge_required_authentication_failed_V1() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardholderEnrolledV1
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: BuilderException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute(version: .one) {
                threeDSecureResult = $0
                
                if let error = $1 as? BuilderException {
                    threeDSecureError = error
                }
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureResult)
        XCTAssertNotNil(threeDSecureError)
        XCTAssertEqual("3D Secure One is no longer supported!", threeDSecureError?.message)
    }

    func test_card_holder_not_enrolled_with_tokenized_payment_method_V1() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardholderNotEnrolledV1
        let tokenizeExpectation = expectation(description: "Tokenize exception")
        var tokenizedCard: CreditCardData?
        var expectedError: Error?

        // WHEN
        card.tokenize { token, error in
            let creditCardData = CreditCardData()
            creditCardData.token = token
            tokenizedCard = creditCardData
            expectedError = error
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(expectedError)
        XCTAssertNotNil(tokenizedCard?.token)

        // Check enrollment

        // GIVEN
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        XCTAssertEqual(threeDSecureResult?.version, .any)
        XCTAssertEqual(threeDSecureResult?.enrolled, NOT_ENROLLED)
        XCTAssertEqual(threeDSecureResult?.status, NOT_ENROLLED)
        XCTAssertNotNil(threeDSecureResult?.challengeReturnUrl)
        XCTAssertNotNil(threeDSecureResult?.messageType)
        XCTAssertNotNil(threeDSecureResult?.sessionDataFieldName)
    }

    func test_card_holder_not_enrolled_v1() {

        // Check Enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardholderNotEnrolledV1
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var checkEnrollmentResult: ThreeDSecure?
        var checkEnrollmentError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                checkEnrollmentResult = $0
                checkEnrollmentError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 10.0)
        XCTAssertNil(checkEnrollmentError)
        XCTAssertNotNil(checkEnrollmentResult)
        XCTAssertEqual(checkEnrollmentResult?.version, .any)
        XCTAssertEqual(checkEnrollmentResult?.enrolled, NOT_ENROLLED)
        XCTAssertEqual(checkEnrollmentResult?.status, NOT_ENROLLED)
        XCTAssertNil(checkEnrollmentResult?.eci)
        XCTAssertEqual(checkEnrollmentResult?.messageVersion, "")
        XCTAssertEqual(checkEnrollmentResult?.challengeMandated, false)

        // Charge

        // GIVEN
        card.threeDSecure = checkEnrollmentResult
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        XCTAssertNotNil(chargeTransactionResult)
        XCTAssertEqual(chargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_card_holder_enrolled_challenge_required_authentication_failed_v1_wrong_acs_value() {

        // Check Enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardholderEnrolledV1
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var checkEnrollmentThreeDSecureResult: ThreeDSecure?
        var checkEnrollmentThreeDSecureError: BuilderException?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute(version: .one) {
                checkEnrollmentThreeDSecureResult = $0
                
                if let error = $1 as? BuilderException {
                    checkEnrollmentThreeDSecureError = error
                }
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(checkEnrollmentThreeDSecureResult)
        XCTAssertNotNil(checkEnrollmentThreeDSecureError)
        XCTAssertEqual("3D Secure One is no longer supported!", checkEnrollmentThreeDSecureError?.message)
    }

    // MARK: - V2

    func test_frictionless_successful_3ds_v2_card_tests() {
        // Frictionless v2.1
        frictionless_full_cycle_v2(cardNumber: GpApi3DSTestCards.cardAuthSuccessfulV21)
        // Frictionless no method url v2.1
        frictionless_full_cycle_v2(cardNumber: GpApi3DSTestCards.cardAuthSuccessfulNoMethodUrlV21)
        // Frictionless v2.2
        frictionless_full_cycle_v2(cardNumber: GpApi3DSTestCards.cardAuthSuccessfulV22)
        // Frictionless no method url v2.2
        frictionless_full_cycle_v2(cardNumber: GpApi3DSTestCards.cardAuthSuccessfulV22)
    }

    func frictionless_full_cycle_v2(cardNumber: String) {

        // Check enrollment

        // GIVEN
        card.number = cardNumber
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        XCTAssertEqual(threeDSecureResult?.enrolled, ENROLLED)
        XCTAssertEqual(threeDSecureResult?.version, .two)
        XCTAssertEqual(threeDSecureResult?.status, AVAILABLE)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        let storedCredential = StoredCredential(type: .unscheduled, initiator: .cardHolder, sequence: .first, reason: .noShow)
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .withStoredCredential(storedCredential)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, SUCCESS_AUTHENTICATED)

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var threeDSecureAuth: ThreeDSecure?
        var authenticationError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                threeDSecureAuth = $0
                authenticationError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authenticationError)
        XCTAssertNotNil(threeDSecureAuth)
        XCTAssertEqual(threeDSecureAuth?.status, SUCCESS_AUTHENTICATED)

        // Card charge

        // GIVEN
        card.threeDSecure = threeDSecureAuth
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_frictionless_failed_3ds_v2_card_tests() {
        frictionless_full_cycle_v2_failed(
            cardNumber: GpApi3DSTestCards.cardAuthAttemptedButNotSuccessfulV21,
            status: SUCCESS_ATTEMPT_MADE
        )
        frictionless_full_cycle_v2_failed(
            cardNumber: GpApi3DSTestCards.cardAuthFailedV21,
            status: NOT_AUTHENTICATED
        )
        frictionless_full_cycle_v2_failed(
            cardNumber: GpApi3DSTestCards.cardAuthIssuerRejectedV21,
            status: FAILED
        )
        frictionless_full_cycle_v2_failed(
            cardNumber: GpApi3DSTestCards.cardAuthCouldNotBePreformedV21,
            status: FAILED
        )
        frictionless_full_cycle_v2_failed(
            cardNumber: GpApi3DSTestCards.cardAuthAttemptedButNotSuccessfulV22,
            status: SUCCESS_ATTEMPT_MADE
        )
        frictionless_full_cycle_v2_failed(
            cardNumber: GpApi3DSTestCards.cardAuthFailedV22,
            status: NOT_AUTHENTICATED
        )
        frictionless_full_cycle_v2_failed(
            cardNumber: GpApi3DSTestCards.cardAuthIssuerRejectedV22,
            status: FAILED
        )
        frictionless_full_cycle_v2_failed(
            cardNumber: GpApi3DSTestCards.cardAuthCouldNotBePreformedV22,
            status: FAILED
        )
    }

    func frictionless_full_cycle_v2_failed(cardNumber: String, status: String) {

        // Check enrollment

        // GIVEN
        card.number = cardNumber
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        XCTAssertEqual(threeDSecureResult?.enrolled, ENROLLED)
        XCTAssertEqual(threeDSecureResult?.version, .two)
        XCTAssertEqual(threeDSecureResult?.status, AVAILABLE)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, status)

        // Get Authentication Data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var getAuthenticationDataThreeDSecureResult: ThreeDSecure?
        var getAuthenticationDataThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                getAuthenticationDataThreeDSecureResult = $0
                getAuthenticationDataThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 10.0)
        XCTAssertNil(getAuthenticationDataThreeDSecureError)
        XCTAssertNotNil(getAuthenticationDataThreeDSecureResult)
        XCTAssertEqual(getAuthenticationDataThreeDSecureResult?.status, status)

        // Charge

        // GIVEN
        card.threeDSecure = getAuthenticationDataThreeDSecureResult
        let chargeExpectation = expectation(description: "Charge Expectation")
        var chargeTransactionResult: Transaction?
        var chargeTransactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                chargeTransactionResult = $0
                chargeTransactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNil(chargeTransactionError)
        XCTAssertNotNil(chargeTransactionResult)
        XCTAssertEqual(chargeTransactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(chargeTransactionResult?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_challenge_successful_3dsv2_card_tests() {
        card_holder_enrolled_challenge_required_v2(
            cardNumber: GpApi3DSTestCards.cardChallengeRequiredV21,
            status: SUCCESS_AUTHENTICATED
        )
//        card_holder_enrolled_challenge_required_v2(
//            cardNumber: GpApi3DSTestCards.cardChallengeRequiredV22,
//            status: SUCCESS_AUTHENTICATED
//        )
    }

    func card_holder_enrolled_challenge_required_v2(cardNumber: String, status: String) {

        // Check enrollment

        // GIVEN
        card.number = cardNumber
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        XCTAssertEqual(threeDSecureResult?.enrolled, ENROLLED)
        XCTAssertEqual(threeDSecureResult?.version, .two)
        XCTAssertEqual(threeDSecureResult?.status, AVAILABLE)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 200.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, CHALLENGE_REQUIRED)
        if let challengeMandated = threeDSecureInitAuthResult?.challengeMandated {
            XCTAssertTrue(challengeMandated)
        } else {
            XCTFail("Expected challengeMandated true")
        }
        XCTAssertNotNil(threeDSecureInitAuthResult?.issuerAcsUrl)
        XCTAssertNotNil(threeDSecureInitAuthResult?.payerAuthenticationRequest)

        // Send challenge

        // GIVEN
        let authenticateExpectation = expectation(description: "Authenticate Expectation")
        let acsClient = GpApi3DSecureAcsClient(redirectURL: threeDSecureInitAuthResult?.issuerAcsUrl)
        var acsResponse: AcsResponse?

        // WHEN
        acsClient?.authenticateV2(secureEcom: threeDSecureInitAuthResult) {
            acsResponse = $0
            authenticateExpectation.fulfill()
        }

        // THEN
        wait(for: [authenticateExpectation], timeout: 500.0)
        XCTAssertNotNil(acsResponse)
        XCTAssertNotNil(acsResponse?.merchantData)

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authThreeDSecureResult: ThreeDSecure?
        var authThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(acsResponse?.merchantData)
            .execute {
                authThreeDSecureResult = $0
                authThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authThreeDSecureError)
        XCTAssertNotNil(authThreeDSecureResult)
        XCTAssertEqual(authThreeDSecureResult?.status, status)

        // Card charge

        // GIVEN
        card.threeDSecure = authThreeDSecureResult
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_challenge_required_get_result_failed_v2() {

        // Check Enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardChallengeRequiredV22
        let checkEnrollmentExpecatation = expectation(description: "Check Enrollment Expecatation")
        var checkEnrollmentThreeDSecureResult: ThreeDSecure?
        var checkEnrollmentThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                checkEnrollmentThreeDSecureResult = $0
                checkEnrollmentThreeDSecureError = $1
                checkEnrollmentExpecatation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpecatation], timeout: 10.0)
        XCTAssertNil(checkEnrollmentThreeDSecureError)
        XCTAssertNotNil(checkEnrollmentThreeDSecureResult)
        XCTAssertEqual(checkEnrollmentThreeDSecureResult?.enrolled, ENROLLED)
        XCTAssertEqual(checkEnrollmentThreeDSecureResult?.version, .two)
        XCTAssertEqual(checkEnrollmentThreeDSecureResult?.status, AVAILABLE)

        // Initiate Authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var initAuthThreeDSecureResult: ThreeDSecure?
        var initAuthThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: checkEnrollmentThreeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                initAuthThreeDSecureResult = $0
                initAuthThreeDSecureError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 10.0)
        XCTAssertNil(initAuthThreeDSecureError)
        XCTAssertNotNil(initAuthThreeDSecureResult)
        XCTAssertEqual(initAuthThreeDSecureResult?.status, CHALLENGE_REQUIRED)
        XCTAssertEqual(initAuthThreeDSecureResult?.challengeMandated, true)
        XCTAssertNotNil(initAuthThreeDSecureResult?.issuerAcsUrl)
        XCTAssertNotNil(initAuthThreeDSecureResult?.challengeValue)

        // Get Authentication Data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var getAuthenticationDataThreeDSecureResult: ThreeDSecure?
        var getAuthenticationDataThreeDSecureError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(initAuthThreeDSecureResult?.serverTransactionId)
            .execute {
                getAuthenticationDataThreeDSecureResult = $0
                getAuthenticationDataThreeDSecureError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 10.0)
        XCTAssertNil(getAuthenticationDataThreeDSecureError)
        XCTAssertNotNil(getAuthenticationDataThreeDSecureResult)
        XCTAssertEqual(getAuthenticationDataThreeDSecureResult?.status, CHALLENGE_REQUIRED)
        XCTAssertNil(getAuthenticationDataThreeDSecureResult?.enrolled)
    }

    func test_full_cycle_frictionless_with_tokenized_payment_method_V2() {

        // Tokenize

        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV21
        let tokenizeExpectation = expectation(description: "Tokenize exception")
        var tokenizedCard: CreditCardData?
        var expectedError: Error?

        // WHEN
        card.tokenize { token, error in
            let creditCardData = CreditCardData()
            creditCardData.token = token
            tokenizedCard = creditCardData
            expectedError = error
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(expectedError)
        XCTAssertNotNil(tokenizedCard?.token)

        // Check enrollment

        // GIVEN
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        XCTAssertEqual(threeDSecureResult?.enrolled, ENROLLED)
        XCTAssertEqual(threeDSecureResult?.version, .two)
        XCTAssertEqual(threeDSecureResult?.status, AVAILABLE)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: tokenizedCard, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, SUCCESS_AUTHENTICATED)

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var threeDSecureAuth: ThreeDSecure?
        var authenticationError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                threeDSecureAuth = $0
                authenticationError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authenticationError)
        XCTAssertNotNil(threeDSecureAuth)
        XCTAssertEqual(threeDSecureAuth?.status, SUCCESS_AUTHENTICATED)

        // Card charge

        // GIVEN
        tokenizedCard?.threeDSecure = threeDSecureAuth
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        tokenizedCard?
            .charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    func test_card_holder_enrolled_challenge_required_v2_duplicate_acs_request() {

        // Check Enrollment

        // GIVEN
        card.number = GpApi3DSTestCards.cardChallengeRequiredV22
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withCurrency(currency)
            .withAmount(amount)
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        XCTAssertEqual(threeDSecureResult?.enrolled, ENROLLED)
        XCTAssertEqual(threeDSecureResult?.version, .two)
        XCTAssertEqual(threeDSecureResult?.status, AVAILABLE)

        // Initiate authentication

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: card, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(billingAddress, .billing)
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, CHALLENGE_REQUIRED)
        XCTAssertEqual(threeDSecureInitAuthResult?.challengeMandated, true)
        XCTAssertNotNil(threeDSecureInitAuthResult?.issuerAcsUrl)
        XCTAssertNotNil(threeDSecureInitAuthResult?.challengeValue)

        // Send challenge - 1

        // GIVEN
        let authenticateExpectation = expectation(description: "Authenticate Expectation")
        let acsClient = GpApi3DSecureAcsClient(redirectURL: threeDSecureInitAuthResult?.issuerAcsUrl)
        var acsResponse: AcsResponse?

        // WHEN
        acsClient?.authenticateV2(secureEcom: threeDSecureInitAuthResult) {
            acsResponse = $0
            authenticateExpectation.fulfill()
        }

        // THEN
        wait(for: [authenticateExpectation], timeout: 500.0)
        XCTAssertNotNil(acsResponse)

        // Send challenge - 2

        // GIVEN
        let authenticateRepeatedExpectation = expectation(description: "Authenticate Expectation")
        let acsClientRepeated = GpApi3DSecureAcsClient(redirectURL: threeDSecureInitAuthResult?.issuerAcsUrl)
        var acsResponseRepeated: AcsResponse?

        // WHEN
        acsClientRepeated?.authenticateV2(secureEcom: threeDSecureInitAuthResult) {
            acsResponseRepeated = $0
            authenticateRepeatedExpectation.fulfill()
        }

        // THEN
        wait(for: [authenticateRepeatedExpectation], timeout: 500.0)
        XCTAssertNotNil(acsResponseRepeated)

        // Get authentication data

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var threeDSecureAuth: ThreeDSecure?
        var authenticationError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                threeDSecureAuth = $0
                authenticationError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20.0)
        XCTAssertNil(authenticationError)
        XCTAssertNotNil(threeDSecureAuth)
        XCTAssertEqual(threeDSecureAuth?.status, SUCCESS_AUTHENTICATED)

        // Card charge

        // GIVEN
        card.threeDSecure = threeDSecureAuth
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
    }

    private func assertCheckEnrollmentChallengeV1(secureEcom: ThreeDSecure?) {
        XCTAssertNotNil(secureEcom)
        XCTAssertEqual(secureEcom?.enrolled, NOT_ENROLLED)
        XCTAssertEqual(secureEcom?.version, .any)
        XCTAssertEqual(secureEcom?.status, NOT_ENROLLED)
        XCTAssertEqual(secureEcom?.challengeMandated, false)
        XCTAssertNotNil(secureEcom?.issuerAcsUrl)
        XCTAssertNotNil(secureEcom?.payerAuthenticationRequest)
        XCTAssertNotNil(secureEcom?.challengeReturnUrl)
        XCTAssertNotNil(secureEcom?.challengeValue)
        XCTAssertNil(secureEcom?.eci)
        XCTAssertEqual(secureEcom?.messageVersion, "")
        XCTAssertNotNil(secureEcom?.messageType)
        XCTAssertNotNil(secureEcom?.sessionDataFieldName)
        XCTAssertEqual(secureEcom?.liabilityShift, "NO")
    }

    func test_decoupled_auth() {
        // GIVEN
        card.number = GpApi3DSTestCards.cardAuthSuccessfulV21
        let tokenizeExpectation = expectation(description: "Tokenize exception")
        var tokenizedCard: CreditCardData?
        var expectedError: Error?

        // WHEN
        card.tokenize { token, error in
            let creditCardData = CreditCardData()
            creditCardData.token = token
            tokenizedCard = creditCardData
            expectedError = error
            tokenizeExpectation.fulfill()
        }

        // THEN
        wait(for: [tokenizeExpectation], timeout: 10.0)
        XCTAssertNil(expectedError)
        XCTAssertNotNil(tokenizedCard?.token)

        // GIVEN
        tokenizedCard?.cardHolderName = "James Mason"
        let checkEnrollmentExpectation = expectation(description: "Check Enrollment Expectation")
        var threeDSecureResult: ThreeDSecure?
        var threeDSecureError: Error?

        // WHEN
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .withDecoupledNotificationUrl("https://www.example.com/decoupledNotification")
            .execute {
                threeDSecureResult = $0
                threeDSecureError = $1
                checkEnrollmentExpectation.fulfill()
            }

        // THEN
        wait(for: [checkEnrollmentExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureError)
        XCTAssertNotNil(threeDSecureResult)
        XCTAssertEqual(threeDSecureResult?.enrolled, ENROLLED)
        XCTAssertEqual(threeDSecureResult?.version, Secure3dVersion.two)
        XCTAssertEqual(threeDSecureResult?.status, AVAILABLE)

        // GIVEN
        let initiateAuthenticationExpectation = expectation(description: "Initiate Authentication Expectation")
        var threeDSecureInitAuthResult: ThreeDSecure?
        var threeDSecureInitAuthError: Error?

        // WHEN
        Secure3dService
            .initiateAuthentication(paymentMethod: tokenizedCard, secureEcom: threeDSecureResult)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.browser)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withAddress(shippingAddress, .shipping)
            .withBrowserData(browserData)
            .withDecoupledFlowRequest(true)
            .withDecoupledFlowTimeout(9001)
            .withDecoupledNotificationUrl("https://www.example.com/decoupledNotification")
            .execute {
                threeDSecureInitAuthResult = $0
                threeDSecureInitAuthError = $1
                initiateAuthenticationExpectation.fulfill()
            }

        // THEN
        wait(for: [initiateAuthenticationExpectation], timeout: 20.0)
        XCTAssertNil(threeDSecureInitAuthError)
        XCTAssertNotNil(threeDSecureInitAuthResult)
        XCTAssertEqual(threeDSecureInitAuthResult?.status, SUCCESS_AUTHENTICATED)
        XCTAssertEqual(threeDSecureInitAuthResult?.liabilityShift, "YES")

        // GIVEN
        let getAuthenticationDataExpectation = expectation(description: "Get Authentication Data Expectation")
        var authenticationThreeDSecure: ThreeDSecure?
        var authenticationError: Error?

        // WHEN
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(threeDSecureInitAuthResult?.serverTransactionId)
            .execute {
                authenticationThreeDSecure = $0
                authenticationError = $1
                getAuthenticationDataExpectation.fulfill()
            }

        // THEN
        wait(for: [getAuthenticationDataExpectation], timeout: 20)
        XCTAssertNil(authenticationError)
        XCTAssertNotNil(authenticationThreeDSecure)
        XCTAssertEqual(authenticationThreeDSecure?.status, SUCCESS_AUTHENTICATED)
        XCTAssertEqual(authenticationThreeDSecure?.liabilityShift, "YES")

        // GIVEN
        tokenizedCard?.threeDSecure = authenticationThreeDSecure
        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResult: Transaction?
        var transactionError: Error?

        // WHEN
        tokenizedCard?.charge(amount: amount)
            .withCurrency(currency)
            .execute {
                transactionResult = $0
                transactionError = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 20.0)
        XCTAssertNil(transactionError)
        XCTAssertNotNil(transactionResult)
        XCTAssertEqual(transactionResult?.responseMessage, TransactionStatus.captured.rawValue)
        XCTAssertEqual(transactionResult?.responseCode, "SUCCESS")
    }
}
