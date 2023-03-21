import Foundation

/// Use credit track data as a payment method.
public class CreditTrackData: Credit, TrackData {
    public var expiry: String?
    public var pan: String?
    public var trackNumber: TrackNumber?
    public var trackData: String? {
        willSet(newValue) {
            value = newValue
        }
    }
    public var discretionaryData: String?
    public var value: String? {
        willSet(newValue) {
            CardUtils.parseTrackData(paymentMethod: self)
            cardType = CardUtils.mapCardType(cardNumber: pan)
            fleetCard = CardUtils.isFleet(cardType: cardType, pan: pan)
            if let discretionaryData = discretionaryData,
                discretionaryData.count >= 8,
                cardType == "WexFleet" {
                purchaseDeviceSequenceNumber = discretionaryData.substring(with: 3..<5)
            }
        }
    }
    public var entryMethod: EntryMethod?
    public var purchaseDeviceSequenceNumber: String?
}
