import Foundation
import GlobalPayments_iOS_SDK

final class AliPayViewModel: BaseViewModel {
    
    private var amount: NSDecimalNumber = 0.0
    private var accountHolderName: String = ""

    func doAliPayTransaction() {
        showLoading.executer()
        
        let paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .ALIPAY
        paymentMethod.returnUrl = "https://example.com/returnUrl"
        paymentMethod.statusUpdateUrl = "https://example.com/statusUrl"
        paymentMethod.country = "US"
        paymentMethod.accountHolderName = accountHolderName
        
        paymentMethod.charge(amount: amount)
            .withCurrency("HKD")
            .withMerchantCategory(.OTHER)
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
        case .amount:
            amount = NSDecimalNumber(string: value)
        case .cardHolderName:
            accountHolderName = value
        default:
            break
        }
    }
}

