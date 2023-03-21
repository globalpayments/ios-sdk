import Foundation

public class CardUtils {

    public static let cardTypes: [String: NSRegularExpression] = [
        "Amex": NSRegularExpression("^3[47]"),
        "MC": NSRegularExpression("^(?:5[1-6]|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)"),
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

    private static let fleetBinMap: [String: [String: String]] = [
        "Visa": [
            "448460": "448611",
            "448613": "448615",
            "448617": "448674",
            "448676": "448686",
            "448688": "448699",
            "461400": "461421",
            "461423": "461499",
            "480700": "480899"
        ],
        "MC": [
            "553231": "553380",
            "556083": "556099",
            "556100": "556599",
            "556700": "556999"
        ],
        "Wex": [
            "690046": "690046",
            "707138": "707138"
        ],
        "Voyager": [
            "708885": "708889"
        ]
    ]

    private static let trackOnePattern = NSRegularExpression("%?[B0]?([\\d]+)\\^[^\\^]+\\^([\\d]{4})([^?]+)\\??")
    private static let trackTwoPattern = NSRegularExpression(";?([\\d]+)[=|w](\\d{4})([^?]+)\\??")

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

    @discardableResult public static func parseTrackData<T: TrackData>(paymentMethod: T) -> T {
        let trackData = paymentMethod.value ?? .empty
        if trackTwoPattern.matches(trackData),
            let groups = trackTwoPattern.groups(trackData) {

            let pan = groups[safe: 1] ?? .empty
            let expiry = groups[safe: 2] ?? .empty
            var discretionary = groups[safe: 3] ?? .empty

            if !discretionary.isEmpty {
                if (pan + expiry + discretionary).count == 37
                    && discretionary.lowercased().last == "f" {
                    discretionary = String(discretionary.dropLast())
                }
            }
            paymentMethod.trackNumber = .trackTwo
            paymentMethod.pan = pan
            paymentMethod.expiry = expiry
            paymentMethod.discretionaryData = discretionary
            paymentMethod.trackData = "\(pan)=\(expiry)\(discretionary)"

        } else {
            if trackOnePattern.matches(trackData),
                let groups = trackOnePattern.groups(trackData) {
                paymentMethod.trackNumber = .trackTwo
                paymentMethod.pan = groups[safe: 1]
                paymentMethod.expiry = groups[safe: 2]
                paymentMethod.discretionaryData = groups[safe: 3]
                paymentMethod.trackData = String(trackData.dropFirst())
            }
        }
        return paymentMethod
    }

    public static func isFleet(cardType: String?, pan: String?) -> Bool {
        if !pan.isNilOrEmpty {
            guard let cardType = cardType else { return false }
            let compareValue = Int(cardType.prefix(4)) ?? .zero
            let baseCardType = cardType.trim("Fleet")
            if fleetBinMap.keys.contains(baseCardType) {
                guard let binRanges = fleetBinMap[baseCardType] else { return false }
                for key in binRanges.keys {
                    guard let lowerRange = Int(key),
                        let value = binRanges[key],
                        let upperRange = Int(value) else { return false }
                    if compareValue >= lowerRange && compareValue <= upperRange {
                        return true
                    }
                }
            }
        }
        return false
    }

    public static func getBaseCardType(cardType: String?) -> String? {
        guard let cardType = cardType else { return nil }
        let baseCardType = cardType.remove("FLEET")
        return baseCardType
    }
    
    public static func getExpMonthFormat(_ value: Int) -> String?{
        return value > .zero ? "\(value)".leftPadding(toLength: 2, withPad: "0") : nil
    }
    
    public static func getExpYearFormat(_ value: Int) -> String?{
        return value > .zero ? "\(value)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : nil
    }

    public static func generateCard(builder: AuthorizationBuilder) -> JsonDoc {
        let funding = builder.paymentMethod?.paymentMethodType == .debit ? "DEBIT" : "CREDIT"
        let card = JsonDoc()

        if let cardData = builder.paymentMethod as? CardData {
            card.set(for: "number", value: cardData.number)
            card.set(for: "expiry_month", value: getExpMonthFormat(cardData.expMonth))
            card.set(for: "expiry_year", value: getExpYearFormat(cardData.expYear))

            if let cvn = cardData.cvn, !cvn.isEmpty {
                card.set(for: "cvv", value: cvn)

                if builder.transactionType == .tokenize || builder.transactionType == .verify {
                    let cvnPresence = cardData.cvnPresenceIndicator
                    if cvnPresence != .notRequested {
                        card.set(for: "cvv_indicator", value: cvnPresence.mapped(for: .gpApi))
                    }
                    card.set(for: "funding", value: funding)
                }
            }

            if builder.emvLastChipRead != nil {
                card.set(for: "chip_condition", value: builder.emvLastChipRead?.mapped(for: .gpApi))
            }
        } else if let track = builder.paymentMethod as? TrackData {
            card.set(for: "track", value: track.value)

            if builder.transactionType == .sale || builder.transactionType == .refund {
                if track.value == nil {
                    card.set(for: "number", value: track.pan)
                    card.set(for: "expiry_month", value: track.expiry?.substring(with: 2..<4))
                    card.set(for: "expiry_year", value: track.expiry?.substring(with: 0..<2))
                }
                card.set(for: "chip_condition", value: builder.emvLastChipRead?.mapped(for: .gpApi))
            }

            if builder.transactionType == .sale {
                card.set(for: "funding", value: funding)
            }
        }

        // PIN Block
        if let pinProtected = builder.paymentMethod as? PinProtected {
            card.set(for: "pin_block", value: pinProtected.pinBlock)
        }

        card.set(for: "tag", value: builder.tagData)
        card.set(for: "avs_address", value: builder.billingAddress?.streetAddress1)
        card.set(for: "avs_postal_code", value: builder.billingAddress?.postalCode)
        card.set(for: "authcode", value: builder.offlineAuthCode)

        return card
    }
}
