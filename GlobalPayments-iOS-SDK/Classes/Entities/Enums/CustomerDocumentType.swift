import Foundation

public enum CustomerDocumentType: String, Mappable, CaseIterable {

    case NATIONAL
    case CPF
    case CPNJ
    case CURP
    case SSN
    case DRIVER_LICENSE
    case PASSPORT
    
    public init?(value: String?) {
        guard let value = value,
              let type = CustomerDocumentType(rawValue: value) else { return nil }
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
