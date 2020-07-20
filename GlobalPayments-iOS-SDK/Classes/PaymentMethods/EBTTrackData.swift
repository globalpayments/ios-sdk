import Foundation

/// Use EBT track data as a payment method.
public class EBTTrackData: EBT, TrackData, Encryptable {
    public var expiry: String?
    public var pan: String?
    public var trackNumber: TrackNumber?
    public var trackData: String? {
        didSet(newValue) {
            value = newValue
        }
    }
    public var discretionaryData: String?
    public var value: String? {
        didSet{
            CardUtils.parseTrackData(paymentMethod: self)
        }
    }
    public var entryMethod: EntryMethod?
    public var encryptionData: EncryptionData?
    public var purchaseDeviceSequenceNumber: String?
}
