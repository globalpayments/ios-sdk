import Foundation

public enum SecCode: String, Mappable, CaseIterable {
    // Indicates prearranged payment and deposit (PPD).
    case ppd
    // Indicates cash concentration or disbursement (CCD).
    case ccd
    // Indicates point of purchase entry (POP).
    case pop
    // Indicates internet initiated entry (WEB).
    case web
    // Indicates telephone initiated entry (TEL).
    case tel
    // Indicates verification only.
    case ebronze

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
