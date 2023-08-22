import Foundation

public class BankPaymentResponse {
    
    public var id: String?
    public var redirectUrl: String?
    public var paymentStatus: String?
    public var type: BankPaymentType?
    public var tokenRequestId: String?
    public var sortCode: String?
    public var accountName: String?
    public var accountNumber: String?
    public var iban: String?
    public var remittanceReferenceValue: String?
    public var rßemittanceReferenceType: String?
}

extension BankPaymentResponse: JsonToObject {
    
    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let bankPaymentResponse = BankPaymentResponse()
        bankPaymentResponse.redirectUrl = doc.getValue(key: "redirect_url")
        bankPaymentResponse.paymentStatus = doc.getValue(key: "message")

        if let bankTransfer = doc.get(valueFor: "bank_transfer") {
            bankPaymentResponse.accountNumber = bankTransfer.getValue(key: "masked_account_number_last4")
            bankPaymentResponse.iban = bankTransfer.getValue(key: "masked_iban_last4")

            if let bank = bankTransfer.get(valueFor: "bank") {
                bankPaymentResponse.sortCode = bank.getValue(key: "code")
                bankPaymentResponse.accountName = bank.getValue(key: "name")
            }
        }
        return bankPaymentResponse as? T
    }
}
