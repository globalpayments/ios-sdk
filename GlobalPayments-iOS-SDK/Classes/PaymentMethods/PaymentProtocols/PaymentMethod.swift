import Foundation

public protocol PaymentMethod {
    var paymentMethodType: PaymentMethodType { get set }
}
