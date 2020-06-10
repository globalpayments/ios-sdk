import Foundation

@objc public protocol Secure3dProvider {
    func getVersion() -> Secure3dVersion
    func processSecure3d(_ builder: Secure3dBuilder) -> Transaction?
}
