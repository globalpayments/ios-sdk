import Foundation

public enum Environment: String, CaseIterable {
    case test
    case production
    
    public init?(value: String?) {
        guard let value = value,
              let status = Environment(rawValue: value.lowercased()) else { return nil }
        self = status
    }
}
