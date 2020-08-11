import Foundation

/// Use PIN debit track data as a payment method.
public class DebitTrackData: Debit, TrackData {
    public var expiry: String?
    public var pan: String?
    public var trackNumber: TrackNumber?
    public var trackData: String? {
        didSet(newValue) {
            if newValue != nil { value = newValue }
        }
    }
    public var discretionaryData: String?
    public var value: String? {
        didSet(newValue) {
            CardUtils.parseTrackData(paymentMethod: self)
            cardType = CardUtils.mapCardType(cardNumber: pan)
        }
    }
    public var entryMethod: EntryMethod?
    public var purchaseDeviceSequenceNumber: String?
}
