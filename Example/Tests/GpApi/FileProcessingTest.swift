import XCTest
import GlobalPayments_iOS_SDK

final class FileProcessingTest: XCTestCase {

    override class func setUp() {
        super.setUp()
        
        let accessTokenInfo = AccessTokenInfo(transactionProcessingAccountName: "transaction_processing")
        
        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "fWkEqBHQNyLrWCAtp1vCWDbo10kf5jr6",
            appKey: "EkOH93AQKuGlj8Ty",
            channel: .cardNotPresent,
            country: "US",
            accessTokenInfo: accessTokenInfo,
            challengeNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            methodNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
            merchantContactUrl: "https://enp4qhvjseljg.x.pipedream.net/",
            statusUrl: "https://eo9faqlbl8wkwmx.m.pipedream.net/"
        ))
    }
    
    override func setUp() {
        super.setUp()
    }
    
    func test_create_upload_url() {
        
        // GIVEN
        let createUploadUrlExpectation = expectation(description: "Create Upload Url Expectation")
        var uploadUrlResponse: FileProcessor?
        var uploadUrlError: Error?
        let service = FileProcessingService.initiate()
        
        // WHEN
        service.execute {
            uploadUrlResponse = $0
            uploadUrlError = $1
            createUploadUrlExpectation.fulfill()
        }
        
        // THEN
        wait(for: [createUploadUrlExpectation], timeout: 10.0)
        XCTAssertNil(uploadUrlError)
        XCTAssertNotNil(uploadUrlResponse)
        XCTAssertEqual("SUCCESS", uploadUrlResponse?.responseCode)
        XCTAssertEqual("INITIATED", uploadUrlResponse?.responseMessage)
        XCTAssertNotNil(uploadUrlResponse?.uploadUrl)
        
        // GIVEN
        let uploadDocumentExpectation = expectation(description: "Upload Document Expectation")
        var uploadDocumentResponse: Data?
        var uploadDocumentError: Error?
        let testFileUrl = Bundle.main.url(forResource: "TestFile", withExtension:"txt")
        let uploadDocumentClient = FileProcessingClient(uploadUrl: uploadUrlResponse?.uploadUrl ?? "")
        
        
        // WHEN
        uploadDocumentClient.uploadFile(file: testFileUrl) {
            uploadDocumentResponse = $0
            uploadDocumentError = $1
            uploadDocumentExpectation.fulfill()
        }
        
        // THEN
        wait(for: [uploadDocumentExpectation], timeout: 20.0)
        XCTAssertNil(uploadDocumentError)
        XCTAssertNotNil(uploadDocumentResponse)
        
        // GIVEN
        let getFileDetailsExpectation = expectation(description: "Get File Details Expectation")
        var getFileDetailsResponse: FileProcessor?
        var getFileDetailsError: Error?
        let serviceDetails = FileProcessingService.getDetails(resourceId: uploadUrlResponse?.resourceId)
        
        // WHEN
        serviceDetails.execute {
            getFileDetailsResponse = $0
            getFileDetailsError = $1
            getFileDetailsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [getFileDetailsExpectation], timeout: 10.0)
        XCTAssertNil(getFileDetailsError)
        XCTAssertNotNil(getFileDetailsResponse)
    }
    
    
    func test_get_file_uploaded_details() {
        // GIVEN
        let resourceId = "FPR_971edc6eb0944d8d890dcba7a2a41bea"
        let getFileDetailsExpectation = expectation(description: "Get File Details Expectation")
        var getFileDetailsResponse: FileProcessor?
        var getFileDetailsError: Error?
        let serviceDetails = FileProcessingService.getDetails(resourceId: resourceId)
        
        // WHEN
        serviceDetails.execute {
            getFileDetailsResponse = $0
            getFileDetailsError = $1
            getFileDetailsExpectation.fulfill()
        }
        
        // THEN
        wait(for: [getFileDetailsExpectation], timeout: 10.0)
        XCTAssertNil(getFileDetailsError)
        XCTAssertNotNil(getFileDetailsResponse)
    }
}
