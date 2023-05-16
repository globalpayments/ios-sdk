import Foundation
import GlobalPayments_iOS_SDK

protocol PaypalViewInput {
    func doPaypalTransaction(_ amount: String?)
    func setType(_ type: String)
    func validateTransaction()
}

protocol PaypalViewOutput: AnyObject{
    func showErrorView(error: Error?)
    func showTransaction(_ transaction: Transaction)
}

final class PaypalViewModel: PaypalViewInput {
    
    weak var view: PaypalViewOutput?
    private var paymentMethod: AlternatePaymentMethod
    private var pendingTransaction: Transaction?
    private var currentType: PaypalType = .charge
    
    init() {
        paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .PAYPAL
        paymentMethod.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.cancelUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.descriptor = "Test Transaction"
        paymentMethod.country = "GB"
        paymentMethod.accountHolderName = "James Mason"
    }
    
    func doPaypalTransaction(_ amount: String? = nil) {
        
        if let amount = amount {
            switch currentType {
            case .charge:
                paymentMethod.charge(amount: NSDecimalNumber(string: amount))
                    .withCurrency("USD")
                    .withDescription("New APM IOS")
                    .execute { [weak self] transaction, error in
                        self?.pendingTransaction = transaction
                        self?.showOutput(transaction: transaction, error: error)
                        UI {
                            if let url = URL(string: transaction?.alternativePaymentResponse?.redirectUrl ?? "") {
                                UIApplication.shared.open(url)
                                sleep(30)
                                self?.validateTransaction()
                            }
                        }
                    }
                break
            case .authorize:
                paymentMethod.authorize(amount: NSDecimalNumber(string: amount))
                    .withCurrency("USD")
                    .withDescription("New APM IOS")
                    .execute { [weak self] transaction, error in
                        self?.pendingTransaction = transaction
                        self?.showOutput(transaction: transaction, error: error)
                        UI {
                            if let url = URL(string: transaction?.alternativePaymentResponse?.redirectUrl ?? "") {
                                UIApplication.shared.open(url)
                                sleep(20)
                                self?.validateTransaction()
                            }
                        }
                    }
                break
            }
        }
    }
    
    func setType(_ type: String) {
        guard let type = PaypalType(rawValue: type) else { return }
        currentType = type
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
    
    func validateTransaction() {
        guard let transaction = pendingTransaction else { return }
        let service = ReportingService.findTransactionsPaged(page: 1, pageSize: 1)
        let startDate = Date()
        
        // WHEN
        service.withTransactionId(transaction.transactionId)
            .where(.startDate, startDate)
            .and(searchCriteria: .endDate, value: startDate)
            .execute(completion: findTransactionAndValidate)
    }
    
    private func findTransactionAndValidate(responseFind: PagedResult<TransactionSummary>?, error: Error?){
        if let transactionSummary = responseFind?.results.first {
            if let transactionId = transactionSummary.transactionId, transactionSummary.transactionStatus == .pending {
                let transaction = Transaction.fromId(transactionId: transactionId, paymentMethodType: .apm)
                transaction.alternativePaymentResponse = transactionSummary.alternativePaymentResponse
                transaction.confirm()
                    .execute{ [weak self]transaction, error in
                        UI {
                            guard let transaction = transaction else {
                                self?.view?.showErrorView(error: error)
                                return
                            }
                            self?.view?.showTransaction(transaction)
                            self?.pendingTransaction = nil
                        }
                    }
            }
        }
    }
}
