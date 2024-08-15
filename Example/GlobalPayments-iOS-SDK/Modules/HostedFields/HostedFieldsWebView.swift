import UIKit
import WebKit

protocol HostedFieldsWebViewOutput: NSObject {
    func onSubmitAction()
    func onTokenError(_ message: String)
    func onTokenizedSuccess(token: String, cardBrand: String)
}

final class HostedFieldsWebView: UIView {

    private var webView: WKWebView?
    weak var delegate: HostedFieldsWebViewOutput?
    private var token: String?
    var bundle: Bundle {
            return Bundle.main
        }

    class func instantiateFromNib(_ token: String) -> HostedFieldsWebView {
        let nib = UINib(nibName: "HostedFieldsView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! HostedFieldsWebView

        nib.initialiseWebView(token)
        nib.clipsToBounds = true

        return nib
    }
    
    private var scriptString: String {
        do {
            guard let filePath = Bundle.main.path(forResource: "script", ofType: "js")
            else {
                print ("File reading error")
                return ""
            }
            
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            return contents
        }
        catch {
            print ("File JS error")
            return ""
        }
    }
    
    private var gpScriptString: String {
        do {
            guard let filePath = Bundle.main.path(forResource: "globalpayments", ofType: "js")
            else {
                print ("File reading error")
                return ""
            }
            
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            return contents
        }
        catch {
            print ("File JS error")
            return ""
        }
    }

    //1. Capture Cardholder Data
    private func initialiseWebView(_ token: String) {
        self.token = token
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "logging")
        userContentController.add(self, name: "onSubmitAction")
        userContentController.add(self, name: "onTokenError")
        userContentController.add(self, name: "onTokenizedSuccess")
        let script = WKUserScript(source: scriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        userContentController.addUserScript(script)

        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController
        
        webView = WKWebView(frame: bounds, configuration: webViewConfig)
        webView?.navigationDelegate = self
        if #available(iOS 16.4, *) {
            webView?.isInspectable = true
        }
        addSubview(webView!)
        // Adding webView content
        do {
            guard let filePath = Bundle.main.path(forResource: "index", ofType: "html")
            else {
                print ("File reading error")
                return
            }

            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(string: "localhost:8080")
            webView?.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
}

extension HostedFieldsWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation) {
        guard let token  = self.token else { return }
        
        let dict = [
            "token": token
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        webView.evaluateJavaScript("initGlobalPayments(\(jsonString))") { result, error in
            guard error == nil else {
                return
            }
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
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

extension HostedFieldsWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        UI {
            switch message.name {
            case "onSubmitAction":
                self.delegate?.onSubmitAction()
                break
            case "onTokenizedSuccess":
                let token = message.body as! [String: String]
                guard let paymentReference = token["paymentReference"], let cardType = token["cardType"] else {
                    self.delegate?.onTokenError("Parameters can not be null")
                    return
                }
                self.delegate?.onTokenizedSuccess(token: paymentReference, cardBrand: cardType)
                break
            case "onTokenError":
                let message = message.body as? String ?? ""
                self.delegate?.onTokenError(message)
                break
            default:
                break
            }
        }
    }
}

