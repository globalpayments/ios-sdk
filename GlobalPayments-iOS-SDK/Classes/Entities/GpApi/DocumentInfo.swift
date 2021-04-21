import Foundation

public class DocumentInfo: Encodable {
    public let type: DocumentType
    public let b64Content: Data?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case b64Content = "b64_content"
    }

    public init(type: DocumentType, b64Content: Data?) {
        self.type = type
        self.b64Content = b64Content
    }
}
