import Foundation

@objcMembers public class ThreeDSecure: NSObject {
    public var acsTransactionId: String?
    public var acsEndVersion: String?
    public var acsStartVersion: String?
    public var algorithm: Int?
    /// The algorithm used.
    public var amount: Decimal? {
        didSet {
            try? merchantData?.put(key: "_amount", value: amount?.description, isVisible: false)
        }
    }
    public var authenticationSource: String?
    public var authenticationType: String?
    public var authenticationValue: String?
    public var cardHolderResponseInfo: String?
    /// Consumer authentication (3DSecure) verification value.
    public var cavv: String?
    public var challengeMandated: Bool?
    public var criticalityIndicator: String?
    public var currency: String? {
        didSet {
            try? merchantData?.put(key: "_currency", value: currency, isVisible: false)
        }
    }
    public var directoryServerTransactionId: String?
    public var directoryServerEndVersion: String?
    public var directoryServerStartVersion: String?
    /// Consumer authentication (3DSecure) electronic commerce indicator.
    public var eci: Int?
    /// The enrolment status:
    public var enrolled: String?
    /// The URL of the Issuing Bank's ACS.
    public var issuerAcsUrl: String?
    /// A KVP collection of merchant supplied data
    public var merchantData: MerchantDataCollection? {
        didSet {
            merchantData?.mergeHidden(collection: self.merchantData)
            if merchantData?.hasKey(key: "_amount") != nil {
                amount = merchantData?.getDecimal(key: "_amount") ?? .zero
            }
            if merchantData?.hasKey(key: "_currency") != nil {
                currency = merchantData?.getString(key: "_currency") ?? .empty
            }
            if merchantData?.hasKey(key: "_orderId") != nil {
                orderId = merchantData?.getString(key: "_orderId") ?? .empty
            }
            if merchantData?.hasKey(key: "_version") != nil {
                let intValue = Int(merchantData?.getString(key: "_version") ?? .empty) ?? .zero
                version = Secure3dVersion(rawValue: intValue) ?? .none
            }
        }
    }
    public var messageCategory: String?
    public var messageExtensionId: String?
    public var messageExtensionName: String?
    public var messageVersion: String?
    /// The order ID used for the initial transaction
    public var orderId: String? {
        didSet {
            try? merchantData?.put(key: "_orderId", value: orderId, isVisible: false)
        }
    }
    /// The Payer Authentication Request returned by the Enrolment Server.
    /// Must be sent to the Issuing Bank's ACS (Access Control Server) URL.
    public var payerAuthenticationRequest: String?
    /// Consumer authentication (3DSecure) source.
    public var paymentDataSource: String?
    /// Consumer authentication (3DSecure) type.
    public var paymentDataType: String?
    public var sdkInterface: String?
    public var sdkUiType: String?
    public var secureCode: String?
    public var serverTransactionId: String?
    public var status: String?
    public var statusReason: String?
    public var version: Secure3dVersion = .none {
        didSet {
            try? merchantData?.put(
                key: "_version",
                value: "\(String(describing: version.rawValue))",
                isVisible: false
            )
        }
    }
    /// Consumer authentication (3DSecure) transaction ID.
    public var xid: String?

    public func threeDSecure() {
        paymentDataType = "3DSecure"
    }

    public func merge(secureEcom: ThreeDSecure?) {
        guard let secureEcom = secureEcom else { return }

        acsTransactionId = mergeValue(acsTransactionId, secureEcom.acsTransactionId)
        acsEndVersion = mergeValue(acsEndVersion, secureEcom.acsEndVersion)
        acsStartVersion = mergeValue(acsStartVersion, secureEcom.acsStartVersion)
        algorithm = mergeValue(algorithm, secureEcom.algorithm)
        amount = mergeValue(amount, secureEcom.amount)
        authenticationSource = mergeValue(authenticationSource, secureEcom.authenticationSource)
        authenticationType = mergeValue(authenticationType, secureEcom.authenticationType)
        authenticationValue = mergeValue(authenticationValue, secureEcom.authenticationValue)
        cardHolderResponseInfo = mergeValue(cardHolderResponseInfo, secureEcom.cardHolderResponseInfo)
        cavv = mergeValue(cavv, secureEcom.cavv)
        challengeMandated = mergeValue(challengeMandated, secureEcom.challengeMandated)
        criticalityIndicator = mergeValue(criticalityIndicator, secureEcom.criticalityIndicator)
        currency = mergeValue(currency, secureEcom.currency)
        directoryServerTransactionId = mergeValue(directoryServerTransactionId, secureEcom.directoryServerTransactionId)
        directoryServerEndVersion = mergeValue(directoryServerEndVersion, secureEcom.directoryServerEndVersion)
        directoryServerStartVersion = mergeValue(directoryServerStartVersion, secureEcom.directoryServerStartVersion)
        eci = mergeValue(eci, secureEcom.eci)
        enrolled = mergeValue(enrolled, secureEcom.enrolled)
        issuerAcsUrl = mergeValue(issuerAcsUrl, secureEcom.issuerAcsUrl)
        merchantData = mergeValue(merchantData, secureEcom.merchantData)
        messageCategory = mergeValue(messageCategory, secureEcom.messageCategory)
        messageExtensionId = mergeValue(messageExtensionId, secureEcom.messageExtensionId)
        messageExtensionName = mergeValue(messageExtensionName, secureEcom.messageExtensionName)
        messageVersion = mergeValue(messageVersion, secureEcom.messageVersion)
        orderId = mergeValue(orderId, secureEcom.orderId)
        payerAuthenticationRequest = mergeValue(payerAuthenticationRequest, secureEcom.payerAuthenticationRequest)
        paymentDataSource = mergeValue(paymentDataSource, secureEcom.paymentDataSource)
        paymentDataType = mergeValue(paymentDataType, secureEcom.paymentDataType)
        sdkInterface = mergeValue(sdkInterface, secureEcom.sdkInterface)
        sdkUiType = mergeValue(sdkUiType, secureEcom.sdkUiType)
        secureCode = mergeValue(secureCode, secureEcom.secureCode)
        serverTransactionId = mergeValue(serverTransactionId, secureEcom.serverTransactionId)
        status = mergeValue(status, secureEcom.status)
        statusReason = mergeValue(statusReason, secureEcom.statusReason)
        version = mergeValue(version, secureEcom.version) ?? .none
        xid = mergeValue(xid, secureEcom.xid)
    }

    private func mergeValue<T>(_ currentValue: T?, _ mergeValue: T?) -> T? {
        if mergeValue == nil {
            return currentValue
        }
        return mergeValue
    }
}
