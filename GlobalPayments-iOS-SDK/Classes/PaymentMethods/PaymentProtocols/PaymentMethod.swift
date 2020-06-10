import Foundation

@objc public protocol PaymentMethod {
    var paymentMethodType: PaymentMethodType { get set }
}
