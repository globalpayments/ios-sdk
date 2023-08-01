import Foundation
import GlobalPayments_iOS_SDK

protocol CaptureBnplViewInput {
    func onCaptureTransaction()
    func onReverseTransaction()
    func validateTransactionId()
    var transactionId: String { get set }
}

protocol CaptureBnplViewOutput: AnyObject{
    func showErrorView(error: Error?)
    func showTransaction(_ transaction: Transaction)
    func setTransactionId(_ value: String)
}

final class CaptureBnplViewModel: CaptureBnplViewInput {
    
    var transactionId: String
    weak var view: CaptureBnplViewOutput?
    
    init(transactionId: String) {
        self.transactionId = transactionId
    }
    
    func validateTransactionId() {
        view?.setTransactionId(transactionId)
    }
    
    func onCaptureTransaction() {
        let transaction = Transaction.fromId(transactionId: transactionId, paymentMethodType: .BPNL)
        transaction.capture()
            .execute(completion: showOutput)
    }
    
    func onReverseTransaction() {
        let transaction = Transaction.fromId(transactionId: transactionId, paymentMethodType: .BPNL)
        transaction.reverse()
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
