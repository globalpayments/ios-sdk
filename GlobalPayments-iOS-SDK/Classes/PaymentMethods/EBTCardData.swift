import Foundation

public class EBTCardData: EBT, CardData {
    public var approvalCode: String?
    public var cardPresent: Bool = false
    public var cardType: String?
    public var cvn: String?
    public var cvnPresenceIndicator: CvnPresenceIndicator = .notRequested
    public var number: String?
    public var expMonth: Int = .zero
    public var expYear: Int = .zero
    public var readerPresent: Bool = false
    public var serialNumber: String?
    public var shortExpiry: String {
        // TODO: There
        let month: String = expMonth > .zero ? .empty : .empty
        let year: String = expYear > .zero ? .empty : .empty
        return month + year
    }
}

//public string ShortExpiry {
//    get {
//        var month = (ExpMonth.HasValue) ? ExpMonth.ToString().PadLeft(2, '0') : string.Empty;
//        var year = (ExpYear.HasValue) ? ExpYear.ToString().PadLeft(4, '0').Substring(2, 2) : string.Empty;
//        return month + year;
//    }
//}
