import Foundation

enum TransactionOperationType: String, CaseIterable {
    case authorization
    case sale
    case capture
    case refund
    case reverse

    init?(value: String?) {
        guard let value = value,
              let type = TransactionOperationType(rawValue: value) else { return nil }
        self = type
    }
}
