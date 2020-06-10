import Foundation

@objc public protocol Encryptable {
    var encryptionData: EncryptionData? { get set }
}
