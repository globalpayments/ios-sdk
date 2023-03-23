import XCTest
import GlobalPayments_iOS_SDK

final class GpApiMerchantsOnboardTest: XCTestCase {
    
    private var card: CreditCardData!
    
    override class func setUp() {
        super.setUp()
        
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "A1feRdMmEB6m0Y1aQ65H0bDi9ZeAEB2t",
            appKey: "5jPt1OpB6LLitgi7",
            channel: .cardNotPresent
        ))
    }
    
    override func setUp() {
        super.setUp()
        
        card = CreditCardData()
        card.number = "4263970000005262"
        card.expMonth = Date().currentMonth
        card.expYear = Date().currentYear + 1
        card.cvn = "123"
        card.cardPresent = true
    }
    
    public func test_board_merchant() {
        // GIVEN
        let merchantExpectation = expectation(description: "Merchant Expectation")
        let merchantData = getMerchantData()
        let productData = getProductList()
        let persons = getPersonList()
        let creditCardInformation = card
        let bankAccountInformation = getBankAccountData()
        let paymentStatistics = getPaymentStatistics()
        var merchantResponse: User?
        var merchantError: Error?
        
        // WHEN
        PayFacService.createMerchant()
            .withUserPersonalData(merchantData)
            .withDescription("Merchant Business Description")
            .withProductData(productData)
            .withCreditCardData(creditCardInformation, paymentMethodFunction: .primaryPayout)
            .withBankAccountData(bankAccountInformation, paymentMethodFunction: .secondaryPayout)
            .withPersonsData(persons)
            .withPaymentStatistics(paymentStatistics)
            .execute {
                merchantResponse = $0
                merchantError = $1
                merchantExpectation.fulfill()
            }
        
        // THEN
        wait(for: [merchantExpectation], timeout: 10.0)
        XCTAssertNil(merchantError)
        XCTAssertNotNil(merchantResponse)
        XCTAssertEqual("SUCCESS", merchantResponse?.responseCode)
        XCTAssertEqual(UserStatus.UNDER_REVIEW, merchantResponse?.userReference?.userStatus)
        XCTAssertNotNil(merchantResponse?.userReference?.userId)
    }
    
    func test_board_merchant_only_mandatory() {
        // GIVEN
        let merchantExpectation = expectation(description: "Merchant Only Mandatory Expectation")
        let merchantData = getMerchantData()
        let productData = getProductList()
        let persons = getPersonList()
        let paymentStatistics = getPaymentStatistics()
        var merchantResponse: User?
        var merchantError: Error?
        
        // WHEN
        PayFacService.createMerchant()
            .withUserPersonalData(merchantData)
            .withDescription("Merchant Business Description")
            .withProductData(productData)
            .withPersonsData(persons)
            .withPaymentStatistics(paymentStatistics)
            .execute {
                merchantResponse = $0
                merchantError = $1
                merchantExpectation.fulfill()
            }
        
        // THEN
        wait(for: [merchantExpectation], timeout: 5.0)
        XCTAssertNil(merchantError)
        XCTAssertNotNil(merchantResponse)
        XCTAssertEqual("SUCCESS", merchantResponse?.responseCode)
        XCTAssertEqual(UserStatus.UNDER_REVIEW, merchantResponse?.userReference?.userStatus)
        XCTAssertEqual(merchantData.userName, merchantResponse?.name)
        XCTAssertEqual("Merchant Boarding in progress", merchantResponse?.statusDescription)
        XCTAssertNotNil(merchantResponse?.userReference?.userId)
    }
    
    func test_board_merchant_with_idempotency() {
        // GIVEN
        let merchantExpectation = expectation(description: "Merchant Idempotency Expectation")
        let idempotencyKey = UUID().uuidString
        let merchantData = getMerchantData()
        let productData = getProductList()
        let persons = getPersonList()
        let paymentStatistics = getPaymentStatistics()
        var merchantResponse: User?
        var merchantError: Error?
        
        // WHEN
        PayFacService.createMerchant()
            .withUserPersonalData(merchantData)
            .withDescription("Merchant Business Description")
            .withProductData(productData)
            .withPersonsData(persons)
            .withPaymentStatistics(paymentStatistics)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                merchantResponse = $0
                merchantError = $1
                merchantExpectation.fulfill()
            }
        
        // THEN
        wait(for: [merchantExpectation], timeout: 5.0)
        XCTAssertNil(merchantError)
        XCTAssertNotNil(merchantResponse)
        XCTAssertEqual("SUCCESS", merchantResponse?.responseCode)
        XCTAssertEqual(UserStatus.UNDER_REVIEW, merchantResponse?.userReference?.userStatus)
        XCTAssertNotNil(merchantResponse?.userReference?.userId)
        
        // GIVEN
        let merchantDuplicatedExpectation = expectation(description: "Merchant Duplicated Expectation")
        var merchantGatewayError: GatewayException?
        var merchantIdempotencyResponse: User?
        
        // WHEN
        PayFacService.createMerchant()
            .withUserPersonalData(merchantData)
            .withDescription("Merchant Business Description")
            .withProductData(productData)
            .withPersonsData(persons)
            .withPaymentStatistics(paymentStatistics)
            .withIdempotencyKey(idempotencyKey)
            .execute {
                merchantIdempotencyResponse = $0
                if let error = $1 as? GatewayException {
                    merchantGatewayError = error
                }
                merchantDuplicatedExpectation.fulfill()
            }
        
        // THEN
        wait(for: [merchantDuplicatedExpectation], timeout: 5.0)
        XCTAssertNil(merchantIdempotencyResponse)
        XCTAssertNotNil(merchantGatewayError)
        XCTAssertEqual("DUPLICATE_ACTION", merchantGatewayError?.responseCode)
        XCTAssertEqual("40039", merchantGatewayError?.responseMessage)
        XCTAssertEqual(merchantGatewayError?.message, "Status Code: 409 - Idempotency Key seen before: id=\(merchantResponse?.userReference?.userId ?? ""), status=\(merchantResponse?.userReference?.userStatus?.rawValue ?? "")")
    }
    
    public func test_get_merchant_info() {
        // GIVEN
        let merchantExpectation = expectation(description: "Merchant Expectation")
        let merchantId = "MER_98f60f1a397c4dd7b7167bda61520292"
        var merchantResponse: User?
        var merchantError: Error?
        
        // WHEN
        PayFacService.getMerchantInfo(merchantId)
            .execute {
                merchantResponse = $0
                merchantError = $1
                merchantExpectation.fulfill()
            }
        
        // THEN
        wait(for: [merchantExpectation], timeout: 5.0)
        XCTAssertNil(merchantError)
        XCTAssertNotNil(merchantResponse)
        XCTAssertEqual(merchantId, merchantResponse?.userReference?.userId)
    }
    
    public func test_get_merchant_info_random_id() {
        // GIVEN
        let merchantExpectation = expectation(description: "Merchant Expectation")
        let merchantId = "MER_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        var merchantResponse: User?
        var merchantError: GatewayException?
        
        // WHEN
        PayFacService.getMerchantInfo(merchantId)
            .execute {
                merchantResponse = $0
                if let error = $1 as? GatewayException {
                    merchantError = error
                }
                merchantExpectation.fulfill()
            }
        
        // THEN
        wait(for: [merchantExpectation], timeout: 5.0)
        XCTAssertNil(merchantResponse)
        XCTAssertNotNil(merchantError)
        XCTAssertEqual("INVALID_REQUEST_DATA", merchantError?.responseCode)
        XCTAssertEqual("40041", merchantError?.responseMessage)
        XCTAssertEqual("Status Code: 400 - Merchant configuration does not exist for the following combination: MMA_1595ca59906346beae43d92c24863430 , \(merchantId)", merchantError?.message)
    }
    
    public func test_search_merchants() {
        // GIVEN
        let expectationSearch = expectation(description: "Search Merchant Expectation")
        let userReportService = ReportingService.findMerchants(1, pageSize: 10)
        var merchantSummaryResult: PagedResult<MerchantSummary>?
        var merchantSummaryError: Error?
        
        // WHEN
        userReportService.execute {
            merchantSummaryResult = $0
            merchantSummaryError = $1
            expectationSearch.fulfill()
        }
        
        // THEN
        wait(for: [expectationSearch], timeout: 5.0)
        XCTAssertNil(merchantSummaryError)
        XCTAssertNotNil(merchantSummaryResult)
        XCTAssertTrue(merchantSummaryResult?.totalRecordCount ?? 0 > 0)
        XCTAssertTrue(merchantSummaryResult?.results.count ?? 0 <= 10)
    }
    
    public func test_edit_merchant_applicant_info() {
        // GIVEN
        let expectationSearch = expectation(description: "Search Merchant Expectation")
        let userReportService = ReportingService.findMerchants(1, pageSize: 1)
        var merchantSummaryResult: PagedResult<MerchantSummary>?
        var merchantSummaryError: Error?
        
        // WHEN
        userReportService.execute {
            merchantSummaryResult = $0
            merchantSummaryError = $1
            expectationSearch.fulfill()
        }
        
        // THEN
        wait(for: [expectationSearch], timeout: 5.0)
        XCTAssertNil(merchantSummaryError)
        XCTAssertNotNil(merchantSummaryResult)
        XCTAssertTrue(merchantSummaryResult?.totalRecordCount ?? 0 > 0)
        XCTAssertTrue(merchantSummaryResult?.results.count ?? 0 == 1)
        
        // GIVEN
        let userExpectation = expectation(description: "User Expectation")
        let merchant = User.fromId(from: merchantSummaryResult?.results.first?.id ?? "", userType: .merchant)
        let persons = getPersonList("Update")
        var userResponse: User?
        var userError: Error?
        
        // WHEN
        merchant.edit()
            .withPersonsData(persons)
            .withDescription("Update merchant applicant info")
            .execute {
                userResponse = $0
                userError = $1
                userExpectation.fulfill()
            }
        
        // THEN
        wait(for: [userExpectation], timeout: 5.0)
        XCTAssertNil(userError)
        XCTAssertNotNil(userResponse)
        XCTAssertEqual("PENDING", userResponse?.responseCode)
    }
    
    public func test_edit_merchant_payment_processing() {
        // GIVEN
        let expectationSearch = expectation(description: "Search Merchant Expectation")
        let userReportService = ReportingService.findMerchants(1, pageSize: 1)
        var merchantSummaryResult: PagedResult<MerchantSummary>?
        var merchantSummaryError: Error?
        
        // WHEN
        userReportService.execute {
            merchantSummaryResult = $0
            merchantSummaryError = $1
            expectationSearch.fulfill()
        }
        
        // THEN
        wait(for: [expectationSearch], timeout: 5.0)
        XCTAssertNil(merchantSummaryError)
        XCTAssertNotNil(merchantSummaryResult)
        XCTAssertTrue(merchantSummaryResult?.totalRecordCount ?? 0 > 0)
        XCTAssertTrue(merchantSummaryResult?.results.count ?? 0 == 1)
        
        // GIVEN
        let userExpectation = expectation(description: "User Expectation")
        let merchant = User.fromId(from: merchantSummaryResult?.results.first?.id ?? "", userType: .merchant)
        let paymentStatistics = PaymentStatistics()
        paymentStatistics.totalMonthlySalesAmount = 1111
        paymentStatistics.highestTicketSalesAmount = 2222
        var userResponse: User?
        var userError: Error?
        
        // WHEN
        merchant.edit()
            .withPaymentStatistics(paymentStatistics)
            .withDescription("Update merchant applicant info")
            .execute {
                userResponse = $0
                userError = $1
                userExpectation.fulfill()
            }
        
        // THEN
        wait(for: [userExpectation], timeout: 5.0)
        XCTAssertNil(userError)
        XCTAssertNotNil(userResponse)
        XCTAssertEqual("PENDING", userResponse?.responseCode)
    }
    
    public func test_edit_merchant_bussiness_information() {
        // GIVEN
        let expectationSearch = expectation(description: "Search Merchant Expectation")
        let userReportService = ReportingService.findMerchants(1, pageSize: 1)
        var merchantSummaryResult: PagedResult<MerchantSummary>?
        var merchantSummaryError: Error?
        
        // WHEN
        userReportService.execute {
            merchantSummaryResult = $0
            merchantSummaryError = $1
            expectationSearch.fulfill()
        }
        
        // THEN
        wait(for: [expectationSearch], timeout: 5.0)
        XCTAssertNil(merchantSummaryError)
        XCTAssertNotNil(merchantSummaryResult)
        XCTAssertTrue(merchantSummaryResult?.totalRecordCount ?? 0 > 0)
        XCTAssertTrue(merchantSummaryResult?.results.count ?? 0 == 1)
        
        // GIVEN
        let userExpectation = expectation(description: "User Expectation")
        let merchant = User.fromId(from: merchantSummaryResult?.results.first?.id ?? "", userType: .merchant)
        merchant.userReference?.userStatus = .ACTIVE
        var userResponse: User?
        var userError: Error?
        
        
        let merchantData = UserPersonalData()
        merchantData.userName = "Username"
        merchantData.DBA = "Doing Business As"
        merchantData.website = "https://abcd.com"
        merchantData.taxIdReference = "987654321"
        let businessAddress = Address()
        businessAddress.streetAddress1 = "Apartment 852"
        businessAddress.streetAddress2 = "Complex 741"
        businessAddress.streetAddress3 = "Unit 4"
        businessAddress.city = "Chicago"
        businessAddress.state = "IL"
        businessAddress.postalCode = "50001"
        businessAddress.countryCode = "840"
        merchantData.userAddress = businessAddress
        
        // WHEN
        merchant.edit()
            .withUserPersonalData(merchantData)
            .withDescription("Update merchant applicant info")
            .execute {
                userResponse = $0
                userError = $1
                userExpectation.fulfill()
            }
        
        // THEN
        wait(for: [userExpectation], timeout: 5.0)
        XCTAssertNil(userError)
        XCTAssertNotNil(userResponse)
        XCTAssertEqual("PENDING", userResponse?.responseCode)
        XCTAssertEqual(UserStatus.UNDER_REVIEW, userResponse?.userReference?.userStatus)
    }
    
    private func getPersonList(_ type: String? = nil) -> [Person] {
        var persons = [Person]()
        
        let person = Person()
        person.functions = .APPLICANT
        person.firstName = "James \(type ?? "")"
        person.middleName = "Mason \(type ?? "")"
        person.lastName = "Doe " + " " + "\(type ?? "")"
        person.email = "uniqueemail@address.com"
        person.dateOfBirth = "1982-02-23"
        person.nationalIdReference = "123456789"
        person.jobTitle = "CEO";
        person.equityPercentage = "25";
        person.address = Address();
        person.address?.streetAddress1 = "1 Business Address"
        person.address?.streetAddress2 = "Suite 2"
        person.address?.streetAddress3 = "1234"
        person.address?.city = "Atlanta"
        person.address?.state = "GA"
        person.address?.postalCode = "30346"
        person.address?.country = "US"
        
        let phoneNumber = PhoneNumber()
        phoneNumber.countryCode = "01"
        phoneNumber.number = "8008675309"
        
        person.homePhone = phoneNumber
        person.workPhone = phoneNumber
        
        persons.append(person)
        
        return persons
    }
    
    private func getPaymentStatistics() -> PaymentStatistics {
        let paymentStatistics = PaymentStatistics()
        paymentStatistics.totalMonthlySalesAmount = 3000000
        paymentStatistics.averageTicketSalesAmount = 50000
        paymentStatistics.highestTicketSalesAmount = 60000
        return paymentStatistics
    }
    
    private func getProductList() -> [Product] {
        let productIdList = ["PRO_TRA_CP-US-CARD-A920_SP", "PRO_FMA_PUSH-FUNDS_PP", "PRO_TRA_CNP_US_BANK-TRANSFER_PP", "PRO_TRA_CNP-US-CARD_PP" ]
        var list = [Product]()
        
        productIdList.forEach { productId in
            let product = Product()
            product.quantity = 1
            product.productId = productId
            
            list.append(product)
        }
        return list
    }
    
    private func getBankAccountData() -> BankAccountData{
        let bankAccountInformation = BankAccountData()
        bankAccountInformation.accountHolderName = "Bank Account Holder Name"
        bankAccountInformation.accountNumber = "123456788"
        bankAccountInformation.accountOwnershipType = "Personal"
        bankAccountInformation.accountType = AccountType.saving.mapped(for: .gpApi)
        bankAccountInformation.routingNumber = "102000076"
        
        return bankAccountInformation
    }
    
    private func getMerchantData() -> UserPersonalData {
        let merchantData = UserPersonalData()
        merchantData.userName = "CERT_Propay_\(Date())"
        merchantData.legalName = "Business Legal Name"
        merchantData.DBA = "Doing Business As"
        merchantData.merchantCategoryCode = 5999
        merchantData.website = "https://example.com/"
        merchantData.notificationEmail = "merchant@example.com"
        merchantData.currencyCode = "USD"
        merchantData.taxIdReference = "123456789"
        merchantData.tier = "test"
        merchantData.type = .merchant
        
        let businessAddress = Address()
        businessAddress.streetAddress1 = "Apartment 852"
        businessAddress.streetAddress2 = "Complex 741"
        businessAddress.streetAddress3 = "Unit 4"
        businessAddress.city = "Chicago"
        businessAddress.state = "IL"
        businessAddress.postalCode = "50001"
        businessAddress.countryCode = "840"
        
        merchantData.userAddress = businessAddress
        
        let shippingAddress = Address()
        shippingAddress.streetAddress1 = "Flat 456"
        shippingAddress.streetAddress2 = "House 789"
        shippingAddress.streetAddress3 = "Basement Flat"
        shippingAddress.city = "Halifax"
        shippingAddress.postalCode = "W5 9HR"
        shippingAddress.countryCode = "826"
        
        merchantData.mailingAddress = shippingAddress
        merchantData.notificationStatusUrl = "https://www.example.com/notifications/status"
        
        return merchantData
    }
}
