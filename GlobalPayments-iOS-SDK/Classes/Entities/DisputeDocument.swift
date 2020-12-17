import Foundation

public class DisputeDocument: Encodable, Equatable {
    public let id: String
    public let type: DocumentType

    public init(id: String, type: DocumentType) {
        self.id = id
        self.type = type
    }

    public static func == (lhs: DisputeDocument, rhs: DisputeDocument) -> Bool {
        lhs.id == rhs.id
    }
}
