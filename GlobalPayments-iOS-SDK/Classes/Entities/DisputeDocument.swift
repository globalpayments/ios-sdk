import Foundation

public class DisputeDocument: Encodable, Equatable {
    public let id: String
    public var type: DocumentType?
    public var base64Content: Data?

    public init(id: String, content: Data) {
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
