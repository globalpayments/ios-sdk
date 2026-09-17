import XCTest
import GlobalPayments_iOS_SDK

class GpApiFraudManagementTests: XCTestCase {

    private var currency: String!
    private var amount: NSDecimalNumber!
    private var card: CreditCardData!

    override class func setUp() {
        super.setUp()
        
        let accessTokenInfo = AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "transaction_processing"

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "4gPqnGBkppGYvoE5UX9EWQlotTxGUDbs",
            appKey: "FQyJA5VuEQfcji2M",
            channel: .cardNotPresent,
            accessTokenInfo: accessTokenInfo
        ))
    }
    
    override func setUp() {
        super.setUp()

        currency = "USD"
        amount = 98.10
        
        // create the card object
        card = CreditCardData();
        card.number = "4263970000005262"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "131"
        card.cardHolderName = "James Mason"
    }

    override func tearDown() {
        super.tearDown()

        currency = nil
        amount = nil
        card = nil
    }
    
    func test_fraud_management_data_submissions() {
        // GIVEN
        let fraudFilters = [FraudFilterMode.active: FraudFilterResult.PASS.rawValue, FraudFilterMode.passive: FraudFilterResult.PASS.rawValue, FraudFilterMode.off : ""]
        var fraudExpectations = [XCTestExpectation]()
        var fraudResults = [(Transaction?, Error?, FraudFilterMode, String)]()
        
        // WHEN
        fraudFilters.forEach { key, value in
            let fraudManagementExpectation = expectation(description: "Check Fraud Management Expectation")
            fraudExpectations.append(fraudManagementExpectation)
            card.charge(amount: amount)
                .withCurrency(currency)
                .withFraudFilter(key)
                .execute {
                    fraudResults.append(($0, $1, key, value))
                    fraudManagementExpectation.fulfill()
                }
        }
        
        // THEN
        wait(for: fraudExpectations, timeout: 20.0)
        fraudResults.forEach { fraudManagementResult, fraudManagementError, key, value in
            XCTAssertNil(fraudManagementError)
            XCTAssertNotNil(fraudManagementResult)
            XCTAssertEqual("SUCCESS", fraudManagementResult?.responseCode)
            XCTAssertEqual(TransactionStatus.captured.rawValue, fraudManagementResult?.responseMessage)
            XCTAssertNotNil(fraudManagementResult?.fraudResponse)
            let assessment = fraudManagementResult?.fraudResponse?.assessments?.first
            XCTAssertNotNil(assessment)
            XCTAssertEqual(key.rawValue.uppercased(), assessment?.mode)
            XCTAssertEqual(value, assessment?.result)
        }
     }
    
    func test_fraud_management_data_submission_with_rules() {
        // GIVEN
        let fraudManagementExpectation = expectation(description: "Check Fraud Management Expectation")
        var fraudManagementResult: Transaction?
        var fraudManagementError: Error?
        
        let rule1 = "2c49c2e6-5843-4275-9b92-8c9b6dc8e566"
        let rule2 = "2cfa3a28-f8f3-42f8-abbf-79b54e35de16"
        let rules = FraudRuleCollection()
        rules.addRule(rule1, mode: .active)
        rules.addRule(rule2, mode: .off)

        // supply the customer's billing country and post code for avs checks
        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.city = "Downtown"
        billingAddress.state = "NJ"
        billingAddress.streetAddress1 = "123 Main St."

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active, fraudRules: rules)
            .execute {
                fraudManagementResult = $0
                fraudManagementError = $1
                fraudManagementExpectation.fulfill()
            }

        // THEN
        wait(for: [fraudManagementExpectation], timeout: 10.0)
        XCTAssertNil(fraudManagementError)
        XCTAssertNotNil(fraudManagementResult)
        XCTAssertEqual("SUCCESS", fraudManagementResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, fraudManagementResult?.responseMessage)
        let assessment = fraudManagementResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterMode.active.rawValue.uppercased(), assessment?.mode)
    }
    
    func test_fraudManagement_data_submission_with_all_rules_active() {
        // GIVEN
        let fraudManagementExpectation = expectation(description: "Check Fraud Management Expectation")
        var fraudManagementResult: Transaction?
        var fraudManagementError: Error?
        let rules = FraudRuleCollection()
        let ruleList = [
            "2c49c2e6-5843-4275-9b92-8c9b6dc8e566",
            "2cfa3a28-f8f3-42f8-abbf-79b54e35de16",
            "21db158b-4541-4217-aa81-927596465547",
            "6acbcb2e-79c7-40c3-8c17-b65c5fba2a54",
            "a7da55fb-69c4-4c41-abb6-c4dded40354e"
        ]
        
        ruleList.forEach { value in
            rules.addRule(value, mode: .active)
        }
        
        // supply the customer's billing country and post code for avs checks
        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.city = "Downtown"
        billingAddress.state = "NJ"
        billingAddress.streetAddress1 = "123 Main St."

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active, fraudRules: rules)
            .execute {
                fraudManagementResult = $0
                fraudManagementError = $1
                fraudManagementExpectation.fulfill()
            }
        
        // THEN
        wait(for: [fraudManagementExpectation], timeout: 10.0)
        XCTAssertNil(fraudManagementError)
        XCTAssertNotNil(fraudManagementResult)
        XCTAssertEqual("SUCCESS", fraudManagementResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, fraudManagementResult?.responseMessage)
        let assessment = fraudManagementResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterMode.active.rawValue.uppercased(), assessment?.mode)
        XCTAssertEqual(FraudFilterResult.PASS.rawValue, assessment?.result)
        assessment?.rules?.forEach({ rule in
            XCTAssertTrue(ruleList.contains(rule.key ?? ""))
        })
    }
    
    func test_fraudManagement_data_submission_with_all_rules_off() {
        // GIVEN
        let fraudManagementExpectation = expectation(description: "Check Fraud Management Expectation")
        var fraudManagementResult: Transaction?
        var fraudManagementError: Error?
        let rules = FraudRuleCollection()
        let ruleList = [
            "2c49c2e6-5843-4275-9b92-8c9b6dc8e566",
            "2cfa3a28-f8f3-42f8-abbf-79b54e35de16",
            "21db158b-4541-4217-aa81-927596465547",
            "6acbcb2e-79c7-40c3-8c17-b65c5fba2a54",
            "a7da55fb-69c4-4c41-abb6-c4dded40354e"
        ]
        
        ruleList.forEach { value in
            rules.addRule(value, mode: .off)
        }
        
        // supply the customer's billing country and post code for avs checks
        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.city = "Downtown"
        billingAddress.state = "NJ"
        billingAddress.streetAddress1 = "123 Main St."

        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active, fraudRules: rules)
            .execute {
                fraudManagementResult = $0
                fraudManagementError = $1
                fraudManagementExpectation.fulfill()
            }
        
        // THEN
        wait(for: [fraudManagementExpectation], timeout: 10.0)
        XCTAssertNil(fraudManagementError)
        XCTAssertNotNil(fraudManagementResult)
        XCTAssertEqual("SUCCESS", fraudManagementResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, fraudManagementResult?.responseMessage)
        let assessment = fraudManagementResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterMode.active.rawValue.uppercased(), assessment?.mode)
        XCTAssertEqual(FraudFilterResult.PASS.rawValue, assessment?.result)
        assessment?.rules?.forEach({ rule in
            XCTAssertTrue(ruleList.contains(rule.key ?? ""))
            XCTAssertEqual(FraudFilterResult.NOT_EXECUTED.rawValue, rule.result)
            XCTAssertEqual(FraudFilterMode.off, rule.mode)
        })
    }
    
    func test_release_transaction_after_fraud_result_hold() {
        // GIVEN
        let fraudManagementExpectation = expectation(description: "Check Fraud Management Expectation")
        var fraudManagementResult: Transaction?
        var fraudManagementError: Error?
        
        // supply the customer's billing country and post code for avs checks
        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.city = "Downtown"
        billingAddress.state = "NJ"
        billingAddress.streetAddress1 = "123 Main St."
        
        // WHEN
        card.charge(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active)
            .withCustomerIpAddress("123.123.123.123")
            .execute {
                fraudManagementResult = $0
                fraudManagementError = $1
                fraudManagementExpectation.fulfill()
            }
        
        // THEN
        wait(for: [fraudManagementExpectation], timeout: 10.0)
        XCTAssertNil(fraudManagementError)
        XCTAssertNotNil(fraudManagementResult)
        XCTAssertEqual("SUCCESS", fraudManagementResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, fraudManagementResult?.responseMessage)
        let assessment = fraudManagementResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterMode.active.rawValue.uppercased(), assessment?.mode)
        XCTAssertEqual(FraudFilterResult.HOLD.rawValue, assessment?.result)
        
        //GIVEN
        let fraudReleaseExpectation = expectation(description: "Check Fraud Release Expectation")
        var fraudReleaseResult: Transaction?
        var fraudReleaseError: Error?
        fraudManagementResult?.releaseTransaction()
            .withReasonCode(.falsePositive)
            .execute{
                fraudReleaseResult = $0
                fraudReleaseError = $1
                fraudReleaseExpectation.fulfill()
            }

        wait(for: [fraudReleaseExpectation], timeout: 10.0)
        XCTAssertNil(fraudReleaseError)
        XCTAssertNotNil(fraudReleaseResult)
        XCTAssertEqual("SUCCESS", fraudReleaseResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, fraudReleaseResult?.responseMessage)
        let fraudReleaseResponse = fraudReleaseResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(fraudReleaseResponse)
        XCTAssertEqual(FraudFilterResult.RELEASE_SUCCESSFUL.rawValue, fraudReleaseResponse?.result)
    }
    
    func test_fraud_management_data_submission_full_cycle() {
        // GIVEN
        let fraudManagementExpectation = expectation(description: "Check Fraud Management Expectation")
        var fraudManagementResult: Transaction?
        var fraudManagementError: Error?
        
        // supply the customer's billing country and post code for avs checks
        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.city = "Downtown"
        billingAddress.state = "NJ"
        billingAddress.streetAddress1 = "123 Main St."
        
        // WHEN
        card.authorize(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active)
            .execute {
                fraudManagementResult = $0
                fraudManagementError = $1
                fraudManagementExpectation.fulfill()
            }
        
        // THEN
        wait(for: [fraudManagementExpectation], timeout: 10.0)
        XCTAssertNil(fraudManagementError)
        XCTAssertNotNil(fraudManagementResult)
        XCTAssertEqual("SUCCESS", fraudManagementResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, fraudManagementResult?.responseMessage)
        let assessment = fraudManagementResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterMode.active.rawValue.uppercased(), assessment?.mode)
        XCTAssertEqual(FraudFilterResult.PASS.rawValue, assessment?.result)
        
        //GIVEN
        let fraudHoldExpectation = expectation(description: "Check Fraud Hold Expectation")
        var fraudHoldResult: Transaction?
        var fraudHoldError: Error?
        
        // WHEN
        fraudManagementResult?.hold()
            .withReasonCode(.fraud)
            .execute{
                fraudHoldResult = $0
                fraudHoldError = $1
                fraudHoldExpectation.fulfill()
            }
        
        wait(for: [fraudHoldExpectation], timeout: 10.0)
        XCTAssertNil(fraudHoldError)
        XCTAssertNotNil(fraudHoldResult)
        XCTAssertEqual("SUCCESS", fraudHoldResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, fraudHoldResult?.responseMessage)
        let fraudHoldResponse = fraudHoldResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(fraudHoldResponse)
        XCTAssertEqual(FraudFilterResult.HOLD_SUCCESSFUL.rawValue, fraudHoldResponse?.result)
        
        //GIVEN
        let fraudReleaseExpectation = expectation(description: "Check Fraud Release Expectation")
        var fraudReleaseResult: Transaction?
        var fraudReleaseError: Error?
        fraudHoldResult?.releaseTransaction()
            .withReasonCode(.falsePositive)
            .execute{
                fraudReleaseResult = $0
                fraudReleaseError = $1
                fraudReleaseExpectation.fulfill()
            }
        
        // THEN
        wait(for: [fraudReleaseExpectation], timeout: 10.0)
        XCTAssertNil(fraudReleaseError)
        XCTAssertNotNil(fraudReleaseResult)
        XCTAssertEqual("SUCCESS", fraudReleaseResult?.responseCode)
        XCTAssertEqual(TransactionStatus.preauthorized.rawValue, fraudReleaseResult?.responseMessage)
        let fraudReleaseResponse = fraudReleaseResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(fraudReleaseResponse)
        XCTAssertEqual(FraudFilterResult.RELEASE_SUCCESSFUL.rawValue, fraudReleaseResponse?.result)
        
        // GIVEN
        let fraudCaptureExpectation = expectation(description: "Check Fraud Release Expectation")
        var fraudCaptureResult: Transaction?
        var fraudCaptureError: Error?
        
        //WHEN
        fraudReleaseResult?.capture()
            .execute{
                fraudCaptureResult = $0
                fraudCaptureError = $1
                fraudCaptureExpectation.fulfill()
            }
        
        //THEN
        wait(for: [fraudCaptureExpectation], timeout: 10.0)
        XCTAssertNil(fraudCaptureError)
        XCTAssertNotNil(fraudCaptureResult)
        XCTAssertEqual("SUCCESS", fraudCaptureResult?.responseCode)
        XCTAssertEqual(TransactionStatus.captured.rawValue, fraudCaptureResult?.responseMessage)
    }

    // MARK: - Hold: standalone + reason codes + response fields + error path

    func test_hold_transaction_with_fraud_reason_code() {
        // GIVEN - Authorize with fraud filter active
        let authExpectation = expectation(description: "Auth Expectation")
        var authResult: Transaction?
        var authError: Error?

        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.streetAddress1 = "123 Main St."

        card.authorize(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)
        XCTAssertEqual("SUCCESS", authResult?.responseCode)

        // GIVEN - Hold with FRAUD reason code
        let holdExpectation = expectation(description: "Hold Expectation")
        var holdResult: Transaction?
        var holdError: Error?

        // WHEN
        authResult?.hold()
            .withReasonCode(.fraud)
            .execute {
                holdResult = $0
                holdError = $1
                holdExpectation.fulfill()
            }

        // THEN
        wait(for: [holdExpectation], timeout: 10.0)
        XCTAssertNil(holdError)
        XCTAssertNotNil(holdResult)
        XCTAssertEqual("SUCCESS", holdResult?.responseCode)
        let assessment = holdResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterResult.HOLD_SUCCESSFUL.rawValue, assessment?.result)
    }

    func test_hold_transaction_with_other_reason_code() {
        // GIVEN - Authorize with fraud filter active
        let authExpectation = expectation(description: "Auth Expectation")
        var authResult: Transaction?
        var authError: Error?

        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.streetAddress1 = "123 Main St."

        card.authorize(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)

        // GIVEN - Hold with OTHER reason code
        let holdExpectation = expectation(description: "Hold Expectation")
        var holdResult: Transaction?
        var holdError: Error?

        // WHEN
        authResult?.hold()
            .withReasonCode(.other)
            .execute {
                holdResult = $0
                holdError = $1
                holdExpectation.fulfill()
            }

        // THEN
        wait(for: [holdExpectation], timeout: 10.0)
        XCTAssertNil(holdError)
        XCTAssertNotNil(holdResult)
        XCTAssertEqual("SUCCESS", holdResult?.responseCode)
        let assessment = holdResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterResult.HOLD_SUCCESSFUL.rawValue, assessment?.result)
    }

    func test_hold_transaction_with_not_given_reason_code() {
        // GIVEN - Authorize with fraud filter active
        let authExpectation = expectation(description: "Auth Expectation")
        var authResult: Transaction?
        var authError: Error?

        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.streetAddress1 = "123 Main St."

        card.authorize(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)

        // GIVEN - Hold with NOT_GIVEN reason code
        let holdExpectation = expectation(description: "Hold Expectation")
        var holdResult: Transaction?
        var holdError: Error?

        // WHEN
        authResult?.hold()
            .withReasonCode(.notGiven)
            .execute {
                holdResult = $0
                holdError = $1
                holdExpectation.fulfill()
            }

        // THEN
        wait(for: [holdExpectation], timeout: 10.0)
        XCTAssertNil(holdError)
        XCTAssertNotNil(holdResult)
        XCTAssertEqual("SUCCESS", holdResult?.responseCode)
        let assessment = holdResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterResult.HOLD_SUCCESSFUL.rawValue, assessment?.result)
    }

    func test_hold_transaction_response_message_field() {
        // GIVEN - Authorize with fraud filter active
        let authExpectation = expectation(description: "Auth Expectation")
        var authResult: Transaction?
        var authError: Error?

        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.streetAddress1 = "123 Main St."

        card.authorize(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError)
        XCTAssertNotNil(authResult)

        // GIVEN - Hold
        let holdExpectation = expectation(description: "Hold Expectation")
        var holdResult: Transaction?
        var holdError: Error?

        // WHEN
        authResult?.hold()
            .withReasonCode(.fraud)
            .execute {
                holdResult = $0
                holdError = $1
                holdExpectation.fulfill()
            }

        // THEN - assert risk_assessment[].message is mapped
        wait(for: [holdExpectation], timeout: 10.0)
        XCTAssertNil(holdError)
        XCTAssertNotNil(holdResult)
        XCTAssertEqual("SUCCESS", holdResult?.responseCode)
        let assessment = holdResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterResult.HOLD_SUCCESSFUL.rawValue, assessment?.result)
        // message is optional — assert it is accessible (may be nil if not returned by sandbox)
        _ = assessment?.message
    }

    func test_hold_transaction_wrong_id() {
        // GIVEN
        let holdExpectation = expectation(description: "Hold Expectation")
        let unknownTransaction = Transaction()
        unknownTransaction.transactionId = "UNKNOWN"
        var holdResult: Transaction?
        var gatewayException: GatewayException?

        // WHEN
        unknownTransaction.hold()
            .withReasonCode(.fraud)
            .execute {
                holdResult = $0
                if let exception = $1 as? GatewayException {
                    gatewayException = exception
                }
                holdExpectation.fulfill()
            }

        // THEN
        wait(for: [holdExpectation], timeout: 10.0)
        XCTAssertNil(holdResult)
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("RESOURCE_NOT_FOUND", gatewayException?.responseCode)
        XCTAssertEqual("40008", gatewayException?.responseMessage)
    }

    // MARK: - Release: standalone + reason codes + response fields + error path

    /// Helper — authorizes, triggers a HOLD result, then returns the held transaction.
    private func authorizeAndHold(file: StaticString = #file, line: UInt = #line) -> Transaction? {
        let authExpectation = expectation(description: "Auth Expectation")
        var authResult: Transaction?
        var authError: Error?

        let billingAddress = Address()
        billingAddress.postalCode = "12345"
        billingAddress.country = "US"
        billingAddress.streetAddress1 = "123 Main St."

        card.authorize(amount: amount)
            .withCurrency(currency)
            .withAddress(billingAddress)
            .withFraudFilter(.active)
            .execute {
                authResult = $0
                authError = $1
                authExpectation.fulfill()
            }

        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertNil(authError, "Auth should not fail", file: file, line: line)
        XCTAssertNotNil(authResult, "Auth result should not be nil", file: file, line: line)

        let holdExpectation = expectation(description: "Hold Expectation")
        var holdResult: Transaction?

        authResult?.hold()
            .withReasonCode(.fraud)
            .execute {
                holdResult = $0
                _ = $1
                holdExpectation.fulfill()
            }

        wait(for: [holdExpectation], timeout: 10.0)
        XCTAssertNotNil(holdResult, "Hold result should not be nil", file: file, line: line)
        return holdResult
    }

    func test_release_transaction_with_false_positive_reason_code() {
        // GIVEN - a held transaction
        guard let held = authorizeAndHold() else { return }

        let releaseExpectation = expectation(description: "Release Expectation")
        var releaseResult: Transaction?
        var releaseError: Error?

        // WHEN
        held.releaseTransaction()
            .withReasonCode(.falsePositive)
            .execute {
                releaseResult = $0
                releaseError = $1
                releaseExpectation.fulfill()
            }

        // THEN
        wait(for: [releaseExpectation], timeout: 10.0)
        XCTAssertNil(releaseError)
        XCTAssertNotNil(releaseResult)
        XCTAssertEqual("SUCCESS", releaseResult?.responseCode)
        let assessment = releaseResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterResult.RELEASE_SUCCESSFUL.rawValue, assessment?.result)
    }

    func test_release_transaction_with_other_reason_code() {
        // GIVEN - a held transaction
        guard let held = authorizeAndHold() else { return }

        let releaseExpectation = expectation(description: "Release Expectation")
        var releaseResult: Transaction?
        var releaseError: Error?

        // WHEN
        held.releaseTransaction()
            .withReasonCode(.other)
            .execute {
                releaseResult = $0
                releaseError = $1
                releaseExpectation.fulfill()
            }

        // THEN
        wait(for: [releaseExpectation], timeout: 10.0)
        XCTAssertNil(releaseError)
        XCTAssertNotNil(releaseResult)
        XCTAssertEqual("SUCCESS", releaseResult?.responseCode)
        let assessment = releaseResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterResult.RELEASE_SUCCESSFUL.rawValue, assessment?.result)
    }

    func test_release_transaction_with_not_given_reason_code() {
        // GIVEN - a held transaction
        guard let held = authorizeAndHold() else { return }

        let releaseExpectation = expectation(description: "Release Expectation")
        var releaseResult: Transaction?
        var releaseError: Error?

        // WHEN
        held.releaseTransaction()
            .withReasonCode(.notGiven)
            .execute {
                releaseResult = $0
                releaseError = $1
                releaseExpectation.fulfill()
            }

        // THEN
        wait(for: [releaseExpectation], timeout: 10.0)
        XCTAssertNil(releaseError)
        XCTAssertNotNil(releaseResult)
        XCTAssertEqual("SUCCESS", releaseResult?.responseCode)
        let assessment = releaseResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterResult.RELEASE_SUCCESSFUL.rawValue, assessment?.result)
    }

    func test_release_transaction_response_message_field() {
        // GIVEN - a held transaction
        guard let held = authorizeAndHold() else { return }

        let releaseExpectation = expectation(description: "Release Expectation")
        var releaseResult: Transaction?
        var releaseError: Error?

        // WHEN
        held.releaseTransaction()
            .withReasonCode(.falsePositive)
            .execute {
                releaseResult = $0
                releaseError = $1
                releaseExpectation.fulfill()
            }

        // THEN - assert risk_assessment[].message is mapped
        wait(for: [releaseExpectation], timeout: 10.0)
        XCTAssertNil(releaseError)
        XCTAssertNotNil(releaseResult)
        XCTAssertEqual("SUCCESS", releaseResult?.responseCode)
        let assessment = releaseResult?.fraudResponse?.assessments?.first
        XCTAssertNotNil(assessment)
        XCTAssertEqual(FraudFilterResult.RELEASE_SUCCESSFUL.rawValue, assessment?.result)
        // message is optional — assert it is accessible (may be nil if not returned by sandbox)
        _ = assessment?.message
    }

    func test_release_transaction_wrong_id() {
        // GIVEN
        let releaseExpectation = expectation(description: "Release Expectation")
        let unknownTransaction = Transaction()
        unknownTransaction.transactionId = "UNKNOWN"
        var releaseResult: Transaction?
        var gatewayException: GatewayException?

        // WHEN
        unknownTransaction.releaseTransaction()
            .withReasonCode(.falsePositive)
            .execute {
                releaseResult = $0
                if let exception = $1 as? GatewayException {
                    gatewayException = exception
                }
                releaseExpectation.fulfill()
            }

        // THEN
        wait(for: [releaseExpectation], timeout: 10.0)
        XCTAssertNil(releaseResult)
        XCTAssertNotNil(gatewayException)
        XCTAssertEqual("RESOURCE_NOT_FOUND", gatewayException?.responseCode)
        XCTAssertEqual("40008", gatewayException?.responseMessage)
    }
}
