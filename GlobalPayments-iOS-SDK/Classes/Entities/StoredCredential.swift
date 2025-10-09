import Foundation

public class StoredCredential: NSObject {
    public var type: StoredCredentialType
    public var initiator: StoredCredentialInitiator
    public var sequence: StoredCredentialSequence
    public var reason: StoredCredentialReason
    public var schemeId: String?
    public var contractReferenc: String?

    public required init(type: StoredCredentialType,
                         initiator: StoredCredentialInitiator,
                         sequence: StoredCredentialSequence,
                         reason: StoredCredentialReason,
                         schemeId: String? = nil,
                         contractReference: String? = nil) {

        self.type = type
        self.initiator = initiator
        self.sequence = sequence
        self.reason = reason
        self.schemeId = schemeId
        self.contractReferenc = contractReference
    }
}
