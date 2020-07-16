import Foundation

public class StoredCredential: NSObject {
    public var type: StoredCredentialType
    public var initiator: StoredCredentialInitiator
    public var sequence: StoredCredentialSequence
    public var schemeId: String

    public required init(type: StoredCredentialType,
                         initiator: StoredCredentialInitiator,
                         sequence: StoredCredentialSequence,
                         schemeId: String) {

        self.type = type
        self.initiator = initiator
        self.sequence = sequence
        self.schemeId = schemeId
    }
}
