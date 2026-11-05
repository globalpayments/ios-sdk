import Foundation

public class DocumentMetadata: Encodable {
    /// Unique identifier for the document on the Global Payments system
    public let id: String
    /// The document represented as a base64 encoded string.
    /// When saving to directory, name must contain PDF extension. Example: document.pdf
    public let b64Content: Data
    /// The action that was executed on the gateway to retrieve the document
    public var action: ActionSummary?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case b64Content = "b64_content"
    }

    public init(id: String, b64Content: Data) {
        self.id = id
        self.b64Content = b64Content
    }
}
