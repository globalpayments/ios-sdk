import Foundation

@objc public protocol CardData {
    var cardPresent: Bool { get set }
    var cardType: String? { get set }
    var cvn: String? { get set }
    var cvnPresenceIndicator: CvnPresenceIndicator { get set }
    var number: String? { get set }
    var expMonth: Int { get set }
    var expYear: Int { get set }
    var readerPresent: Bool { get set }
    var shortExpiry: String { get }
}
