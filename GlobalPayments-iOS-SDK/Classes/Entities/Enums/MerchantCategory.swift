import Foundation

public enum MerchantCategory: String, Mappable, CaseIterable {
    
    case HOTEL
    case AIRLINE
    case RETAIL
    case TOP_UP
    case PLAYER
    case CD_KEY
    case OTHER
    
    public init?(value: String?) {
        guard let value = value,
              let status = MerchantCategory(rawValue: value) else { return nil }
        self = status
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
