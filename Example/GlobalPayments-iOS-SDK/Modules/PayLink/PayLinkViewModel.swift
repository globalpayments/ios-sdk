import Foundation
import GlobalPayments_iOS_SDK

protocol PayLinkViewInput {
    func doPayLinkTransaction(_ form: PayLinkForm)
}

protocol PayLinkViewOutput: AnyObject{
    func showErrorView(error: Error?)
    func showTransaction(_ transaction: Transaction)
}

final class PayLinkViewModel: PayLinkViewInput {

    weak var view: PayLinkViewOutput?

    func doPayLinkTransaction(_ form: PayLinkForm) {
        let payLinkData = PayLinkData()
        payLinkData.type = .payment
        payLinkData.usageMode = PaymentMethodUsageMode(value: form.usageMode)
        payLinkData.allowedPaymentMethods = [ PaymentMethodName.card ]
        payLinkData.usageLimit = form.usageLimit
        payLinkData.name = form.name
        payLinkData.isShippable = false
        payLinkData.expirationDate = form.expirationDate.formattedDate("yyyy-MM-dd")
        payLinkData.images = []
        payLinkData.returnUrl = "https://www.example.com/returnUrl"
        payLinkData.statusUpdateUrl = "https://www.example.com/statusUrl"
        payLinkData.cancelUrl = "https://www.example.com/returnUrl"
        
        PayLinkService.create(payLink: payLinkData, amount: form.amount)
            .withCurrency("GBP")
            .withClientTransactionId(UUID().uuidString)
            .withDescription(form.name)
            .execute(completion: showOutput)
    }

    private func showOutput(transaction: Transaction?, error: Error?) {
        UI {
            guard let transaction = transaction else {
                self.view?.showErrorView(error: error)
                return
            }
            self.view?.showTransaction(transaction)
        }
    }
}
