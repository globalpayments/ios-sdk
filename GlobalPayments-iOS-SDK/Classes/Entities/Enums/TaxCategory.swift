import Foundation

public enum TaxCategory: String, Mappable {
    case service = "SERVICE"
    case duty = "DUTY"
    case vat = "VAT"
    case alternate = "ALTERNATE"
    case national = "NATIONAL"
    case taxExempt = "TAX_EXEMPT"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .transit:
            return self.rawValue
        default:
            return nil
        }
    }
}
