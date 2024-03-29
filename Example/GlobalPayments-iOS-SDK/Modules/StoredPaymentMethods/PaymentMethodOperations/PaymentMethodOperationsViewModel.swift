import Foundation
import GlobalPayments_iOS_SDK

protocol PaymentMethodOperationsInput {
    func performOperation(from form: PaymentOperationForm)
}

protocol PaymentMethodOperationsOutput: AnyObject {
    func showError(error: Error?)
    func showViewModels(models: [PaymentMethodResultModel])
}

final class PaymentMethodOperationsViewModel: PaymentMethodOperationsInput {

    weak var view: PaymentMethodOperationsOutput?

    func performOperation(from form: PaymentOperationForm) {

        switch form.operationType {
        case .tokenize:
            let card = CreditCardData()
            card.number = form.cardNumber
            card.expYear = form.cardExpiryYear
            card.expMonth = form.cardExpiryMonth
            card.cvn = form.cvn
            card.tokenize() { [weak self] token, error in
                UI {
                    guard let token = token else {
                        self?.view?.showError(error: error)
                        return
                    }
                    self?.view?.showViewModels(
                        models: PaymentMethodResultModelBuilder.buildTokenizeModels(token)
                    )
                }
            }
        case .edit:
            edit(form)
        case .delete:
            let card = CreditCardData()
            card.token = form.paymentMethodId
            card.deleteToken() { [weak self] result, error in
                UI {
                    if result == false {
                        self?.view?.showError(error: error)
                        return
                    }
                    self?.view?.showViewModels(
                        models: PaymentMethodResultModelBuilder.buildDeleteModels(result)
                    )
                }
            }
        }
    }
    
    private func edit(_ form: PaymentOperationForm){
        let card = CreditCardData()
        card.number = form.cardNumber
        card.expYear = form.cardExpiryYear
        card.expMonth = form.cardExpiryMonth
        card.cvn = form.cvn
        card.token = form.paymentMethodId
        card.methodUsageMode = form.methodUsageMode
        card.updateTokenExpiry() { [weak self] result, error in
            UI {
                if result == false {
                    self?.view?.showError(error: error)
                    return
                }
                self?.view?.showViewModels(
                    models: PaymentMethodResultModelBuilder.buildEditModels(result)
                )
            }
        }
    }
}
