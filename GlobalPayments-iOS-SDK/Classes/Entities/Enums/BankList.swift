import Foundation

public enum BankList: String, Mappable {
    case PKOBANKPOLSKISA = "pkobankpolskisa"
    case SANTANDER = "santander"
    case ING = "ing"
    case BANKPEKAOSA = "bankpekaosa"
    case MBANK = "mbank"
    case ALIOR = "alior"
    case BNPPARIBAS = "bnpparibas"
    case MILLENIUM = "millennium"
    case CREDITAGRICOLE = "creditagricole"
    case CITI = "citi"
    case INTELIGO = "inteligo"
    case BANKISPOLDZIELCZE = "bankispoldzielcze"
    case BOSBANK = "bosbank"
    case NESTBANK = "nestbank"
    case VELOBANK = "velobank"
    case BANKNOWYSA = "banknowysa"
    case PLUSBANK = "plusbank"
    case BANKPOCZTOWY = "bankpocztowy"
    
    public init?(value: String?) {
        guard let value = value,
              let method = BankList(rawValue: value) else { return nil }
        self = method
    }
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
