import Foundation

public protocol Secure3dProvider {
    var version: Secure3dVersion { get }
    func processSecure3d(_ builder: Secure3dBuilder, _ completion: @escaping (Transaction?, Error?) -> Void)
}
