import Foundation

public class Encryption: NSObject {
    
    ///The encryption method used when sending encrypted card data to Global Payments.
    public var method: String?
    
    ///The version of encryption being used.
    public var version: String?
    
    ///The encryption info used when sending encrypted card data to Global Payments.
    public var info: String?
    
    ///Indicates the encryption encoding format used to encrypt the data.
    public var type: String?
}
