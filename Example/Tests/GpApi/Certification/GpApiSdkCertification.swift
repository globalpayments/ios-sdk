import XCTest
import GlobalPayments_iOS_SDK

class GpApiSdkCertification: XCTestCase {

    // MARK: - Credit Card SUCCESS

    func test_credit_card_visa_success() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "John Doe"

        let chargeExpectation = expectation(description: "test credit card visa success expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 14.99)
            .withCurrency("GBP")
            .withDescription("test_credit_card_visa_success")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "VISA", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "00")
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_card_mastercard_success() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "5425230000004415"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "John Smith"

        let chargeExpectation = expectation(description: "test credit card mastercard success expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 4.95)
            .withCurrency("GBP")
            .withDescription("test_credit_card_mastercard_success")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "MASTERCARD", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "00")
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_card_american_express_success() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "374101000000608"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "1234"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Susan Jones"

        let chargeExpectation = expectation(description: "test credit card american express success expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 17.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_american_express_success")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "AMEX", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "00")
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_card_diners_club_success() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "36256000000725"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "789"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Green"

        let chargeExpectation = expectation(description: "test credit card diners club success expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 5.15)
            .withCurrency("GBP")
            .withDescription("test_credit_card_diners_club_success")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "DINERS", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "00")
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_card_discover_success() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "6011000000000087"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "456"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Green"

        let chargeExpectation = expectation(description: "test credit card discover success expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 2.14)
            .withCurrency("GBP")
            .withDescription("test_credit_card_discover_success")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "DISCOVER", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "00")
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    func test_credit_card_jcb_success() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "3566000000000000"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "223"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Dalas"

        let chargeExpectation = expectation(description: "test credit card jcb success expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 1.99)
            .withCurrency("GBP")
            .withDescription("test_credit_card_jcb_success")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "JCB", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "00")
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.captured.mapped(for: .gpApi))
    }

    // MARK: - Credit Card Visa DECLINED

    func test_credit_card_visa_declined_101() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "4000120000001154"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "John Doe"

        let chargeExpectation = expectation(description: "test credit card visa declined 101 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 10.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_visa_declined_101")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "VISA", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "101")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_visa_declined_102() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "4000130000001724"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Smith"

        let chargeExpectation = expectation(description: "test credit card visa declined 102 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 3.75)
            .withCurrency("GBP")
            .withDescription("test_credit_card_visa_declined_102")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "VISA", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "102")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_visa_declined_103() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "4000160000004147"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Bob Smith"

        let chargeExpectation = expectation(description: "test credit card visa declined 103 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 5.35)
            .withCurrency("GBP")
            .withDescription("test_credit_card_visa_declined_103")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "VISA", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "103")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    // MARK: - Credit Card Mastercard DECLINED

    func test_credit_card_mastercard_declined_101() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "5114610000004778"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Bob Howard"

        let chargeExpectation = expectation(description: "test credit card mastercard declined 101 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 3.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_mastercard_declined_101")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "MASTERCARD", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "101")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_mastercard_declined_102() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "5114630000009791"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Tom Grey"

        let chargeExpectation = expectation(description: "test credit card mastercard declined 102 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 3.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_mastercard_declined_102")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "MASTERCARD", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "102")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_mastercard_declined_103() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "5121220000006921"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvnPresenceIndicator = .illegible
        card.cardHolderName = "Marie Curie"

        let chargeExpectation = expectation(description: "test credit card mastercard declined 103 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 3.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_mastercard_declined_103")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "MASTERCARD", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "103")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    // MARK: - Credit Card American Express DECLINED

    func test_credit_card_american_express_declined_101() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "376525000000010"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "1234"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "John Doe"

        let chargeExpectation = expectation(description: "test credit card american express declined 101 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 7.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_american_express_declined_101")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "AMEX", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "101")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_american_express_declined_102() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "375425000000907"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "1234"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Smith"

        let chargeExpectation = expectation(description: "test credit card american express declined 102 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 9.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_american_express_declined_102")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "AMEX", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "102")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_american_express_declined_103() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "343452000000306"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "1234"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Bob Smith"

        let chargeExpectation = expectation(description: "test credit card american express declined 103 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 1.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_american_express_declined_103")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "AMEX", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "103")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    // MARK: - Credit Card Diners Club DECLINED

    func test_credit_card_diners_club_declined_101() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "36256000000998"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "John Smith"

        let chargeExpectation = expectation(description: "test credit card diners club declined 101 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 1.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_diners_club_declined_101")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "DINERS", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "101")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_diners_club_declined_102() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "36256000000634"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "John Smith"

        let chargeExpectation = expectation(description: "test credit card diners club declined 102 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 2.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_diners_club_declined_102")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "DINERS", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "102")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_diners_club_declined_103() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "38865000000705"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "John Smith"

        let chargeExpectation = expectation(description: "test credit card diners club declined 103 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 3.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_diners_club_declined_103")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "DINERS", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "103")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    // MARK: - Credit Card Discover DECLINED

    func test_credit_card_discover_declined_101() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "6011000000001010"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Rob Brown"

        let chargeExpectation = expectation(description: "test credit card discover declined 101 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 1.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_discover_declined_101")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "DISCOVER", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "101")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_discover_declined_102() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "6011000000001028"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Rob Brown"

        let chargeExpectation = expectation(description: "test credit card discover declined 102 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 2.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_discover_declined_102")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "DISCOVER", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "102")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_discover_declined_103() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "6011000000001036"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Rob Brown"

        let chargeExpectation = expectation(description: "test credit card discover declined 103 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 3.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_discover_declined_103")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "DISCOVER", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "103")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    // MARK: - Credit Card JCB DECLINED

    func test_credit_card_jcb_declined_101() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "3566000000001016"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Michael Smith"

        let chargeExpectation = expectation(description: "test credit card jcb declined 101 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 1.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_jcb_declined_101")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "JCB", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "101")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_jcb_declined_102() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "3566000000001024"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Michael Smith"

        let chargeExpectation = expectation(description: "test credit card jcb declined 102 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 2.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_jcb_declined_102")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "JCB", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "102")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    func test_credit_card_jcb_declined_103() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "3566000000001032"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Michael Smith"

        let chargeExpectation = expectation(description: "test credit card jcb declined 103 expectation")
        var transactionResponse: Transaction?
        var errorResponse: Error?

        // WHEN
        card.charge(amount: 3.25)
            .withCurrency("GBP")
            .withDescription("test_credit_card_jcb_declined_103")
            .execute {
                transactionResponse = $0
                errorResponse = $1
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(errorResponse)
        XCTAssertNotNil(transactionResponse)
        XCTAssertEqual(transactionResponse?.cardType, "JCB", "Card brand match")
        XCTAssertEqual(transactionResponse?.authorizationCode, "103")
        XCTAssertEqual(transactionResponse?.responseCode, "DECLINED")
        XCTAssertEqual(transactionResponse?.responseMessage, TransactionStatus.declined.mapped(for: .gpApi))
    }

    // MARK: - Credit Card Visa ERROR

    func test_credit_card_visa_processing_error() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "4009830000001985"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Spencer"

        let chargeExpectation = expectation(description: "test credit card_visa processing error expectation")
        var transactionResponse: Transaction?
        var errorResponse: GatewayException?

        // WHEN
        card.charge(amount: 3.99)
            .withCurrency("GBP")
            .withDescription("test_credit_card_visa_processing_error")
            .execute {
                transactionResponse = $0
                if let gatewayException = $1 as? GatewayException {
                    errorResponse = gatewayException
                }
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(errorResponse)
        XCTAssertEqual(errorResponse?.responseMessage, "50013")
        XCTAssertEqual(errorResponse?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
    }

    func test_credit_card_visa_processing_error_wrong_currency() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "4009830000001985"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Spencer"

        let chargeExpectation = expectation(description: "test credit card visa processing error wrong currency expectation")
        var transactionResponse: Transaction?
        var errorResponse: GatewayException?

        // WHEN
        card.charge(amount: 3.99)
            .withCurrency("XXX")
            .withDescription("test_credit_card_visa_processing_error_wrong_currency")
            .execute {
                transactionResponse = $0
                if let gatewayException = $1 as? GatewayException {
                    errorResponse = gatewayException
                }
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(errorResponse)
        XCTAssertEqual(errorResponse?.responseMessage, "50024")
        XCTAssertEqual(errorResponse?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
    }

    // MARK: - Credit Card Mastercard ERROR

    func test_credit_card_mastercard_processing_error() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "5135020000005871"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Tom Brown"

        let chargeExpectation = expectation(description: "test credit card mastercard processing error expectation")
        var transactionResponse: Transaction?
        var errorResponse: GatewayException?

        // WHEN
        card.charge(amount: 2.16)
            .withCurrency("GBP")
            .withDescription("test_credit_card_mastercard_processing_error")
            .execute {
                transactionResponse = $0
                if let gatewayException = $1 as? GatewayException {
                    errorResponse = gatewayException
                }
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(errorResponse)
        XCTAssertEqual(errorResponse?.responseMessage, "50013")
        XCTAssertEqual(errorResponse?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
    }

    // MARK: - Credit Card American Express ERROR

    func test_credit_card_american_express_processing_error() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "372349000000852"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "1234"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Tina White"

        let chargeExpectation = expectation(description: "test credit card mastercard processing error expectation")
        var transactionResponse: Transaction?
        var errorResponse: GatewayException?

        // WHEN
        card.charge(amount: 4.02)
            .withCurrency("GBP")
            .withDescription("test_credit_card_american_express_processing_error")
            .execute {
                transactionResponse = $0
                if let gatewayException = $1 as? GatewayException {
                    errorResponse = gatewayException
                }
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(errorResponse)
        XCTAssertEqual(errorResponse?.responseMessage, "50013")
        XCTAssertEqual(errorResponse?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
    }

    // MARK: - Credit Card Diners Club ERROR

    func test_credit_card_diners_club_processing_error() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "30450000000985"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Ashley Brown"

        let chargeExpectation = expectation(description: "test credit card diners club processing error expectation")
        var transactionResponse: Transaction?
        var errorResponse: GatewayException?

        // WHEN
        card.charge(amount: 5.99)
            .withCurrency("GBP")
            .withDescription("test_credit_card_diners_club_processing_error")
            .execute {
                transactionResponse = $0
                if let gatewayException = $1 as? GatewayException {
                    errorResponse = gatewayException
                }
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(errorResponse)
        XCTAssertEqual(errorResponse?.responseMessage, "50013")
        XCTAssertEqual(errorResponse?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
    }

    // MARK: - Credit Card Discover ERROR

    func test_credit_card_discover_processing_error() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "6011000000002000"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Spencer"

        let chargeExpectation = expectation(description: "test credit card discover processing error expectation")
        var transactionResponse: Transaction?
        var errorResponse: GatewayException?

        // WHEN
        card.charge(amount: 8.99)
            .withCurrency("GBP")
            .withDescription("test_credit_card_discover_processing_error")
            .execute {
                transactionResponse = $0
                if let gatewayException = $1 as? GatewayException {
                    errorResponse = gatewayException
                }
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(errorResponse)
        XCTAssertEqual(errorResponse?.responseMessage, "50013")
        XCTAssertEqual(errorResponse?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
    }

    // MARK: - Credit Card JCB ERROR

    func test_credit_card_jcb_processing_error() {
        // GIVEN
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            channel: .cardNotPresent,
            country: "GB"
        ))

        let card = CreditCardData()
        card.number = "3566000000002006"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cvnPresenceIndicator = .present
        card.cardHolderName = "Mark Spencer"

        let chargeExpectation = expectation(description: "test credit card jcb processing error expectation")
        var transactionResponse: Transaction?
        var errorResponse: GatewayException?

        // WHEN
        card.charge(amount: 4.99)
            .withCurrency("GBP")
            .withDescription("test_credit_card_jcb_processing_error")
            .execute {
                transactionResponse = $0
                if let gatewayException = $1 as? GatewayException {
                    errorResponse = gatewayException
                }
                chargeExpectation.fulfill()
            }

        // THEN
        wait(for: [chargeExpectation], timeout: 10)
        XCTAssertNil(transactionResponse)
        XCTAssertNotNil(errorResponse)
        XCTAssertEqual(errorResponse?.responseMessage, "50013")
        XCTAssertEqual(errorResponse?.responseCode, "SYSTEM_ERROR_DOWNSTREAM")
    }
}
