import Foundation

public class DisputeDocument: Encodable {
    let id: String
    let type: DocumentType

    init(id: String, type: DocumentType) {
        self.id = id
        self.type = type
    }
}
