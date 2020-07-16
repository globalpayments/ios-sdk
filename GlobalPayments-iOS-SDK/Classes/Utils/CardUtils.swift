import Foundation

public class CardUtils {

    public static let cardTypes: [String: NSRegularExpression] = [
        "Amex": NSRegularExpression("^3[47]"),
        "MC": NSRegularExpression("^(?:5[1-5]|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)"),
        "Visa": NSRegularExpression("^4"),
        "DinersClub": NSRegularExpression("^3(?:0[0-5]|[68][0-9])"),
        "EnRoute": NSRegularExpression("^(2014|2149)"),
        "Discover": NSRegularExpression("^6(?:011|5[0-9]{2})"),
        "Jcb": NSRegularExpression("^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"),
        "Voyager": NSRegularExpression("^70888[5-9]"),
        "Wex": NSRegularExpression("^(?:690046|707138)"),
        "StoredValue": NSRegularExpression("^(?:600649|603261|603571|627600|639470)"),
        "ValueLink": NSRegularExpression("^(?:601056|603225)"),
        "HeartlandGift": NSRegularExpression("^(?:502244|627720|708355)")
    ]

    public static func mapCardType(cardNumber: String?) -> String {
        var rValue = "Unknown"
        guard var cardNumber = cardNumber else {
            return rValue
        }
        cardNumber = cardNumber
            .replacingOccurrences(of: " ", with: String.empty)
            .replacingOccurrences(of: "-", with: String.empty)

        for cardType in cardTypes.keys {
            if let regex = cardTypes[cardType], regex.matches(cardNumber) {
                rValue = cardType
                break
            }
        }

        return rValue
    }
}
