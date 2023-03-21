import Foundation

public class EBTCardData: EBT, CardData {
    public var approvalCode: String?
    public var cardPresent: Bool = false
    public var cardType: String?
    /// The card's card verification number (CVN).
    /// When set, `CreditCardData.CvnPresenceIndicator` is set to `CvnPresenceIndicator.present`.
    public var cvn: String? {
        willSet(newValue) {
            cvnPresenceIndicator = newValue.isNilOrEmpty ? .notRequested : .present
        }
    }
    public var cvnPresenceIndicator: CvnPresenceIndicator = .notRequested
    public var number: String?
    public var expMonth: Int = .zero
    public var expYear: Int = .zero
    public var readerPresent: Bool = false
    public var serialNumber: String?
    public var shortExpiry: String {
        let month: String = expMonth > .zero ? "\(expMonth)".leftPadding(toLength: 2, withPad: "0") : .empty
        let year: String = expYear > .zero ? "\(expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : .empty
        return month + year
    }
    public var entryMethod: ManualEntryMethod?
}
