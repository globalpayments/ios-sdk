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
            appId: "Q18DcsJvh8TtRo9zxICvg9S78S3RN8u2",
            appKey: "CFaMNPgpPN4KXibu",
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
        wait(for: fraudExpectations, timeout: 10.0)
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
        XCTAssertEqual(FraudFilterResult.NOT_EXECUTED.rawValue, assessment?.result)
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
        XCTAssertEqual(FraudFilterResult.RELEASE_SUCCESSFULL.rawValue, fraudReleaseResponse?.result)
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
        XCTAssertEqual(FraudFilterResult.HOLD_SUCCESSFULL.rawValue, fraudHoldResponse?.result)
        
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
        XCTAssertEqual(FraudFilterResult.RELEASE_SUCCESSFULL.rawValue, fraudReleaseResponse?.result)
        
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
}
