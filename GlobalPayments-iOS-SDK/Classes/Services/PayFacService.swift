import Foundation

public class PayFacService {
    
    public static func createMerchant() -> PayFacBuilder<User> {
        PayFacBuilder<User>(transactionType: .create, transactionModifier: .merchant)
    }
    
    public static func getMerchantInfo(_ merchantId: String) -> PayFacBuilder<User> {
        let userReference = UserReference()
        userReference.userId = merchantId
        userReference.userType = .merchant
        return PayFacBuilder<User>(transactionType: .fetch)
            .withModifier(.merchant)
            .withUserReference(userReference)
    }
}
