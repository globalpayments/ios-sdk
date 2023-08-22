import Foundation
import GlobalPayments_iOS_SDK

protocol OpenBankingViewInput {
    func fasterPaymentTransation(_ form: FasterPaymentsForm)
    func sepaPaymentTransation(_ form: SepaPaymentsForm)
}

protocol OpenBankingViewOutput: AnyObject {
    func showErrorView(error: Error?)
    func showUrlOpen(_ url: URL, transaction: Transaction)
}

final class OpenBankingViewModel: OpenBankingViewInput {
    
    weak var view: OpenBankingViewOutput?
    private let CURRENCY = "GBP"
    
    func fasterPaymentTransation(_ form: FasterPaymentsForm) {
        let bankPayment = fasterPaymentsConfig(form)
        bankPayment.charge(amount: 17.57)
            .withCurrency(CURRENCY)
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute(completion: showOutput)
    }
    
    func sepaPaymentTransation(_ form: SepaPaymentsForm) {
        let bankPayment = sepaConfig(form)
        bankPayment.charge(amount: 20.00)
            .withCurrency("EUR")
            .withRemittanceReference(.TEXT, value: "Nike Bounce Shoes")
            .execute(completion: showOutput)
    }
    
    private func fasterPaymentsConfig(_ form: FasterPaymentsForm) -> BankPayment {
        let bankPayment = BankPayment()
        bankPayment.accountNumber = form.accountNumber
        bankPayment.sortCode = form.sortCode
        bankPayment.accountName = form.accountName
        bankPayment.countries = ["GB", "IE"]
        bankPayment.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        bankPayment.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        return bankPayment
    }
    
    private func sepaConfig(_ form: SepaPaymentsForm) -> BankPayment {
        let bankPayment = BankPayment()
        bankPayment.iban = form.iban
        bankPayment.accountName = form.accountName
        bankPayment.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        bankPayment.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        return bankPayment
    }
    
    private func showOutput(transaction: Transaction?, error: Error?) {
        UI {
            guard let transaction = transaction else {
                self.view?.showErrorView(error: error)
                return
            }
            
            if let urlMerchant = transaction.bankPaymentResponse?.redirectUrl, let url = URL(string: urlMerchant) {
                self.view?.showUrlOpen(url, transaction: transaction)
            }
        }
    }
}

struct FasterPaymentsForm {
    let accountNumber: String
    let sortCode: String
    let accountName: String
}

struct SepaPaymentsForm {
    let iban: String
    let accountName: String
}
