import Foundation

public class BankResponse: NSObject, JsonToObject {
    public var name: String?
    public var identifierCode: String?
    public var iban: String?
    public var code: String?
    public var accountNumber: String?
    
    public static func mapToObject<T>(_ json: JsonDoc) -> T? {
        let bank = BankResponse()
        bank.name = json.getValue(key: "name")
        bank.identifierCode = json.getValue(key: "identifier_code")
        bank.iban = json.getValue(key: "iban")
        bank.code = json.getValue(key: "code")
        bank.accountNumber = json.getValue(key: "account_number")
        return bank as? T
    }
}
