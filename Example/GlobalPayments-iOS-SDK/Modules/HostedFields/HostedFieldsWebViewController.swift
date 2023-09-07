import UIKit

protocol TokenizedCardDataDelegate: AnyObject {
    func tokenizedCard(token: String, cardBrand: String)
}

final class HostedFieldsWebViewController: UIViewController, StoryboardInstantiable  {
    
    static let storyboardName = "HostedFieldsWebView"
    weak var delegate: TokenizedCardDataDelegate?
    
    @IBOutlet weak var supportView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = HostedFieldsWebView.instantiateFromNib(token)
        webView.delegate = self
        supportView.addSubview(webView)
        activityIndicatorView.stopAnimating()
    }
}

extension HostedFieldsWebViewController: HostedFieldsWebViewOutput {
    
    func onTokenError() {
        supportView.isHidden = false
        activityIndicatorView.stopAnimating()
    }
    
    func onTokenizedSuccess(token: String, cardBrand: String) {
        delegate?.tokenizedCard(token: token, cardBrand: cardBrand)
        supportView.isHidden = false
        activityIndicatorView.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    
    
    func onSubmitAction() {
        supportView.isHidden = true
        activityIndicatorView.startAnimating()
    }
}
