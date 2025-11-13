import XCTest
import GlobalPayments_iOS_SDK

final class GpApiCreateInstallmentTest: XCTestCase {

    private let APP_ID = "bcTDtE6wV2iCfWPqXv0FMpU86YDqvTnc"
    private let APP_KEY = "jdf2vlLCA13A3Fsz"
    private var installment: Installment?
    private var visaCard: CreditCardData?
    private var masterCard: CreditCardData?
    private var encryption: Encryption?
    
    override func setUp() {
        super.setUp()
        createInstallmentConfiguration()
    }
    
    func createInstallmentConfiguration() {
        let config = GpApiConfig(
            appId: APP_ID,
            appKey: APP_KEY)
        config.channel = .cardNotPresent
        config.country = "MX"
        config.serviceUrl = "https://apis-sit.globalpay.com/ucp"
        
        let accessTokenInfo =  AccessTokenInfo()
        accessTokenInfo.transactionProcessingAccountName = "IPP_Processing"
        config.accessTokenInfo = accessTokenInfo
        try? ServicesContainer.configureService(config: config)
        
        installment = Installment()
        installment?.Channel =  "CNP"
        installment?.Amount = 11
        installment?.Country = "MX"
        installment?.Currency = "MXN"
        installment?.Program = "SIP"
        installment?.AccountName = "transaction_processing"
        installment?.Reference = "becf9f3e-4d33-459c-8ed2-0c4affc95"
        
        encryption = Encryption()
        encryption?.method = ""
        encryption?.version = ""
        encryption?.info = ""
        encryption?.type = ""
        installment?.encryption = encryption
        
        installment?.EntryMode = "ECOM"
        
        visaCard = CreditCardData()
        visaCard?.number = "4213168058314147"
        visaCard?.expMonth = 07
        visaCard?.expYear = 2027
        visaCard?.cvn = "123"
        visaCard?.cardPresent = false
        visaCard?.readerPresent = false
        
        masterCard = CreditCardData()
        masterCard?.number = "5546259023665054"
        masterCard?.expMonth = 11
        masterCard?.expYear = 2025
        masterCard?.cvn = "123"
        masterCard?.cardPresent = false
        masterCard?.readerPresent = false
    }
    
    func test_CreateInstallment_WithMasterCardAndValidProgramSIP() {
        installment?.CardDetails = masterCard
        
        let expectationValidProgramSIP = expectation(description: "Create Installment Master Card And Valid ProgramSIP")
        var installmentResponse: Installment?
        var errorResponse: Error?
        
        
        installment?.create { installment, error in
            installmentResponse = installment
            errorResponse = error
            expectationValidProgramSIP.fulfill()
        }
        
        wait(for: [expectationValidProgramSIP], timeout: 10.0)
        XCTAssertNotNil(installmentResponse)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(installment?.Program, installmentResponse?.Program)
        XCTAssertEqual("APPROVAL", installmentResponse?.Message)
        XCTAssertNotNil(installmentResponse?.AuthCode)
        XCTAssertEqual("00", installmentResponse?.Result)
        XCTAssertEqual("SUCCESS", installmentResponse?.Action?.ResultCode)
    }
    
    func test_CreateInstallment_WithMasterCardAndValidProgramMIPP() {
        installment?.Program = "mIPP"
        installment?.CardDetails = masterCard
        
        let expectationValidProgramMIPP = expectation(description: "Create Installment Master Card And Valid ProgramMIPP")
        var installmentResponse: Installment?
        var errorResponse: Error?
        
        installment?.create { installment, error in
            installmentResponse = installment
            errorResponse = error
            expectationValidProgramMIPP.fulfill()
        }
        
        wait(for: [expectationValidProgramMIPP], timeout: 10.0)
        XCTAssertNotNil(installmentResponse)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(installment?.Program, installmentResponse?.Program)
        XCTAssertEqual("APPROVAL", installmentResponse?.Message)
        XCTAssertNotNil(installmentResponse?.AuthCode)
        XCTAssertEqual("00", installmentResponse?.Result)
        XCTAssertEqual("SUCCESS", installmentResponse?.Action?.ResultCode)
    }
    
    func test_CreateInstallment_WithVisaAndValidProgramSIP() {
        installment?.CardDetails = visaCard
        
        let expectationValidProgramSIP = expectation(description: "Create Installment Visa Card And Valid ProgramSIP")
        var installmentResponse: Installment?
        var errorResponse: Error?
        
        installment?.create { installment, error in
            installmentResponse = installment
            errorResponse = error
            expectationValidProgramSIP.fulfill()
        }
        
        wait(for: [expectationValidProgramSIP], timeout: 10.0)
        XCTAssertNotNil(installmentResponse)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(installment?.Program, installmentResponse?.Program)
        XCTAssertEqual("APPROVAL", installmentResponse?.Message)
        XCTAssertNotNil(installmentResponse?.AuthCode)
        XCTAssertEqual("00", installmentResponse?.Result)
        XCTAssertEqual("SUCCESS", installmentResponse?.Action?.ResultCode)
    }
    
    func test_CreateInstallment_WithVisaAndValidProgramMIPP() {
        installment?.Program = "mIPP"
        installment?.CardDetails = visaCard
        
        let expectationValidProgramMIPP = expectation(description: "Create Installment Visa Card And Valid ProgramMIPP")
        var installmentResponse: Installment?
        var errorResponse: Error?
        
        installment?.create { installment, error in
            installmentResponse = installment
            errorResponse = error
            expectationValidProgramMIPP.fulfill()
        }
        
        wait(for: [expectationValidProgramMIPP], timeout: 10.0)
        XCTAssertNotNil(installmentResponse)
        XCTAssertNil(errorResponse)
        XCTAssertEqual(installment?.Program, installmentResponse?.Program)
        XCTAssertEqual("APPROVAL", installmentResponse?.Message)
        XCTAssertNotNil(installmentResponse?.AuthCode)
        XCTAssertEqual("00", installmentResponse?.Result)
        XCTAssertEqual("SUCCESS", installmentResponse?.Action?.ResultCode)
    }
    
    func test_CreateInstallment_WithExpiredVisaCardAndValidProgramMIPP() {
        installment?.Program = "mIPP"
        
        visaCard?.number = "4213168058314147"
        visaCard?.expMonth = 07
        visaCard?.expYear = 2022
        visaCard?.cvn = "123"
        visaCard?.cardPresent = false
        visaCard?.readerPresent = false
        
        installment?.CardDetails = visaCard
        
        let expectationValidProgramMIPP = expectation(description: "Create Installment Expired Visa Card And Valid ProgramMIPP")
        var installmentResponse: Installment?
        var errorResponse: Error?
        
        installment?.create { installment, error in
            installmentResponse = installment
            errorResponse = error
            expectationValidProgramMIPP.fulfill()
        }
        
        wait(for: [expectationValidProgramMIPP], timeout: 10.0)
        XCTAssertNotNil(installmentResponse)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("EXPIRED CARD", installmentResponse?.Message)
        XCTAssertEqual("54", installmentResponse?.Result)
        XCTAssertEqual("DECLINED", installmentResponse?.Action?.ResultCode)
    }
    
    func test_CreateInstallment_WithExpiredMasterCardAndValidProgramMIPP() {
        installment?.Program = "mIPP"
        
        masterCard?.number = "5546259023665054"
        masterCard?.expMonth = 05
        masterCard?.expYear = 2021
        masterCard?.cvn = "123"
        masterCard?.cardPresent = false
        masterCard?.readerPresent = false
        
        installment?.CardDetails = masterCard
        
        let expectationValidProgramMIPP = expectation(description: "Create Installment Expired Master Card And Valid ProgramMIPP")
        var installmentResponse: Installment?
        var errorResponse: Error?
        installment?.create { installment, error in
            installmentResponse = installment
            errorResponse = error
            expectationValidProgramMIPP.fulfill()
        }
        
        wait(for: [expectationValidProgramMIPP], timeout: 10.0)
        XCTAssertNotNil(installmentResponse)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("EXPIRED CARD", installmentResponse?.Message)
        XCTAssertEqual("54", installmentResponse?.Result)
        XCTAssertEqual("DECLINED", installmentResponse?.Action?.ResultCode)
    }
    
    func test_CreateInstallment_WithVisaAndInvalidProgram() {
        installment?.CardDetails = visaCard
        installment?.Program = "InCorrectProgram"
        
        let expectationInvalidProgram = expectation(description: "Create Installment Expired Visa Card Invalid Program")
        var errorResponse: GatewayException?
        
        installment?.create { installment, error in
            errorResponse = error as? GatewayException
            expectationInvalidProgram.fulfill()
        }
        
        wait(for: [expectationInvalidProgram], timeout: 10.0)
        XCTAssertEqual("INVALID_REQUEST_DATA", errorResponse?.responseCode)
        XCTAssertEqual("40213", errorResponse?.responseMessage)
        XCTAssertEqual("Status Code: 400 - program contains unexpected data", errorResponse?.message)
    }
    
    func test_CreateInstallment_WithMasterCardAndInvalidProgram() {
        installment?.CardDetails = masterCard
        installment?.Program = "InCorrectProgram"
        
        let expectationInvalidProgram = expectation(description: "Create Installment Expired Master Card Invalid Program")
        var errorResponse: GatewayException?
        
        installment?.create { installment, error in
            errorResponse = error as? GatewayException
            expectationInvalidProgram.fulfill()
        }
        
        wait(for: [expectationInvalidProgram], timeout: 10.0)
        XCTAssertEqual("INVALID_REQUEST_DATA", errorResponse?.responseCode)
        XCTAssertEqual("40213", errorResponse?.responseMessage)
        XCTAssertEqual("Status Code: 400 - program contains unexpected data", errorResponse?.message)
    }
    
    func test_CreateInstallment_WithExpiredVisaCardAndValidProgramSIP() {
        visaCard?.number = "4213168058314147"
        visaCard?.expMonth = 07
        visaCard?.expYear = 2022
        visaCard?.cvn = "123"
        visaCard?.cardPresent = false
        visaCard?.readerPresent = false
        
        installment?.CardDetails = visaCard
        
        let expectationValidProgramSIP = expectation(description: "Create Installment Expired Visa Card And Valid ProgramSIP")
        var installmentResponse: Installment?
        var errorResponse: Error?
        
        installment?.create { installment, error in
            installmentResponse = installment
            errorResponse = error
            expectationValidProgramSIP.fulfill()
        }
        
        wait(for: [expectationValidProgramSIP], timeout: 10.0)
        XCTAssertNotNil(installmentResponse)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("EXPIRED CARD", installmentResponse?.Message)
        XCTAssertEqual("54", installmentResponse?.Result)
        XCTAssertEqual("DECLINED", installmentResponse?.Action?.ResultCode)
    }
    
    func test_CreateInstallment_WithExpiredMasterCardAndValidProgramSIP() {
        masterCard?.number = "5546259023665054"
        masterCard?.expMonth = 05
        masterCard?.expYear = 2021
        masterCard?.cvn = "123"
        masterCard?.cardPresent = false
        masterCard?.readerPresent = false
        
        installment?.CardDetails = masterCard
        
        let expectationValidProgramSIP = expectation(description: "Create Installment Expired Master Card And Valid ProgramSIP")
        var installmentResponse: Installment?
        var errorResponse: Error?
        installment?.create { installment, error in
            installmentResponse = installment
            errorResponse = error
            expectationValidProgramSIP.fulfill()
        }
        
        wait(for: [expectationValidProgramSIP], timeout: 10.0)
        XCTAssertNotNil(installmentResponse)
        XCTAssertNil(errorResponse)
        XCTAssertEqual("EXPIRED CARD", installmentResponse?.Message)
        XCTAssertEqual("54", installmentResponse?.Result)
        XCTAssertEqual("DECLINED", installmentResponse?.Action?.ResultCode)
    }
}

