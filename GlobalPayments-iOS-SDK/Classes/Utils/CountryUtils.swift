import Foundation

public class CountryUtils {

    public static let shared = CountryUtils()

    private var countryCodeMapByCountry: [String: String]
    private var countryMapByCode: [String: String]
    private let significantCountryMatch = 6
    private let significantCodeMatch = 3

    init() {
        countryCodeMapByCountry = [String: String]()
        countryMapByCode = [String: String]()

        NSLocale.isoCountryCodes.forEach { countryCode in
            let countryName = NSLocale(localeIdentifier: "EN")
                .displayName(forKey: .countryCode, value: countryCode) ?? .empty
            countryCodeMapByCountry[countryName] = countryCode
            countryMapByCode[countryCode] = countryName
        }
    }

    public func countryByCode(_ countryCode: String?) -> String? {
        guard let countryCode = countryCode else { return nil }
        // These should be ISO so just check if it's there and return
        if countryMapByCode.keys.contains(countryCode) {
            return countryMapByCode[countryCode]
        } else {
            if countryCode.count > 3 { return nil }
            return fuzzyMatch(countryMapByCode, countryCode, significantCodeMatch)
        }
    }

    public func countryCodeByCountry(_ country: String?) -> String? {
        guard let country = country else { return nil }

        // These can be tricky... first check for direct match
        if countryCodeMapByCountry.keys.contains(country) {
            return countryCodeMapByCountry[country]
        } else {
            // check the inverse, in case we have a countryCode in the country field
            if countryMapByCode.keys.contains(country) {
                return country
            } else {
                // it's not a country match or a countryCode match so let's get fuzzy
                let fuzzyCountryMatch = fuzzyMatch(
                    countryCodeMapByCountry,
                    country,
                    significantCountryMatch
                )
                if fuzzyCountryMatch != nil {
                    return fuzzyCountryMatch
                } else {
                    // assume if it's > 3 it's not a code and do not do fuzzy code matching
                    if country.count > 3 {
                        return nil
                    }
                    // 3 or less, let's fuzzy match
                    let fuzzyCodeMatch = fuzzyMatch(
                        countryMapByCode,
                        country,
                        significantCodeMatch
                    )
                    guard let fuzzyCodeMatchResult = fuzzyCodeMatch else { return nil }
                    return countryCodeMapByCountry[fuzzyCodeMatchResult]
                }
            }
        }
    }

    public func isCountry(_ address: Address, _ countryCode: String?) -> Bool {
        if address.countryCode != nil {
            return address.countryCode == countryCode
        } else if address.country != nil {
            let code = countryCodeByCountry(address.country)
            if code != nil {
                return code == countryCode
            }
            return false
        }
        return false
    }

    // MARK: - Fuzzy Match Algorithm

    private func fuzzyMatch(_ countryMapByCode: [String: String],
                            _ query: String,
                            _ significantCodeMatch: Int) -> String? {

        var rValue: String?
        var matches = [String: String]()

        // now we can loop
        var highScore: Int = -1

        for key in countryMapByCode.keys {
            let score = fuzzyScore(key, query)
            if score > significantCodeMatch && score > highScore {
                matches = [String: String]()
                highScore = score
                rValue = countryMapByCode[key]
                matches[key] = rValue
            } else if score == highScore {
                matches[key] = countryMapByCode[key]
            }
        }
        if matches.count > 1 {
            return nil
        }
        
        return rValue
    }

    private func fuzzyScore(_ term: String, _ query: String) -> Int {

        let termLowerCase = term.lowercased()
        let queryLowerCase = query.lowercased()

        var score = 0
        var index = 0
        var previousMatchingCharacterIndex = Int.min

        for queryChar in queryLowerCase {

            var termCharacterMatchFound = false

            for (termIndex, termChar) in termLowerCase.enumerated() {

                if termCharacterMatchFound { break }
                if termIndex < index { continue }
                if queryChar == termChar {
                    score += 1

                    if previousMatchingCharacterIndex + 1 == termIndex {
                        score += 2
                    }

                    index = termIndex
                    previousMatchingCharacterIndex = termIndex
                    termCharacterMatchFound = true
                }

                index += 1
            }
        }

        return score
    }
}
