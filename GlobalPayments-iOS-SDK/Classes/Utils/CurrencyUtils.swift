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
}
