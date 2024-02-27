import Foundation

public class User: NSObject {
    /// This is a label to identify the user
    public var name: String?
    /// Global Payments time indicating when the object was created in ISO-8601 format.
    public var timeCreated: String?
    /// The date and time the resource object was last changed.
    public var timeLastUpdated: String?
    public var email: String?
    public var addresses: [Address]?
    public var contactPhone: PhoneNumber?
    /// A further description of the status of merchant boarding.
    public var statusDescription: String?
    /// The result of the action executed.
    public var responseCode: String?
    public var userReference: UserReference?
    public var personList: [Person]?

    public var paymentMethods: [PaymentMethodList]?
    
    public var fundsAccountDetails: FundsAccountDetails?
    
    /// Creates an `User` object from an existing user ID.
    /// - Parameters:
    ///   - userId: User id
    ///   - userType: User type
    /// - Returns: User
    public static func fromId(from userId: String, userType: UserType) -> User {
        let user = User()
        user.userReference = UserReference()
        user.userReference?.userId = userId
        user.userReference?.userType = userType
        return user
    }

    public func edit() -> PayFacBuilder<User> {
        var builder = PayFacBuilder<User>(transactionType: .edit)
            .withUserReference(userReference)
        
        if let userType = userReference?.userType {
            builder = builder.withModifier(TransactionModifier(value: userType.rawValue))
        }
        return builder
    }
    
    public func addFunds() -> PayFacBuilder<User> {
        var builder = PayFacBuilder<User>(transactionType: .addFunds)
            .withUserReference(userReference)
        
        if let userType = userReference?.userType {
            builder = builder.withModifier(TransactionModifier(value: userType.rawValue))
        }
        return builder
    }
}
