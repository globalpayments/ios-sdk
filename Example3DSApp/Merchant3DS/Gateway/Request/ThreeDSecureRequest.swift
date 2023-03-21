import Foundation

class ThreeDSecureRequest {
    let acsEndVersion = "2.1.0"
    let messageType = "creq"
    let directoryServerEndVersion = "2.1.0"
    let acsStartVersion = "2.1.0"
    var currency: String?
    var amount: Decimal?
    var status: String?
    var providerServerTransRef = "c1d4469a-1bdb-4770-951d-eee3346dce94"
    var serverTransactionId: String?
    var messageVersion: String?
    var acsInfoIndicator = ["NOT_AVAILABLE"]
    
    var challengeValue: String?
    var challengeMandated = false
    var challengeReturnUrl = "https: //ensi808o85za.x.pipedream.net/"
    var enrolled = true
    var sessionDataFieldName = "threeDSSessionData"
    var version = "2"
    
    func toJson() -> JsonDoc{
        let jsonDoc = JsonDoc()
        jsonDoc.set(for: "acsEndVersion", value: acsEndVersion)
        jsonDoc.set(for: "messageType", value: messageType)
        jsonDoc.set(for: "directoryServerEndVersion", value: directoryServerEndVersion)
        jsonDoc.set(for: "acsStartVersion", value: acsStartVersion)
        jsonDoc.set(for: "currency", value: currency)
        jsonDoc.set(for: "amount", value: amount)
        jsonDoc.set(for: "status", value: status)
        jsonDoc.set(for: "providerServerTransRef", value: providerServerTransRef)
        jsonDoc.set(for: "acsInfoIndicator", value: acsInfoIndicator)
        jsonDoc.set(for: "serverTransactionId", value: serverTransactionId)
        jsonDoc.set(for: "messageVersion", value: messageVersion)
        jsonDoc.set(for: "enrolled", value: enrolled)
        jsonDoc.set(for: "challengeValue", value: challengeValue)
        jsonDoc.set(for: "challengeMandated", value: challengeMandated)
        jsonDoc.set(for: "challengeReturnUrl", value: challengeReturnUrl)
        jsonDoc.set(for: "sessionDataFieldName", value: sessionDataFieldName)
        jsonDoc.set(for: "version", value: version)
        return jsonDoc
    }
}
