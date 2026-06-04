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
    /// Provider-specific redirect URL (e.g. for eRaty: apm.provider_redirect_url)
    public var providerRedirectUrl: String?
    /// APM category (e.g. "BNPL" for eRaty)
    public var category: String?
    /// Provider payer name returned in the eRaty response (apm.provider_payer_name)
    public var providerPayerName: String?
    /// Installment terms returned for eRaty (apm.terms)
    public var responseTerms: Terms?
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
    public var bank: BankResponse?
    /// apm.provider.confirmed_account_holder — returned in CAPTURED eRaty response
    public var confirmedAccountHolder: String?
    /// apm.provider.wait_notification — only set when non-empty
    public var waitNotification: String?
    /// apm.provider.fund_status — only set when non-empty
    public var fundStatus: String?
    /// apm.provider.payment_description — only set when non-empty
    public var paymentDescription: String?
    /// apm.provider.optional_redirect — only set when non-empty
    public var optionalRedirect: String?
}

extension AlternativePaymentResponse: JsonToObject {
    
    public static func mapToObject<T>(_ json: JsonDoc) -> T? {
        let apm = AlternativePaymentResponse()
        // Top-level payment_method redirect URL (used by eRaty and others)
        apm.redirectUrl = json.getValue(key: "redirect_url")
        if let paymentMethodApm: JsonDoc = json.get(valueFor: "apm") {
            // Prefer apm.redirect_url if present; otherwise keep payment_method.redirect_url
            if let apmRedirectUrl: String = paymentMethodApm.getValue(key: "redirect_url") {
                apm.redirectUrl = apmRedirectUrl
            }
            apm.providerRedirectUrl = paymentMethodApm.getValue(key: "provider_redirect_url")
            apm.category = paymentMethodApm.getValue(key: "category")
            apm.providerPayerName = paymentMethodApm.getValue(key: "provider_payer_name")
            if let termsDoc: JsonDoc = paymentMethodApm.get(valueFor: "terms") {
                let terms = Terms()
                terms.TimeUnit = termsDoc.getValue(key: "time_unit")
                // `count` may be returned as a string, number (Int/NSNumber) or Int64.
                // Try multiple conversions and assign as Int64 to match model.
                if let countInt64: Int64 = termsDoc.getValue(key: "count") {
                    terms.count = countInt64
                } else if let countInt: Int = termsDoc.getValue(key: "count") {
                    terms.count = Int64(countInt)
                } else if let countNumber: NSNumber = termsDoc.getValue(key: "count") {
                    terms.count = countNumber.int64Value
                } else if let countStr: String = termsDoc.getValue(key: "count"), let parsed = Int64(countStr) {
                    terms.count = parsed
                }
                terms.mode = termsDoc.getValue(key: "mode")
                apm.responseTerms = terms
            }
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
            
            if let provider: JsonDoc = paymentMethodApm.get(valueFor: "provider") {
                apm.providerName = provider.getValue(key: "name")
                apm.providerReference = provider.getValue(key: "merchant_identifier")
                apm.timeCreatedReference = provider.getValue(key: "time_created_reference")
                apm.confirmedAccountHolder = provider.getValue(key: "confirmed_account_holder")
                if let value: String = provider.getValue(key: "wait_notification"), !value.isEmpty { apm.waitNotification = value }
                if let value: String = provider.getValue(key: "fund_status"), !value.isEmpty { apm.fundStatus = value }
                if let value: String = provider.getValue(key: "payment_description"), !value.isEmpty { apm.paymentDescription = value }
                if let value: String = provider.getValue(key: "optional_redirect"), !value.isEmpty { apm.optionalRedirect = value }
            } else {
                apm.providerName = paymentMethodApm.getValue(key: "provider")
            }
            if let bankDoc: JsonDoc = paymentMethodApm.get(valueFor: "bank") {
                apm.bank = BankResponse.mapToObject(bankDoc)
            }
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
