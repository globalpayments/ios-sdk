import Foundation

public enum EntryMode: String, Mappable, Encodable {
    case moto = "MOTO"
    case ecom = "ECOM"
    case inApp = "IN_APP"
    case chip = "CHIP"
    case swipe = "SWIPE"
    case manual = "MANUAL"
    case contactlessChip = "CONTACTLESS_CHIP"
    case contactlessSwipe = "CONTACTLESS_SWIPE"

    init?(value: String?) {
        guard let value = value,
              let mode = EntryMode(rawValue: value) else { return nil }
        self = mode
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
