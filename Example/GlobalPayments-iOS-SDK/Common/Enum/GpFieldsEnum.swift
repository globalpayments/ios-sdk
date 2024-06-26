import Foundation

enum GpFieldsEnum: Int {
    
    case appId
    case appKey
    case secondsToExpire
    case env
    case interval
    case amount
    case cardNumber
    case cardHolderName
    case cardCvv
    case cardExpiryDate
    case description
    case expirationDate
    case usageMode
    case usageLimit
    case accountHolderName
    case accountType
    case secCode
    case routingNumber
    case accountNumber
    case firstName
    case lastName
    case dateOfBirth
    case mobilePhone
    case homePhone
    case line1
    case line2
    case postalCode
    case country
    case city
    case state
    case pinBlock
    case billing
    case shipping
    case countryCode
    case phoneNumber
    case phoneType
    case customer
    case paymentOperation
    case paymentId
    case tokenUsage
    case currencyType
    case fingerprintType
    case disputeId
    case idempotencyId
    case operationType
    case batchId
    case fromTimeCreated
    case toTimeCreated
    case fromTimeLastUpdated
    case toTimeLastUpdated
    case transactionId
    case depositId
    case page
    case pageSize
    case order
    case orderBy
    case brand
    case brandReference
    case reference
    case authCode
    case status
    case numberFirst6
    case numberLast4
    case type
    case channel
    case tokenFirst6
    case tokenLast4
    case entryMode
    case name
    case currency
    case accountName
    case id
    case maskedAccountNumber
    case systemMid
    case systemHierarchy
    case paymentMethodId
    case referenceNumber
    case actionId
    case appName
    case version
    case resource
    case merchantName
    case resourceId
    case responseCode
    case httpResponseCode
    case resourceStatus
    case arn
    case stage
    case accountId
    case cardEnv
    case language
    case merchantId
    case transactionProccesing
    case tokenization
    case challengeNotification
    case methodNotification
    case merchantContactUrl
    case statusUrl
    case merchantDocumentType
    case merchantDocumentCategory
    case none
    
    public init?(value: Int?) {
        guard let value = value,
              let status = GpFieldsEnum(rawValue: value) else { return nil }
        self = status
    }
}
