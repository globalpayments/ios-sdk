import UIKit
import PassKit

final class DigitalWalletsViewController: UIViewController, StoryboardInstantiable {
    
    static let storyboardName = "DigitalWallets"
    
    @IBOutlet weak var applePayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "globalpay.digital.wallets".localized()
        applePayButton.apply(style: .globalPayStyle, title: "globalpay.apple.pay".localized())
    }
    
    @IBAction func onApplePayAction(_ sender: Any) {
        if (PKPaymentAuthorizationViewController.canMakePayments()) {
            let paymentRequest = PKPaymentRequest()
            paymentRequest.merchantIdentifier = "merchant.com.gpapi.sandbox"
            paymentRequest.supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
            paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
            paymentRequest.countryCode = "US"
            paymentRequest.currencyCode = "USD"
            
            let totalItem = PKPaymentSummaryItem(label:"Foobar", amount:NSDecimalNumber(string:"10.00"))
            paymentRequest.paymentSummaryItems = [totalItem]
            
            
            // Show the Apple Pay controller
            let payAuth = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            payAuth?.delegate = self
            self.present(payAuth!, animated:true, completion: nil)
        }
    }
}

extension DigitalWalletsViewController: PKPaymentAuthorizationViewControllerDelegate{

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion:(@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        
        print("Testing Pay: \(NSString(data:payment.token.paymentData, encoding:String.Encoding.utf8.rawValue)!)")
        completion(PKPaymentAuthorizationStatus.success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
