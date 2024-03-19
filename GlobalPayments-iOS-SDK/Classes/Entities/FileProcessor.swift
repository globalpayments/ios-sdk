import Foundation

public class FileProcessor {
    
    private static let CREATED = ""
    private static let SINGLE_FILE = ""
    
    public var resourceId: String?
    public var uploadUrl: String?
    public var expirationDate: Date?
    public var createdDate: String?
    public var totalRecordCount: String?
    public var responseCode: String?
    public var responseMessage: String?
    public var filesUploaded: [FileUploaded]?
}

extension FileProcessor: JsonToObject {
    
    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let fileProcessor = FileProcessor()
        fileProcessor.resourceId = doc.getValue(key: "id")
        fileProcessor.expirationDate = doc.getValue(key: "expiration_date")
        fileProcessor.uploadUrl = doc.getValue(key: "url")
        fileProcessor.responseCode = doc.get(valueFor: "action")?.getValue(key: "result_code")
        fileProcessor.responseMessage = doc.getValue(key: "status")
        
        if let typeAction: String = doc.get(valueFor: "action")?.getValue(key: "type"){
            switch typeAction {
            case SINGLE_FILE:
                if let documents: [JsonDoc?] = doc.getValue(key: "response_files") {
                    fileProcessor.filesUploaded = documents.compactMap { FileUploaded.mapToObject($0 ??  JsonDoc()) }
                }
            default:
                break
            }
        }
        return fileProcessor as? T
    }
}
