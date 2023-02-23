import Foundation
import GlobalPayments_iOS_SDK

protocol AchViewInput {
    func doAchTransaction(from form: AchChargeForm, path: AchPath)
}

protocol AchViewOutput: AnyObject{
    func showErrorView(error: Error?)
    func showTransaction(_ transaction: Transaction)
}

final class AchViewModel: AchViewInput {

    weak var view: AchViewOutput?

    func doAchTransaction(from form: AchChargeForm, path: AchPath) {
        let eCheckData = eCheck()

        let billingAddress = Address()
        billingAddress.streetAddress1 = form.billingAddress.line1
        billingAddress.streetAddress2 = form.billingAddress.line2
        billingAddress.city = form.billingAddress.city
        billingAddress.postalCode = form.billingAddress.postalCode
        billingAddress.state = form.billingAddress.state
        billingAddress.countryCode = form.billingAddress.country

        eCheckData.accountNumber = form.bankDetails.accountNumber
        eCheckData.routingNumber = form.bankDetails.routingNumber
        eCheckData.accountType = AccountType(rawValue: form.bankDetails.accountType)
        eCheckData.secCode = form.bankDetails.secCode
        eCheckData.checkHolderName = form.bankDetails.accountHolderName

        let customer = Customer()
        customer.firstName = form.customerDetails.firstName
        customer.lastName = form.customerDetails.lastName
        customer.mobilePhone = form.customerDetails.mobilePhone
        customer.homePhone = form.customerDetails.homePhone
        customer.dateOfBirth = form.customerDetails.birthDate

        switch path {
        case .charge:
            eCheckData.charge(amount: form.amount)
                .withCurrency(form.currency)
                .withAddress(billingAddress)
                .withCustomer(customer)
                .execute(completion: showOutput)
        case .refund:
            eCheckData.refund(amount: form.amount)
                .withCurrency(form.currency)
                .withAddress(billingAddress)
                .withCustomer(customer)
                .execute(completion: showOutput)
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
