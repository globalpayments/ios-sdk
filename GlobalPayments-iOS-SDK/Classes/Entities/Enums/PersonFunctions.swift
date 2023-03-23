import Foundation

public enum PersonFunctions: String, Mappable {
    
    case APPLICANT
    case BENEFICIAL_OWNER
    case PAYMENT_METHOD_OWNER
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
