import Foundation

extension Decimal {

    static func sum(_ lhs: Decimal?, _ rhs: Decimal?) -> Decimal {
        return (lhs ?? .zero) + (rhs ?? .zero)
    }

    func toNumericCurrencyString() -> String {
        var input: Decimal = self * 100
        var output: Decimal = 0
        NSDecimalRound(&output, &input, 0, .plain)
        return String(describing: output)
    }

    var amount: Decimal {
        return self / 100
    }
}
