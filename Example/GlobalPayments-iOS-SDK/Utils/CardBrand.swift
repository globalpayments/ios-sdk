import Foundation

enum CardBrand: String, CaseIterable {
    case visa
    case mastercard
    case amex
    case discover

    init?(value: String?) {
        guard let value = value,
              let brand = CardBrand(rawValue: value) else { return nil }
        self = brand
    }
}
