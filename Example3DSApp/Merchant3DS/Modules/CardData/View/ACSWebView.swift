import UIKit
import WebKit

let overrideConsole = """
    function log(emoji, type, args) {
      window.webkit.messageHandlers.logging.postMessage(
        `${emoji} JS ${type}: ${Object.values(args)
          .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v) : v.toString())
          .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
          .join(", ")}`
      )
    }

    let originalLog = console.log
    let originalWarn = console.warn
    let originalError = console.error
    let originalDebug = console.debug

    console.log = function() { log("📗", "log", arguments); originalLog.apply(null, arguments) }
    console.warn = function() { log("📙", "warning", arguments); originalWarn.apply(null, arguments) }
    console.error = function() { log("📕", "error", arguments); originalError.apply(null, arguments) }
    console.debug = function() { log("📘", "debug", arguments); originalDebug.apply(null, arguments) }

    window.addEventListener("error", function(e) {
       log("💥", "Uncaught", [`${e.message} at ${e.filename}:${e.lineno}:${e.colno}`])
    })
"""

protocol ACSWebViewOutput: NSObject {
    func onSubmitAction()
    func onTokenError()
    func onTokenizedSuccess(token: String, cardType: String)
}

final class ACSWebView: UIView {

    private var webView: WKWebView?
    weak var delegate: ACSWebViewOutput?
    private var token: String?

    class func instantiateFromNib(_ token: String) -> ACSWebView {
        let nib = UINib(nibName: "ACSWebView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! ACSWebView

        nib.initialiseWebView(token)
        nib.clipsToBounds = true

        return nib
    }
    
    var scriptString: String {
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

    //1. Capture Cardholder Data
    private func initialiseWebView(_ token: String) {
        self.token = token
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "logging")
        userContentController.add(self, name: "onSubmitAction")
        userContentController.add(self, name: "onTokenError")
        userContentController.add(self, name: "onTokenizedSuccess")
        userContentController.addUserScript(WKUserScript(source: overrideConsole, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        let js = scriptString
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        userContentController.addUserScript(script)

        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController
        
        webView = WKWebView(frame: bounds, configuration: webViewConfig)
        webView?.backgroundColor = .white
        webView?.navigationDelegate = self
        addSubview(webView!)
        
        // Adding webView content
        do {
            guard let filePath = Bundle.main.path(forResource: "cardData", ofType: "html")
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

extension ACSWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation) {
        let dict = [
            "token": self.token
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        webView.evaluateJavaScript("initGpLibrary(\(jsonString))") { result, error in
            guard error == nil else {
                print(error ?? "")
                return
            }
        }
    }
    
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        print(navigationResponse)
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

extension ACSWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        UI {
            switch message.name {
            case "onSubmitAction":
                self.delegate?.onSubmitAction()
                break
            case "onTokenizedSuccess":
                let token = message.body as! [String: String]
                guard let paymentReference = token["paymentReference"], let cardType = token["cardType"] else {
                    self.delegate?.onTokenError()
                    return
                }
                print("PaymentReference:: \(paymentReference)")
                self.delegate?.onTokenizedSuccess(token: paymentReference, cardType: cardType)
                break
            case "onTokenError":
                print("onTokenError:: \(message.body as? String)")
                self.delegate?.onTokenError()
                break
            default:
                break
            }
        }
    }
}
