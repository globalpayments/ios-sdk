import Foundation
import GlobalPayments_iOS_SDK

final class PaymentMethodByIDViewModel: BaseViewModel {
    
    private lazy var paymentMethodId: String? = ""
    private lazy var currency: String? = "USD"
    
    
    func getPaymentMethodById() {
        showLoading.executer()
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = paymentMethodId
        tokenizedCard
            .verify()
            .withCurrency(currency)
            .execute(completion: showOutput)
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
        case .paymentMethodId:
            paymentMethodId = value
        case .currency:
            currency = value
        default:
            break;
        }
    }
}
