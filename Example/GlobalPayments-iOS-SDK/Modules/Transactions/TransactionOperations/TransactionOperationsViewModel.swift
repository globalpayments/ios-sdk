import Foundation
import GlobalPayments_iOS_SDK

protocol TransactionOperationsInput {
    func getTransaction(from form: TransactionOperationsForm)
}

protocol TransactionOperationsOutput: class {
    func showErrorView(error: Error?)
    func showTransaction(_ transaction: Transaction)
}

final class TransactionOperationsViewModel: TransactionOperationsInput {

    weak var view: TransactionOperationsOutput?

    func getTransaction(from form: TransactionOperationsForm) {
        let card = CreditCardData()
        card.number = form.cardNumber
        card.expMonth = form.expiryMonth
        card.expYear = form.expiryYear
        card.cvn = form.cvv

        switch form.transactionOperationType {
        case .authorization:
            card.authorize(amount: form.amount)
                .withCurrency(form.currency)
                .withIdempotencyKey(form.idempotencyKey)
                .execute(completion: showOutput)
        case .sale:
            card.charge(amount: form.amount)
                .withCurrency(form.currency)
                .withIdempotencyKey(form.idempotencyKey)
                .execute(completion: showOutput)
        case .capture:
            card.authorize(amount: form.amount)
                .withCurrency(form.currency)
                .withIdempotencyKey(form.idempotencyKey)
                .execute { [weak self] transaction, error in
                    guard let transaction = transaction else {
                        self?.showOutput(transaction: nil, error: error)
                        return
                    }
                    transaction
                        .capture(amount: form.amount)
                        .execute(completion: self?.showOutput)
                }
        case .refund:
            card.refund(amount: form.amount)
                .withCurrency(form.currency)
                .withIdempotencyKey(form.idempotencyKey)
                .execute(completion: showOutput)
        case .reverse:
            card.charge(amount: form.amount)
                .withCurrency(form.currency)
                .withIdempotencyKey(form.idempotencyKey)
                .execute { [weak self] transaction, error in
                    guard let transaction = transaction else {
                        self?.showOutput(transaction: nil, error: error)
                        return
                    }
                    transaction
                        .reverse(amount: form.amount)
                        .execute(completion: self?.showOutput)
                }
        }
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
