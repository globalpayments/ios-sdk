import Foundation

public class CurrencyUtils {
    
    public static let shared = CurrencyUtils()
    
    private init() { }
    
    func getBankPaymentType(_ currency: String) -> BankPaymentType? {
        switch currency {
        case "EUR":
            return BankPaymentType.SEPA
        case "GBP":
            return BankPaymentType.FASTERPAYMENTS
        default:
            return nil
        }
    }
    
    static let defaultExponent = 2

    private static let exponents: [String: Int] = [
        // ── Exponent 0 ── whole-unit (no decimal places on the GP-API wire)
        "ISK": 0,
        "KRW": 0,
        "VND": 0,

        // ── Exponent 3 ── milli-unit (×1000 on the GP-API wire)
        "BHD": 3,
        "KWD": 3,
        "OMR": 3,

        // ── Exponent 2 ── standard two-decimal currencies
        "JPY": 2,
        // CLP: ISO 4217 exponent 0, but 24713 analysis mandates exponent 2 on the wire.
        "CLP": 2,
        "AED": 2, "AUD": 2, "BDT": 2, "BND": 2, "BRL": 2,
        "CAD": 2, "CHF": 2, "CNY": 2, "DKK": 2, "EGP": 2,
        "EUR": 2, "GBP": 2, "HKD": 2, "IDR": 2, "ILS": 2,
        "INR": 2, "LKR": 2, "MOP": 2, "MUR": 2, "MVR": 2,
        "MXN": 2, "MYR": 2, "NOK": 2, "NZD": 2, "PGK": 2,
        "PHP": 2, "PKR": 2, "QAR": 2, "RUB": 2, "SAR": 2,
        "SEK": 2, "SGD": 2, "THB": 2, "TRY": 2, "TWD": 2,
        "USD": 2, "VEF": 2, "ZAR": 2
    ]
    
    /// - Returns: 0, 2, or 3 depending on the currency.
    func exponent(for currency: String?) -> Int {
        guard let key = currency?.uppercased(), !key.isEmpty else {
            return CurrencyUtils.defaultExponent
        }
        return CurrencyUtils.exponents[key] ?? CurrencyUtils.defaultExponent
    }

    /// Returns `true` when the currency code is in the supported table.
    func isSupported(_ currency: String?) -> Bool {
        guard let key = currency?.uppercased(), !key.isEmpty else { return false }
        return CurrencyUtils.exponents[key] != nil
    }
}
