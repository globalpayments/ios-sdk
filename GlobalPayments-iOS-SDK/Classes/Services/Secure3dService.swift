import Foundation

public class Secure3dService {

    public static func checkEnrollment(paymentMethod: PaymentMethod?) -> Secure3dBuilder {
        Secure3dBuilder(transactionType: .verifyEnrolled)
            .withPaymentMethod(paymentMethod)
    }

    public static func initiateAuthentication(paymentMethod: PaymentMethod?, secureEcom: ThreeDSecure?) -> Secure3dBuilder {
        let method = paymentMethod
        if (method as? Secure3d) != nil {
            (method as? Secure3d)?.threeDSecure = secureEcom
        }
        return Secure3dBuilder(transactionType: .initiateAuthentication)
            .withPaymentMethod(method)
    }

    public static func getAuthenticationData() -> Secure3dBuilder {
        Secure3dBuilder(transactionType: .verifySignature)
    }
}
