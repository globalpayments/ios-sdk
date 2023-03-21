import Foundation

public enum ManualEntryMethod: Int, Encodable, CaseIterable {
    case MOTO = 0
    case MAIL = 1
    case PHONE = 2
    case KEYED = 3

    public init?(value: Int?) {
        guard let value = value,
              let mode = ManualEntryMethod(rawValue: value) else { return nil }
        self = mode
    }
    
    public static func withLabel(_ label: String?) -> ManualEntryMethod? {
        return self.allCases.first{ "\($0)" == label }
    }
}

public enum ManualEntryCases: String, CaseIterable {
    case MOTO
    case MAIL
    case PHONE
}
