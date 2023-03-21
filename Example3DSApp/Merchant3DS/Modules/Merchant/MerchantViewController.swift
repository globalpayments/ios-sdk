import UIKit

protocol TokenizedCardDataDelegate: AnyObject {
    func tokenizedCard(token: String, cardType: String)
}

final class MerchantViewController: UIViewController, StoryboardInstantiable  {
    
    static let storyboardName = "Merchant"
    weak var delegate: TokenizedCardDataDelegate?
    
    @IBOutlet weak var supportView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let acsWebView = ACSWebView.instantiateFromNib(token)
        acsWebView.delegate = self
        supportView.addSubview(acsWebView)
        activityIndicatorView.stopAnimating()
    }
}

extension MerchantViewController: ACSWebViewOutput {
    func onTokenError() {
        supportView.isHidden = false
        activityIndicatorView.stopAnimating()
    }
    
    func onTokenizedSuccess(token: String, cardType: String) {
        delegate?.tokenizedCard(token: token, cardType: cardType)
        supportView.isHidden = false
        activityIndicatorView.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    
    
    func onSubmitAction() {
        supportView.isHidden = true
        activityIndicatorView.startAnimating()
    }
}

