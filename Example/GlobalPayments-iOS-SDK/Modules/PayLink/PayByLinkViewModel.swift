import Foundation
import GlobalPayments_iOS_SDK

final class PayByLinkViewModel: BaseViewModel {
    
    var enableButton: Dynamic<Bool> = Dynamic(false)
    private var amount: NSDecimalNumber = 0.0
    private var description: String = ""
    private var usageMode: PaymentMethodUsageMode = .single
    private var usageLimit: String = "1"
    private var expirationDate: String = Date().format("yyyy-MM-dd")

    func doPayByLinkTransaction() {
        showLoading.executer()
        let payByLinkData = PayByLinkData()
        payByLinkData.type = .payment
        payByLinkData.usageMode = usageMode
        payByLinkData.allowedPaymentMethods = [ PaymentMethodName.card ]
        payByLinkData.usageLimit = usageLimit
        payByLinkData.name = description
        payByLinkData.isShippable = false
        payByLinkData.expirationDate = expirationDate.formattedDate("yyyy-MM-dd")
        payByLinkData.images = []
        payByLinkData.returnUrl = "https://www.example.com/returnUrl"
        payByLinkData.statusUpdateUrl = "https://www.example.com/statusUrl"
        payByLinkData.cancelUrl = "https://www.example.com/returnUrl"
        
        PayByLinkService.create(payByLink: payByLinkData, amount: amount)
            .withCurrency("GBP")
            .withClientTransactionId(UUID().uuidString)
            .withDescription(description)
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
        case .usageMode:
            usageMode = PaymentMethodUsageMode(value: value) ?? .single
        case .usageLimit:
            usageLimit = value
        case .expirationDate:
            expirationDate = value
        case .description:
            description = value
        default:
            break
        }
        validateFields()
    }
    
    private func validateFields() {
        guard amount.doubleValue > 0.0,
              !description.isEmpty,
              !expirationDate.isEmpty else {
            enableButton.value = false
            return
        }
        enableButton.value = true
    }
}
