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

final class PaypalViewModel: BaseViewModel {
    
    weak var view: PaypalViewOutput?
    private var paymentMethod: AlternatePaymentMethod
    private var pendingTransaction: Transaction?
    private var currentType: PaypalType = .charge
    private var amount: NSDecimalNumber?
    
    var enableButtons: Dynamic<Bool> = Dynamic(false)
    var openWebView: Dynamic<URL> = Dynamic(URL(fileURLWithPath: ""))
    
    override init() {
        paymentMethod = AlternatePaymentMethod()
        paymentMethod.alternativePaymentMethodType = .PAYPAL
        paymentMethod.returnUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.statusUpdateUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.cancelUrl = "https://7b8e82a17ac00346e91e984f42a2a5fb.m.pipedream.net"
        paymentMethod.descriptor = "Test Transaction"
        paymentMethod.country = "GB"
        paymentMethod.accountHolderName = "James Mason"
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .amount:
            amount = NSDecimalNumber(string: value)
        default:
            break
        }
        validateFields()
    }
    
    private func validateFields() {
        guard let amount = amount, amount.doubleValue > 0.0 else {
            enableButtons.value = false
            return
        }
        enableButtons.value = true
    }
    
    func chargeTrasaction() {
        showLoading.executer()
        paymentMethod.charge(amount: amount)
            .withCurrency("USD")
            .withDescription("New APM IOS")
            .execute { [weak self] in self?.handleResponse($0, $1) }
    }
    
    func authorizeTransaction() {
        showLoading.executer()
        paymentMethod.authorize(amount: amount)
            .withCurrency("USD")
            .withDescription("New APM IOS")
            .execute { [weak self] in self?.handleResponse($0, $1) }
    }
    
    private func handleResponse(_ transaction: Transaction?,_ error: Error?) {
        UI {
            guard let transaction = transaction else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            self.handleTransaction(transaction)
        }
    }
    
    private func handleTransaction(_ transaction: Transaction) {
        pendingTransaction = transaction
        if let url = URL(string: transaction.alternativePaymentResponse?.redirectUrl ?? "") {
            self.openWebView.value = url
        }else {
            self.hideLoading.executer()
        }
    }
    
    func validateTransaction() {
        guard let transaction = pendingTransaction else {
            showDataResponse.value = (.error, GatewayException(message: "Transaction can't be empty"))
            return
        }
        let service = ReportingService.findTransactionsPaged(page: 1, pageSize: 1)
        let startDate = Date()
        
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
                    .execute{ [weak self] transaction, error in
                        UI {
                            guard let transaction = transaction else {
                                if let error = error as? GatewayException {
                                    self?.showDataResponse.value = (.error, error)
                                }
                                return
                            }
                            self?.showDataResponse.value = (.success, transaction)
                            self?.pendingTransaction = nil
                            self?.hideLoading.executer()
                        }
                    }
            } else {
                UI {
                    self.showDataResponse.value = (.error, GatewayException(message: "There's not pending transaction"))
                }
            }
        }else {
            UI {
                self.showDataResponse.value = (.error, GatewayException(message: "There's not transactions"))
            }
        }
    }
}
