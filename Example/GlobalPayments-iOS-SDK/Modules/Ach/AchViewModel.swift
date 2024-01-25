import Foundation
import GlobalPayments_iOS_SDK

final class AchViewModel: BaseViewModel {
    
    private var useCase: AchChargeUseCase = AchChargeUseCase()
    private var form: AchChargeForm = AchChargeForm()
    var enableButton: Dynamic<Bool> = Dynamic(false)

    func doAchTransaction(path: TransactionTypePath) {
        showLoading.executer()
        form = useCase.form
        form.currency = "USD"
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
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            self.showDataResponse.value = (.success, transaction)
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        useCase.fieldDataChanged(value: value, type: type)
        validateFields()
    }
    
    private func validateFields() {
        enableButton.value = useCase.validateFields()
    }
}
