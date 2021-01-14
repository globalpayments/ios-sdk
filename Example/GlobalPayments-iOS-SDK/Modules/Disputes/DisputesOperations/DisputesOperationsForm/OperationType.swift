import Foundation

enum OperationType: String, CaseIterable {
    case accept
    case challenge

    public init?(value: String?) {
        guard let value = value,
              let type = OperationType(rawValue: value) else { return nil }
        self = type
    }
}
