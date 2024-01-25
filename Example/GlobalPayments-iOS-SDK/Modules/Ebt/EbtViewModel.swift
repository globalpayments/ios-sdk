import Foundation
import GlobalPayments_iOS_SDK

final class EbtViewModel: BaseViewModel {
    
    private let currency: String = "USD"
    
    var enableButton: Dynamic<Bool> = Dynamic(false)
    
    private var amount: NSDecimalNumber = 0.0
    private var cardNumber: String = ""
    private var expirationDate: String = Date().format("MM-yyyy")
    private var pinBlock: String = ""
    private var cvn: String = ""
    private var cardHolderName: String = ""

    func doEbtTransaction(path: TransactionTypePath) {
        showLoading.executer()
        let card = EBTCardData()
        card.number = cardNumber
        
        let splitDate = expirationDate.split(separator: "-")
        card.expMonth = Int(String(splitDate[0])) ?? 0
        card.expYear = Int(String(splitDate[1])) ?? 0
        card.cvn = cvn
        card.pinBlock = pinBlock
        card.cardPresent = true

        switch path {
        case .charge:
            card.charge(amount: amount)
                .withCurrency(currency)
                .execute(completion: showOutput)
            break
        case .refund:
            card.refund(amount: amount)
                .withCurrency(currency)
                .execute(completion: showOutput)
            break
        }
    }

    private func showOutput(transaction: Transaction?, error: Error?) {
        UI {
            guard let transaction = transaction else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            self.showDataResponse.value = (.success, transaction)
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .amount:
            amount = NSDecimalNumber(string: value)
        case .cardNumber:
            cardNumber = value
        case .expirationDate:
            expirationDate = value
        case .pinBlock:
            pinBlock = value
        case .cardCvv:
            cvn = value
        case .cardHolderName:
            cardHolderName = value
        default:
            break
        }
        validateFields()
    }
    
    private func validateFields() {
        guard amount.doubleValue > 0.0,
              !cardNumber.isEmpty,
              !expirationDate.isEmpty else {
            enableButton.value = false
            return
        }
        enableButton.value = true
    }
}

