import Foundation

public enum RemittanceReferenceType: String, Mappable, CaseIterable {
    
    case TEXT
    case PAN
    
    public init?(value: String?) {
        guard let value = value,
              let type = RemittanceReferenceType(rawValue: value) else { return nil }
        self = type
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
