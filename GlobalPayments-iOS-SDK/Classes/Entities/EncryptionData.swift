import Foundation

/// Details how encrypted track data was encrypted by the device
/// in order for the gateway to decrypt the data.
@objcMembers public class EncryptionData: NSObject {
    /// The encryption version
    public var version: String
    /// The track number that is encrypted and supplied in the request.
    public var trackNumber: String?
    /// The key serial number (KSN) used at the point of sale;
    /// where applicable.
    public var ksn: String?
    /// The key transmission block (KTB) used at the point of sale;
    /// where applicable.
    public var ktb: String?

    public init(version: String,
                trackNumber: String? = nil,
                ksn: String? = nil,
                ktb: String? = nil) {

        self.version = version
        self.trackNumber = trackNumber
        self.ksn = ksn
        self.ktb = ktb
    }

    /// Convenience method for creating version `01` encryption data.
    /// - Returns: EncryptionData object for version 1
    public static func version1() -> EncryptionData {
        return EncryptionData(
            version: "01"
        )
    }

    /// Convenience method for creating version `02` encryption data.
    /// - Returns: EncryptionData object for version 1
    public static func version2(ktb: String, trackNumber: String? = nil) -> EncryptionData {
        return EncryptionData(
            version: "02",
            trackNumber: trackNumber,
            ktb: ktb
        )
    }
}
