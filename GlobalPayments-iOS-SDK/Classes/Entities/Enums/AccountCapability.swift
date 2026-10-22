import Foundation

/// A capability that can be enabled or disabled on a merchant's account via PATCH /accounts/{id}.
public enum AccountCapability: String, Mappable, CaseIterable {
    case PAY_IN_ENABLE
    case PAY_IN_DISABLE
    case PAY_OUT_ENABLE
    case PAY_OUT_DISABLE
    case CC_PROCESSING_ENABLE
    case CC_PROCESSING_DISABLE
    case TRANSFER_IN_ENABLE
    case TRANSFER_IN_DISABLE
    case TRANSFER_OUT_ENABLE
    case TRANSFER_OUT_DISABLE
    case CARD_PROCESSING_OVER_LIMIT_ENABLE
    case CARD_PROCESSING_OVER_LIMIT_DISABLE
    case BANK_TRANSFER_PROCESSING_OVER_LIMIT_ENABLE
    case BANK_TRANSFER_PROCESSING_OVER_LIMIT_DISABLE
    case ACH_PROCESSING_OVER_LIMIT_ENABLE
    case ACH_PROCESSING_OVER_LIMIT_DISABLE
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
