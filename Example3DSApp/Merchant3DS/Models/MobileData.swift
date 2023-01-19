import Foundation

class MobileData {
    var applicationReference: String?
    var ephemeralPublicKey: JsonDoc?
    var maximumTimeout: Decimal?
    var referenceNumber: String?
    var sdkTransReference: String?
    var encodedData: String?
    var sdkInterface: SdkInterface?
    var sdkUiTypes: [SdkUiType]?
}
