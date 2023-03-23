import Foundation

public class PhoneNumber: NSObject {
    public var countryCode: String?
    public var areaCode: String?
    public var number: String?
    public var extensionNum: String?
    
    func toString() -> String {
        // country code (default to 1)
        var stringValue = "+\(countryCode ?? "1")"
        // append area code if present
        if let areaCode = areaCode {
            stringValue += "(\(areaCode))"
        }
        // put the number
        stringValue += number ?? ""
        // put extension if present
        if let extensionNum = extensionNum {
            stringValue += "EXT: \(extensionNum)"
        }
        return stringValue
    }
}
