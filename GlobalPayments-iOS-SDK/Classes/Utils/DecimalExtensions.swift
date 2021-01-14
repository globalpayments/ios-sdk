import Foundation

extension NSDecimalNumber {

    static func sum(_ lhs: NSDecimalNumber?, _ rhs: NSDecimalNumber?) -> NSDecimalNumber {
        return (lhs ?? .zero).adding((rhs ?? .zero))
    }

    func toNumericCurrencyString() -> String? {
        guard self != NSDecimalNumber.notANumber else { return nil }
        let input: NSDecimalNumber = self.multiplying(by: 100)
        let behavior = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let output = input.rounding(accordingToBehavior: behavior)
        return String(describing: output)
    }

    var amount: NSDecimalNumber? {
        guard self != NSDecimalNumber.notANumber else {
            return nil
        }
        return self.dividing(by: 100)
    }
}
