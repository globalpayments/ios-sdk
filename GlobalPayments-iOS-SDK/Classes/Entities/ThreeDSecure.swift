import Foundation

public class ThreeDSecure: NSObject {
    public var acsInterface: String?
    public var acsTransactionId: String?
    public var acsEndVersion: String?
    public var acsStartVersion: String?
    public var acsInfoIndicator: [String]?
    public var acsUiTemplate: String?
    public var algorithm: Int?
    /// The algorithm used.
    public var amount: NSDecimalNumber? {
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
    public var challengeValue: String?
    public var challengeReturnUrl: String?
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
    public var decoupledResponseIndicator: String?
    /// The enrolment status:
    public var enrolled: String?
    /// The URL of the Issuing Bank's ACS.
    public var issuerAcsUrl: String?

    public var liabilityShift: String?
    
    /// A KVP collection of merchant supplied data
    public var merchantData: MerchantDataCollection? = MerchantDataCollection() {
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
                version = Secure3dVersion(rawValue: intValue)
            }
        }
    }
    public var messageCategory: String?
    public var messageExtensionId: String?
    public var messageExtensionName: String?
    public var messageVersion: String?
    public var messageType: String?
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
    public var acsReferenceNumber: String?
    public var serverTransferReference: String?
    public var status: String?
    public var statusReason: String?
    public var version: Secure3dVersion? {
        didSet(newValue) {
            try? merchantData?.put(
                key: "_version",
                value: "\(String(describing: newValue?.rawValue))",
                isVisible: false
            )
        }
    }
    public var providerServerTransRef: String?
    /// Consumer authentication (3DSecure) transaction ID.
    public var xid: String?
    public var sessionDataFieldName: String?
    /// The exempt status
    public var exemptStatus: ExemptStatus?
    /// The exemption optimization service reason
    public var exemptReason: ExemptReason?

    public var whiteListStatus: String?

    public func threeDSecure() {
        paymentDataType = "3DSecure"
    }

    public func merge(secureEcom: ThreeDSecure?) {
        guard let secureEcom = secureEcom else { return }

        acsTransactionId = mergeValue(acsTransactionId, secureEcom.acsTransactionId)
        acsEndVersion = mergeValue(acsEndVersion, secureEcom.acsEndVersion)
        acsStartVersion = mergeValue(acsStartVersion, secureEcom.acsStartVersion)
        acsInfoIndicator = mergeValue(acsInfoIndicator, secureEcom.acsInfoIndicator)
        acsInterface = mergeValue(acsInterface, secureEcom.acsInterface)
        acsUiTemplate = mergeValue(acsUiTemplate, secureEcom.acsUiTemplate)
        acsReferenceNumber = mergeValue(acsReferenceNumber, secureEcom.acsReferenceNumber)
        algorithm = mergeValue(algorithm, secureEcom.algorithm)
        providerServerTransRef = mergeValue(providerServerTransRef, secureEcom.providerServerTransRef)
        amount = mergeValue(amount, secureEcom.amount)
        authenticationSource = mergeValue(authenticationSource, secureEcom.authenticationSource)
        authenticationType = mergeValue(authenticationType, secureEcom.authenticationType)
        authenticationValue = mergeValue(authenticationValue, secureEcom.authenticationValue)
        cardHolderResponseInfo = mergeValue(cardHolderResponseInfo, secureEcom.cardHolderResponseInfo)
        cavv = mergeValue(cavv, secureEcom.cavv)
        challengeMandated = mergeValue(challengeMandated, secureEcom.challengeMandated)
        challengeValue = mergeValue(challengeValue, secureEcom.challengeValue)
        challengeReturnUrl = mergeValue(challengeReturnUrl, secureEcom.challengeReturnUrl)
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
        messageType = mergeValue(messageType, secureEcom.messageType)
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
        version = mergeValue(version, secureEcom.version)
        xid = mergeValue(xid, secureEcom.xid)
        sessionDataFieldName = mergeValue(sessionDataFieldName, secureEcom.sessionDataFieldName)
        exemptStatus = mergeValue(exemptStatus, secureEcom.exemptStatus)
        exemptReason = mergeValue(exemptReason, secureEcom.exemptReason)
        liabilityShift = mergeValue(liabilityShift, secureEcom.liabilityShift)
        whiteListStatus = mergeValue(whiteListStatus, secureEcom.whiteListStatus)
    }

    private func mergeValue<T>(_ currentValue: T?, _ mergeValue: T?) -> T? {
        if mergeValue == nil {
            return currentValue
        }
        return mergeValue
    }
}
