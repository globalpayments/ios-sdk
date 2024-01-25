import Foundation
import GlobalPayments_iOS_SDK

final class PayLinkViewModel: BaseViewModel {
    
    var enableButton: Dynamic<Bool> = Dynamic(false)
    private var amount: NSDecimalNumber = 0.0
    private var description: String = ""
    private var usageMode: PaymentMethodUsageMode = .single
    private var usageLimit: String = "1"
    private var expirationDate: String = Date().format("yyyy-MM-dd")

    func doPayLinkTransaction() {
        showLoading.executer()
        let payLinkData = PayLinkData()
        payLinkData.type = .payment
        payLinkData.usageMode = usageMode
        payLinkData.allowedPaymentMethods = [ PaymentMethodName.card ]
        payLinkData.usageLimit = usageLimit
        payLinkData.name = description
        payLinkData.isShippable = false
        payLinkData.expirationDate = expirationDate.formattedDate("yyyy-MM-dd")
        payLinkData.images = []
        payLinkData.returnUrl = "https://www.example.com/returnUrl"
        payLinkData.statusUpdateUrl = "https://www.example.com/statusUrl"
        payLinkData.cancelUrl = "https://www.example.com/returnUrl"
        
        PayLinkService.create(payLink: payLinkData, amount: amount)
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
