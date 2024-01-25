import Foundation
import GlobalPayments_iOS_SDK

final class PaymentOperationFormViewModel: BaseViewModel {
    
    private var methodUsage: PaymentMethodUsageMode = .single
    private var operationType: PaymentMethodOperationType = .tokenize
    private var cardNumber: String = ""
    private var cardExpiration: String = ""
    private var cvv: String = ""
    private var token: String = ""
    private var cardHolderName: String = ""
    private var currency: String = ""
    private var fingerprintType: String = ""

    func onSubmitPressed() {
        showLoading.executer()
        
        if operationType != .tokenize {
            guard !token.isEmpty else {
                self.showDataResponse.value = (.error, GatewayException(message: "Payment Id can't be empty"))
                return
            }
        }
        
        let dateExpSplit = cardExpiration.split(separator: "/")
        let month = Int(dateExpSplit[0]) ?? 0
        let year = Int(dateExpSplit[1]) ?? 0
        
        let form = PaymentOperationForm(
            operationType: operationType,
            methodUsageMode: methodUsage,
            paymentMethodId: token,
            cardNumber: cardNumber,
            cardExpiryMonth: month,
            cardExpiryYear: year,
            cvn: cvv
        )
        
        performOperation(from: form)
    }

    private func showOutput(token: Any?, error: Error?) {
        UI {
            guard let token = token else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            
            let message = MessageResponse(message: "\(token)")
            self.showDataResponse.value = (.success, message)
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .paymentOperation:
            operationType = PaymentMethodOperationType(value: value) ?? .tokenize
        case .tokenUsage:
            methodUsage = PaymentMethodUsageMode(value: value) ?? .single
        case .cardNumber:
            cardNumber = value
        case .cardHolderName:
            cardHolderName = value
        case .cardCvv:
            cvv = value
        case .cardExpiryDate:
            cardExpiration = value
        case .currencyType:
            currency = value
        case .paymentId:
            token = value
        case .fingerprintType:
            fingerprintType = value
        default:
            break
        }
    }
    
    func performOperation(from form: PaymentOperationForm) {
        switch form.operationType {
        case .tokenize:
            let card = CreditCardData()
            card.number = form.cardNumber
            card.expYear = form.cardExpiryYear
            card.expMonth = form.cardExpiryMonth
            card.cvn = form.cvn
            
            if !fingerprintType.isEmpty {
                var customer = Customer()
                customer.deviceFingerPrint = fingerprintType
                card.withCustomerData(customer)
            }
            
            card.tokenize(paymentMethodUsageMode: methodUsage, completion:showOutput)
        case .edit:
            edit(form)
        case .delete:
            let card = CreditCardData()
            card.token = form.paymentMethodId
            card.deleteToken(completion: showOutput)
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
        card.updateTokenExpiry(completion: showOutput)
    }
}
