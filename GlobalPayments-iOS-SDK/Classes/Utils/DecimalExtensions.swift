import Foundation

extension NSDecimalNumber {

    static func sum(_ lhs: NSDecimalNumber?, _ rhs: NSDecimalNumber?) -> NSDecimalNumber {
        return (lhs ?? .zero).adding((rhs ?? .zero))
    }

   
    public func toNumericCurrencyString(currency: String? = nil) -> String? {
        guard self != NSDecimalNumber.notANumber else { return nil }
        let exp = CurrencyUtils.shared.exponent(for: currency)
        let multiplier = NSDecimalNumber(mantissa: 1, exponent: Int16(exp), isNegative: false)
        let input: NSDecimalNumber = self.multiplying(by: multiplier)
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


    public func amount(for currency: String? = nil) -> NSDecimalNumber? {
        guard self != NSDecimalNumber.notANumber else {
            return nil
        }
        let exp = CurrencyUtils.shared.exponent(for: currency)
        let divisor = NSDecimalNumber(mantissa: 1, exponent: Int16(exp), isNegative: false)
        return self.dividing(by: divisor)
    }

    var amount: NSDecimalNumber? {
        guard self != NSDecimalNumber.notANumber else {
            return nil
        }
        return self.dividing(by: 100)
    }
    
    var toString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        formatter.usesGroupingSeparator = false 
        let string = formatter.string(from: self) ?? ""
        return string
    }
}

extension String {
    var toNSDecimalNumber: NSDecimalNumber {
            let decimal = NSDecimalNumber(string: self)
            return decimal == NSDecimalNumber.notANumber ? NSDecimalNumber.zero : decimal
        }
    
    var toInt: Int? {
        return Int(self) ?? 0
    }
}
