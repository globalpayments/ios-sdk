import Foundation
import GlobalPayments_iOS_SDK
import PassKit

class DigitalWalletsViewModel: BaseViewModel {
    
    var paymentGenerated: Dynamic<PKPaymentRequest?> = Dynamic(nil)
    var defaultValues: Dynamic<Void> = Dynamic(())
    private var amount: NSDecimalNumber?
    
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
        paymentRequest.currencyCode = "USD"

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
        if let tokenGenerated = tokenGenerated, !tokenGenerated.isEmpty {
            showDataResponse.value = (.success, MessageResponse(message: "Token Generated \(tokenGenerated)"))
        }else {
            showDataResponse.value = (.error, ApiException(message: "Run on Real Device To Generate Token"))
        }
    }
}
