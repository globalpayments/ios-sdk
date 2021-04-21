import Foundation
import GlobalPayments_iOS_SDK

protocol PaymentMethodReportInput {
    func getPaymentMethodById(_ id: String)
}

protocol PaymentMethodReportOutput: class {
    func showError(error: Error?)
    func showTransaction(_ transaction: Transaction)
}

final class PaymentMethodReportViewModel: PaymentMethodReportInput {

    weak var view: PaymentMethodReportOutput?

    func getPaymentMethodById(_ id: String) {
        let tokenizedCard = CreditCardData()
        tokenizedCard.token = id
        tokenizedCard
            .verify()
            .execute(completion: handleResponse)
    }

    private func handleResponse(transaction: Transaction?, error: Error?) {
        UI { [weak self] in
            guard let transaction = transaction else {
                self?.view?.showError(error: error)
                return
            }
            self?.view?.showTransaction(transaction)
        }
    }
}
