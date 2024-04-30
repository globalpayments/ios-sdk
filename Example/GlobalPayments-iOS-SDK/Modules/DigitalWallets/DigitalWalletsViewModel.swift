import Foundation
import GlobalPayments_iOS_SDK
import PassKit

class DigitalWalletsViewModel: BaseViewModel {
    
    var paymentGenerated: Dynamic<PKPaymentRequest?> = Dynamic(nil)
    var defaultValues: Dynamic<Void> = Dynamic(())
    private var amount: NSDecimalNumber?
    private let currency = "USD"
    
    override func viewDidLoad() {
        defaultValues.executer()
    }
    
    func generatePaymentRequest() {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.com.gpapi.sandbox"
        paymentRequest.supportedNetworks = [
            PKPaymentNetwork.visa,
            PKPaymentNetwork.masterCard,
            PKPaymentNetwork.amex
        ]
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = currency

        let totalItem = PKPaymentSummaryItem(label: "Foobar", amount: amount ?? 0.0)
        paymentRequest.paymentSummaryItems = [totalItem]
        paymentGenerated.value = paymentRequest
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum){
        switch type {
        case .amount:
            amount = NSDecimalNumber(string: value)
        default:
            break
        }
    }
    
    func showTokenGenerated(_ tokenGenerated: String?) {
        if let tokenGenerated = tokenGenerated {
            showLoading.executer()
            chargeTokenApplePay(paymentToken: tokenGenerated)
        }else {
            showDataResponse.value = (.error, ApiException(message: "Run on Real Device To Generate Token"))
        }
    }
    
    func chargeTokenApplePay(paymentToken: String) {
        let card = CreditCardData()
        card.cardHolderName = "James Mason#"
        card.mobileType = EncryptedMobileType.APPLE_PAY.rawValue
        card.token = paymentToken
        card.charge(amount: amount)
            .withCurrency(currency)
            .withModifier(.encryptedMobile)
            .execute(completion: showOutput)
    }
    
    private func showOutput(transaction: Transaction?, error: Error?) {
        UI {
            self.hideLoading.executer()
            guard let transaction = transaction else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                } else if let error = error as? ApiException{
                    self.showDataResponse.value = (.error, error)
                } else {
                    self.showDataResponse.value = (.error, "Data Error")
                }
                return
            }
            self.showDataResponse.value = (.success, transaction)
        }
    }
}
