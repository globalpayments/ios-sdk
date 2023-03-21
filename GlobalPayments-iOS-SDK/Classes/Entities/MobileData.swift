import Foundation

public class MobileData: NSObject {
    
    public var encodedData: String?
    public var applicationReference: String?
    public var sdkInterface: SdkInterface?
    public var sdkUiTypes: [SdkUiType]?
    public var ephemeralPublicKey: JsonDoc?
    public var maximumTimeout: Decimal?
    public var referenceNumber: String?
    public var sdkTransReference: String?
}
