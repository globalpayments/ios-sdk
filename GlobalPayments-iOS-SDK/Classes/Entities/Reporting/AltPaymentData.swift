import Foundation

public class AltPaymentData {
    public var status: String?
    public var statusMessage: String?
    public var buyerEmailAddress: String?
    public var stateDate: Date?
    public var processorResponseInfo: [AltPaymentProcessorInfo]?
}

public class AltPaymentProcessorInfo {
    public var code: String?
    public var message: String?
    public var type: String?
}
