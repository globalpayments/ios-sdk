import Foundation
import GlobalPayments_iOS_SDK

final class VerificationsFormViewModel: BaseViewModel {
    
    private var cardNumber: String = ""
    private var cardExpiration: String = ""
    private var cvv: String = ""
    private var idempotencyId: String = ""
    private var fingerprintType: String = ""
    private var currency: String = ""

    func onSubmitPressed() {
        showLoading.executer()
        
        let dateExpSplit = cardExpiration.split(separator: "/")
        let month = Int(dateExpSplit[0]) ?? 0
        let year = Int(dateExpSplit[1]) ?? 0
        
        let card = CreditCardData()
        card.number = cardNumber
        card.expMonth = month
        card.expYear = year
        card.cvn = cvv

        card.verify()
            .withCurrency(currency)
            .withIdempotencyKey(idempotencyId)
            .execute(completion: showOutput)
    }

    private func showOutput(transaction: Any?, error: Error?) {
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
        case .cardNumber:
            cardNumber = value
        case .cardCvv:
            cvv = value
        case .cardExpiryDate:
            cardExpiration = value
        case .fingerprintType:
            fingerprintType = value
        case .currencyType:
            currency = value
        default:
            break
        }
    }
}

