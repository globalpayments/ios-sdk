import Foundation

public class DocumentInfo: Encodable {
    public var type: DocumentType?
    public var fileFormat: String?
    public let b64Content: Data?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case fileFormat = "file_format"
        case b64Content = "b64_content"
    }

    /// Use for dispute document challenges — maps `type` and `b64_content`.
    public init(type: DocumentType, b64Content: Data?) {
        self.type = type
        self.b64Content = b64Content
    }

    /// Use for transaction challenges — maps `file_format` and `b64_content`.
    public init(b64Content: Data?, fileFormat: String) {
        self.b64Content = b64Content
        self.fileFormat = fileFormat
    }
}
