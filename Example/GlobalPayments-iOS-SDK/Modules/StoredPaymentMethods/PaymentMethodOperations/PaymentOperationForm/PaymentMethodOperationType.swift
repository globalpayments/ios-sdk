import Foundation

enum PaymentMethodOperationType: String, CaseIterable {
    case tokenize
    case edit
    case delete

    public init?(value: String?) {
        guard let value = value,
              let operation = PaymentMethodOperationType(rawValue: value) else { return nil }
        self = operation
    }
}
