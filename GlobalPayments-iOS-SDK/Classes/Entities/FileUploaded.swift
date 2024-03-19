import Foundation

public class FileUploaded {
    
    public var fileId: String?
    public var fileName: String?
    public var timeCreated: Date?
    public var url: String?
    public var expirationDate: Date?
}

extension FileUploaded: JsonToObject {
    
    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let fileUploaded = FileUploaded()
        fileUploaded.fileId = doc.getValue(key: "response_file_id")
        fileUploaded.fileName = doc.getValue(key: "name")
        fileUploaded.expirationDate = doc.getValue(key: "expiration_date")
        fileUploaded.timeCreated = doc.getValue(key: "time_created")
        fileUploaded.url = doc.getValue(key: "url")
        return fileUploaded as? T
    }
}
