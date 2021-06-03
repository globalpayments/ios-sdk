import UIKit
import WebKit
import GlobalPayments_iOS_SDK

final class ACSWebView: UIView, WKNavigationDelegate {

    private var webView: WKWebView?
    private var threeDSecure: ThreeDSecure?
    private var form: InitiateForm?

    var onFinishChallenge: ((InitiateForm?, ThreeDSecure?) -> Void)?

    class func instantiateFromNib() -> ACSWebView {
        let nib = UINib(nibName: "ACSWebView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! ACSWebView

        nib.initialiseWebView()
        nib.clipsToBounds = true

        return nib
    }

    private func initialiseWebView() {
        webView = WKWebView(frame: bounds)
        webView?.backgroundColor = .white
        webView?.navigationDelegate = self
        addSubview(webView!)
    }

    func load(form: InitiateForm, threeDSecure: ThreeDSecure) {
        self.form = form
        self.threeDSecure = threeDSecure
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let url = URL(string: threeDSecure.issuerAcsUrl!)!
        var request = URLRequest(url: url)
        let parameters = [
            "challenge_value": threeDSecure.payerAuthenticationRequest ?? "",
            "TermUrl": threeDSecure.challengeReturnUrl ?? "",
            (threeDSecure.sessionDataFieldName ?? ""): (threeDSecure.serverTransactionId ?? ""),
            (threeDSecure.messageType ?? ""): (threeDSecure.payerAuthenticationRequest ?? ""),
            "creq": threeDSecure.payerAuthenticationRequest ?? "",
            "threeDSSessionData": threeDSecure.serverTransactionId ?? ""
        ]

        request.encodeParameters(parameters: parameters)

        let task = URLSession(configuration: config).dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, data.count > 0 else { return }
                let htmlString = String(data: data, encoding: String.Encoding.utf8)
                self.webView?.loadHTMLString(htmlString!, baseURL: request.url)
            }
        }

        task.resume()
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation) {
        guard let title = webView.title, title.isEmpty else { return }
        onFinishChallenge?(form, threeDSecure)
    }

    /// Allow all requests to be loaded
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        decisionHandler(.allow)
    }

    /// Allow all navigation actions
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        decisionHandler(.allow)
    }
}
