import Foundation
import GlobalPayments_iOS_SDK

protocol VerificationsViewModelInput {
    func verifyTransaction(from form: VerificationsForm)
}

protocol VerificationsViewModelOutput: class {
    func showErrorView(error: Error?)
    func showTransaction(_ transaction: Transaction)
}

final class VerificationsViewModel: VerificationsViewModelInput {
    weak var view: VerificationsViewModelOutput?

    func verifyTransaction(from form: VerificationsForm) {

        let address = Address()
        address.country = form.country
        address.streetAddress1 = form.avsAddress
        address.postalCode = form.avsPostalCode

        let card = CreditCardData()
        card.number = form.cardNumber
        card.expMonth = form.expiryMonth
        card.expYear = form.expiryYear
        card.cvn = form.cvn

        card.verify()
            .withCurrency(form.currency)
            .withAddress(address)
            .withFirstName(form.firstName)
            .withLastName(form.lastName)
            .withClientTransactionId(form.reference)
            .withId(form.id)
            .withIdempotencyKey(form.idempotencyKey)
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
