import Foundation

@objcMembers public class MerchantKVP: NSObject {
    var key: String
    var value: String
    var isVisible: Bool

    public init(key: String, value: String, isVisible: Bool) {
        self.key = key
        self.value = value
        self.isVisible = isVisible
    }
}
