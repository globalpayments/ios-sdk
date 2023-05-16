import Foundation

public class AlternativePaymentResponse: NSObject {
    /// bank account details
    public var bankAccount: String?
    /// Account holder name of the customer’s account
    public var accountHolderName: String?
    /// 2 character ISO country code
    public var country: String?
    /// URL to redirect the customer to - only available in PENDING asynchronous transactions.
    /// Sent there so merchant can redirect consumer to complete an interrupted payment.
    public var redirectUrl: String?
    /// This parameter reflects what the customer will see on the proof of payment
    /// (for example, bank statement record and similar). Also known as the payment descriptor
    public var paymentPurpose: String?
    public var paymentMethod: String?
    public var providerReference: String?
    public var providerName: String?
    public var ack: String?
    public var sessionToken: String?
    public var correlationReference: String?
    public var versionReference: String?
    public var buildReference: String?
    public var timeCreatedReference: Date?
    public var transactionReference: String?
    public var secureAccountReference: String?
    public var reasonCode: String?
    public var pendingReason: String?
    public var grossAmount: NSDecimalNumber?
    public var paymentTimeReference: Date?
    public var paymentType: String?
    public var paymentStatus: String?
    public var type: String?
    public var protectionEligibility: String?
    public var authStatus: String?
    public var authAmount: NSDecimalNumber?
    public var authAck: String?
    public var authCorrelationReference: String?
    public var authVersionReference: String?
    public var authBuildReference: String?
    public var authPendingReason: String?
    public var authProtectionEligibility: String?
    public var authProtectionEligibilityType: String?
    public var authReference: String?
    public var feeAmount: NSDecimalNumber?
}

extension AlternativePaymentResponse: JsonToObject {
    
    public static func mapToObject<T>(_ json: JsonDoc) -> T? {
        let apm = AlternativePaymentResponse()
        if let paymentMethodApm: JsonDoc = json.get(valueFor: "apm") {
            apm.redirectUrl = json.getValue(key: "redirect_url")
            apm.providerName = paymentMethodApm.getValue(key: "provider")
            apm.ack = paymentMethodApm.getValue(key: "ack")
            apm.sessionToken = paymentMethodApm.getValue(key: "session_token")
            apm.correlationReference = paymentMethodApm.getValue(key: "correlation_reference")
            apm.versionReference = paymentMethodApm.getValue(key: "version_reference")
            apm.buildReference = paymentMethodApm.getValue(key: "build_reference")
            apm.transactionReference = paymentMethodApm.getValue(key: "transaction_reference")
            apm.secureAccountReference = paymentMethodApm.getValue(key: "secure_account_reference")
            apm.reasonCode = paymentMethodApm.getValue(key: "reason_code")
            apm.pendingReason = paymentMethodApm.getValue(key: "pending_reason")
            apm.grossAmount = paymentMethodApm.getValue(key: "gross_amount")
            apm.paymentType = paymentMethodApm.getValue(key: "payment_type")
            apm.paymentStatus = paymentMethodApm.getValue(key: "payment_status")
            apm.type = paymentMethodApm.getValue(key: "type")
            apm.protectionEligibility = paymentMethodApm.getValue(key: "protection_eligibilty")
            apm.feeAmount = paymentMethodApm.getValue(key: "fee_amount")
            apm.providerReference = paymentMethodApm.getValue(key: "provider_reference")
            
            apm.timeCreatedReference = paymentMethodApm.getValue(key: "time_created_reference")
            apm.paymentTimeReference = paymentMethodApm.getValue(key: "payment_time_reference")
        }
        
        if let authorization: JsonDoc = json.get(valueFor: "authorization") {
            apm.authStatus = authorization.getValue(key: "status")
            apm.authAmount = authorization.getValue(key: "amount")
            apm.authAck = authorization.getValue(key: "ack")
            apm.authCorrelationReference = authorization.getValue(key: "correlation_reference")
            apm.authVersionReference = authorization.getValue(key: "version_reference")
            apm.authBuildReference = authorization.getValue(key: "build_reference")
            apm.authPendingReason = authorization.getValue(key: "pending_reason")
            apm.authProtectionEligibility = authorization.getValue(key: "protection_eligibilty")
            apm.authProtectionEligibilityType = authorization.getValue(key: "protection_eligibilty_type")
            apm.authReference = authorization.getValue(key: "reference")
        }
        return apm as? T
    }
}
