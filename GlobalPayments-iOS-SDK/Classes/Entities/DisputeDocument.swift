import Foundation

public class DisputeDocument: Encodable, Equatable {
    public let id: String
    public var type: DocumentType?
    /// Document type exactly as returned by the gateway (e.g. `ACQUIRER_DOC_FOR_ISSUER`).
    public var rawType: String?
    public var base64Content: Data?

    public init(id: String, content: Data? = nil) {
        self.id = id
        self.base64Content = content
    }
    
    public init(id: String, type: DocumentType) {
        self.id = id
        self.type = type
    }

    public static func == (lhs: DisputeDocument, rhs: DisputeDocument) -> Bool {
        lhs.id == rhs.id
    }
}
