import Foundation

public protocol RequestLogger {
    func requestSent(request: String)
    func responseReceived(response: String)
}
