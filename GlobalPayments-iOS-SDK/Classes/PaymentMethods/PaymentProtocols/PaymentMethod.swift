import Foundation

public protocol PaymentMethod: NSObject {
    var paymentMethodType: PaymentMethodType { get set }
}
