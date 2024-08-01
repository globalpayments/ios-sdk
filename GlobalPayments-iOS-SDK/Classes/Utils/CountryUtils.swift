import Foundation

public class CountryUtils {

    public static let shared = CountryUtils()

    private let significantCountryMatch = 6
    private let significantCodeMatch = 3

    private init() { }

    public func countryByCode(_ countryCode: String?) -> String? {
        guard let countryCode = countryCode else { return nil }
        // These should be ISO so just check if it's there and return
        if ISOCountryInfo.countryMapByCountryCode.keys.contains(countryCode) {
            return ISOCountryInfo.countryMapByCountryCode[countryCode]
        } else {
            if countryCode.count > 3 { return nil }
            return fuzzyMatch(ISOCountryInfo.countryMapByCountryCode, countryCode, significantCodeMatch)
        }
    }

    public func countryCodeByCountry(_ country: String?) -> String? {
        guard let country = country else { return nil }

        // These can be tricky... first check for direct match
        if ISOCountryInfo.countryCodeMapByCountry.keys.contains(country) {
            return ISOCountryInfo.countryCodeMapByCountry[country]
        } else {
            // check the inverse, in case we have a countryCode in the country field
            if ISOCountryInfo.countryMapByCountryCode.keys.contains(country) {
                return country
            } else {
                // check for codes in case we have a numericCode in the country field
                if ISOCountryInfo.countryCodeMapByNumericCode.keys.contains(country) {
                    return ISOCountryInfo.countryCodeMapByNumericCode[country]
                } else {
                    // it's not a country match or a countryCode match so let's get fuzzy
                    let fuzzyCountryMatch = fuzzyMatch(ISOCountryInfo.countryCodeMapByCountry, country, significantCountryMatch)
                    if fuzzyCountryMatch != nil {
                        return fuzzyCountryMatch
                    } else {
                        // assume if it's > 3 it's not a code and do not do fuzzy code matching
                        if country.count > 3 { return nil }
                        // 3 or less, let's fuzzy match
                        let fuzzyCodeMatch = fuzzyMatch(ISOCountryInfo.countryMapByCountryCode, country, significantCodeMatch)
                        guard let fuzzyCodeMatchResult = fuzzyCodeMatch else { return nil }
                        return ISOCountryInfo.countryCodeMapByCountry[fuzzyCodeMatchResult]
                    }
                }
            }
        }
    }

    public func numericCodeByCountry(_ country: String) -> String? {
        if ISOCountryInfo.countryCodeMapByNumericCode.keys.contains(country) {
            return country
        } else {
            guard let countryCode = countryCodeByCountry(country) else { return nil }
            return ISOCountryInfo.numericCodeMapByCountryCode[countryCode]
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
    
    public func getPhoneCodesByCountry(_ value: String?) -> String? {
        var countryInfo: ISOCountryInfo?
        if let countryByName = ISOCountryInfo.allCountries.first (where: { $0.name == value }) {
            countryInfo = countryByName
        }
        
        if let countryByNumeric = ISOCountryInfo.allCountries.first (where: { $0.numeric == value }) {
            countryInfo = countryByNumeric
        }
        
        if let countryByAlpha2 = ISOCountryInfo.allCountries.first (where: { $0.alpha2 == value }) {
            countryInfo = countryByAlpha2
        }
        
        if let countryByAlpha3 = ISOCountryInfo.allCountries.first (where: { $0.alpha3 == value }) {
            countryInfo = countryByAlpha3
        }
        return ISOCountryInfo.listCountryCode[countryInfo?.name ?? ""]
    }
}

// MARK: - Countries

extension CountryUtils {

    public struct ISOCountryInfo {
        public let name: String
        public let numeric: String
        public let alpha2: String
        public let alpha3: String
        
        public static func allCountriesSorted() -> [ISOCountryInfo] {
            var list = allCountries.sorted(by: { $0.alpha2 < $1.alpha2 }).sorted(by: { $0.alpha2 == "US" || $1.alpha2 == "GB" })
            guard let lastItem = list.last else { return list }
            list.insert(lastItem, at: 0)
            list.removeLast()
            return list
        }

        public static let allCountries: [ISOCountryInfo] = [
            ISOCountryInfo(name: "Afghanistan", numeric: "004", alpha2: "AF", alpha3: "AFG"),
            ISOCountryInfo(name: "Åland Islands", numeric: "248", alpha2: "AX", alpha3: "ALA"),
            ISOCountryInfo(name: "Albania", numeric: "008", alpha2: "AL", alpha3: "ALB"),
            ISOCountryInfo(name: "Algeria", numeric: "012", alpha2: "DZ", alpha3: "DZA"),
            ISOCountryInfo(name: "American Samoa", numeric: "016", alpha2: "AS", alpha3: "ASM"),
            ISOCountryInfo(name: "Andorra", numeric: "020", alpha2: "AD", alpha3: "AND"),
            ISOCountryInfo(name: "Angola", numeric: "024", alpha2: "AO", alpha3: "AGO"),
            ISOCountryInfo(name: "Anguilla", numeric: "660", alpha2: "AI", alpha3: "AIA"),
            ISOCountryInfo(name: "Antarctica", numeric: "010", alpha2: "AQ", alpha3: "ATA"),
            ISOCountryInfo(name: "Antigua and Barbuda", numeric: "028", alpha2: "AG", alpha3: "ATG"),
            ISOCountryInfo(name: "Argentina", numeric: "032", alpha2: "AR", alpha3: "ARG"),
            ISOCountryInfo(name: "Armenia", numeric: "051", alpha2: "AM", alpha3: "ARM"),
            ISOCountryInfo(name: "Aruba", numeric: "533", alpha2: "AW", alpha3: "ABW"),
            ISOCountryInfo(name: "Australia", numeric: "036", alpha2: "AU", alpha3: "AUS"),
            ISOCountryInfo(name: "Austria", numeric: "040", alpha2: "AT", alpha3: "AUT"),
            ISOCountryInfo(name: "Azerbaijan", numeric: "031", alpha2: "AZ", alpha3: "AZE"),
            ISOCountryInfo(name: "Bahamas", numeric: "044", alpha2: "BS", alpha3: "BHS"),
            ISOCountryInfo(name: "Bahrain", numeric: "048", alpha2: "BH", alpha3: "BHR"),
            ISOCountryInfo(name: "Bangladesh", numeric: "050", alpha2: "BD", alpha3: "BGD"),
            ISOCountryInfo(name: "Barbados", numeric: "052", alpha2: "BB", alpha3: "BRB"),
            ISOCountryInfo(name: "Belarus", numeric: "112", alpha2: "BY", alpha3: "BLR"),
            ISOCountryInfo(name: "Belgium", numeric: "056", alpha2: "BE", alpha3: "BEL"),
            ISOCountryInfo(name: "Belize", numeric: "084", alpha2: "BZ", alpha3: "BLZ"),
            ISOCountryInfo(name: "Benin", numeric: "204", alpha2: "BJ", alpha3: "BEN"),
            ISOCountryInfo(name: "Bermuda", numeric: "060", alpha2: "BM", alpha3: "BMU"),
            ISOCountryInfo(name: "Bhutan", numeric: "064", alpha2: "BT", alpha3: "BTN"),
            ISOCountryInfo(name: "Bolivia, Plurinational State of", numeric: "068", alpha2: "BO", alpha3: "BOL"),
            ISOCountryInfo(name: "Bonaire, Sint Eustatius and Saba", numeric: "535", alpha2: "BQ", alpha3: "BES"),
            ISOCountryInfo(name: "Bosnia and Herzegovina", numeric: "070", alpha2: "BA", alpha3: "BIH"),
            ISOCountryInfo(name: "Botswana", numeric: "072", alpha2: "BW", alpha3: "BWA"),
            ISOCountryInfo(name: "Bouvet Island", numeric: "074", alpha2: "BV", alpha3: "BVT"),
            ISOCountryInfo(name: "Brazil", numeric: "076", alpha2: "BR", alpha3: "BRA"),
            ISOCountryInfo(name: "British Indian Ocean Territory", numeric: "086", alpha2: "IO", alpha3: "IOT"),
            ISOCountryInfo(name: "Brunei Darussalam", numeric: "096", alpha2: "BN", alpha3: "BRN"),
            ISOCountryInfo(name: "Bulgaria", numeric: "100", alpha2: "BG", alpha3: "BGR"),
            ISOCountryInfo(name: "Burkina Faso", numeric: "854", alpha2: "BF", alpha3: "BFA"),
            ISOCountryInfo(name: "Burundi", numeric: "108", alpha2: "BI", alpha3: "BDI"),
            ISOCountryInfo(name: "Cambodia", numeric: "116", alpha2: "KH", alpha3: "KHM"),
            ISOCountryInfo(name: "Cameroon", numeric: "120", alpha2: "CM", alpha3: "CMR"),
            ISOCountryInfo(name: "Canada", numeric: "124", alpha2: "CA", alpha3: "CAN"),
            ISOCountryInfo(name: "Cabo Verde", numeric: "132", alpha2: "CV", alpha3: "CPV"),
            ISOCountryInfo(name: "Cayman Islands", numeric: "136", alpha2: "KY", alpha3: "CYM"),
            ISOCountryInfo(name: "Central African Republic", numeric: "140", alpha2: "CF", alpha3: "CAF"),
            ISOCountryInfo(name: "Chad", numeric: "148", alpha2: "TD", alpha3: "TCD"),
            ISOCountryInfo(name: "Chile", numeric: "152", alpha2: "CL", alpha3: "CHL"),
            ISOCountryInfo(name: "China", numeric: "156", alpha2: "CN", alpha3: "CHN"),
            ISOCountryInfo(name: "Christmas Island", numeric: "162", alpha2: "CX", alpha3: "CXR"),
            ISOCountryInfo(name: "Cocos (Keeling) Islands", numeric: "166", alpha2: "CC", alpha3: "CCK"),
            ISOCountryInfo(name: "Colombia", numeric: "170", alpha2: "CO", alpha3: "COL"),
            ISOCountryInfo(name: "Comoros", numeric: "174", alpha2: "KM", alpha3: "COM"),
            ISOCountryInfo(name: "Congo", numeric: "178", alpha2: "CG", alpha3: "COG"),
            ISOCountryInfo(name: "Congo, the Democratic Republic of the", numeric: "180", alpha2: "CD", alpha3: "COD"),
            ISOCountryInfo(name: "Cook Islands", numeric: "184", alpha2: "CK", alpha3: "COK"),
            ISOCountryInfo(name: "Costa Rica", numeric: "188", alpha2: "CR", alpha3: "CRI"),
            ISOCountryInfo(name: "Côte d'Ivoire", numeric: "384", alpha2: "CI", alpha3: "CIV"),
            ISOCountryInfo(name: "Croatia", numeric: "191", alpha2: "HR", alpha3: "HRV"),
            ISOCountryInfo(name: "Cuba", numeric: "192", alpha2: "CU", alpha3: "CUB"),
            ISOCountryInfo(name: "Curaçao", numeric: "531", alpha2: "CW", alpha3: "CUW"),
            ISOCountryInfo(name: "Cyprus", numeric: "196", alpha2: "CY", alpha3: "CYP"),
            ISOCountryInfo(name: "Czechia", numeric: "203", alpha2: "CZ", alpha3: "CZE"),
            ISOCountryInfo(name: "Denmark", numeric: "208", alpha2: "DK", alpha3: "DNK"),
            ISOCountryInfo(name: "Djibouti", numeric: "262", alpha2: "DJ", alpha3: "DJI"),
            ISOCountryInfo(name: "Dominica", numeric: "212", alpha2: "DM", alpha3: "DMA"),
            ISOCountryInfo(name: "Dominican Republic", numeric: "214", alpha2: "DO", alpha3: "DOM"),
            ISOCountryInfo(name: "Ecuador", numeric: "218", alpha2: "EC", alpha3: "ECU"),
            ISOCountryInfo(name: "Egypt", numeric: "818", alpha2: "EG", alpha3: "EGY"),
            ISOCountryInfo(name: "El Salvador", numeric: "222", alpha2: "SV", alpha3: "SLV"),
            ISOCountryInfo(name: "Equatorial Guinea", numeric: "226", alpha2: "GQ", alpha3: "GNQ"),
            ISOCountryInfo(name: "Eritrea", numeric: "232", alpha2: "ER", alpha3: "ERI"),
            ISOCountryInfo(name: "Estonia", numeric: "233", alpha2: "EE", alpha3: "EST"),
            ISOCountryInfo(name: "Ethiopia", numeric: "231", alpha2: "ET", alpha3: "ETH"),
            ISOCountryInfo(name: "Falkland Islands (Malvinas)", numeric: "238", alpha2: "FK", alpha3: "FLK"),
            ISOCountryInfo(name: "Faroe Islands", numeric: "234", alpha2: "FO", alpha3: "FRO"),
            ISOCountryInfo(name: "Fiji", numeric: "242", alpha2: "FJ", alpha3: "FJI"),
            ISOCountryInfo(name: "Finland", numeric: "246", alpha2: "FI", alpha3: "FIN"),
            ISOCountryInfo(name: "France", numeric: "250", alpha2: "FR", alpha3: "FRA"),
            ISOCountryInfo(name: "French Guiana", numeric: "254", alpha2: "GF", alpha3: "GUF"),
            ISOCountryInfo(name: "French Polynesia", numeric: "258", alpha2: "PF", alpha3: "PYF"),
            ISOCountryInfo(name: "French Southern Territories", numeric: "260", alpha2: "TF", alpha3: "ATF"),
            ISOCountryInfo(name: "Gabon", numeric: "266", alpha2: "GA", alpha3: "GAB"),
            ISOCountryInfo(name: "Gambia", numeric: "270", alpha2: "GM", alpha3: "GMB"),
            ISOCountryInfo(name: "Georgia", numeric: "268", alpha2: "GE", alpha3: "GEO"),
            ISOCountryInfo(name: "Germany", numeric: "276", alpha2: "DE", alpha3: "DEU"),
            ISOCountryInfo(name: "Ghana", numeric: "288", alpha2: "GH", alpha3: "GHA"),
            ISOCountryInfo(name: "Gibraltar", numeric: "292", alpha2: "GI", alpha3: "GIB"),
            ISOCountryInfo(name: "Greece", numeric: "300", alpha2: "GR", alpha3: "GRC"),
            ISOCountryInfo(name: "Greenland", numeric: "304", alpha2: "GL", alpha3: "GRL"),
            ISOCountryInfo(name: "Grenada", numeric: "308", alpha2: "GD", alpha3: "GRD"),
            ISOCountryInfo(name: "Guadeloupe", numeric: "312", alpha2: "GP", alpha3: "GLP"),
            ISOCountryInfo(name: "Guam", numeric: "316", alpha2: "GU", alpha3: "GUM"),
            ISOCountryInfo(name: "Guatemala", numeric: "320", alpha2: "GT", alpha3: "GTM"),
            ISOCountryInfo(name: "Guernsey", numeric: "831", alpha2: "GG", alpha3: "GGY"),
            ISOCountryInfo(name: "Guinea", numeric: "324", alpha2: "GN", alpha3: "GIN"),
            ISOCountryInfo(name: "Guinea-Bissau", numeric: "624", alpha2: "GW", alpha3: "GNB"),
            ISOCountryInfo(name: "Guyana", numeric: "328", alpha2: "GY", alpha3: "GUY"),
            ISOCountryInfo(name: "Haiti", numeric: "332", alpha2: "HT", alpha3: "HTI"),
            ISOCountryInfo(name: "Heard Island and McDonald Islands", numeric: "334", alpha2: "HM", alpha3: "HMD"),
            ISOCountryInfo(name: "Holy See (Vatican City State)", numeric: "336", alpha2: "VA", alpha3: "VAT"),
            ISOCountryInfo(name: "Honduras", numeric: "340", alpha2: "HN", alpha3: "HND"),
            ISOCountryInfo(name: "Hong Kong", numeric: "344", alpha2: "HK", alpha3: "HKG"),
            ISOCountryInfo(name: "Hungary", numeric: "348", alpha2: "HU", alpha3: "HUN"),
            ISOCountryInfo(name: "Iceland", numeric: "352", alpha2: "IS", alpha3: "ISL"),
            ISOCountryInfo(name: "India", numeric: "356", alpha2: "IN", alpha3: "IND"),
            ISOCountryInfo(name: "Indonesia", numeric: "360", alpha2: "ID", alpha3: "IDN"),
            ISOCountryInfo(name: "Iran, Islamic Republic of", numeric: "364", alpha2: "IR", alpha3: "IRN"),
            ISOCountryInfo(name: "Iraq", numeric: "368", alpha2: "IQ", alpha3: "IRQ"),
            ISOCountryInfo(name: "Ireland", numeric: "372", alpha2: "IE", alpha3: "IRL"),
            ISOCountryInfo(name: "Isle of Man", numeric: "833", alpha2: "IM", alpha3: "IMN"),
            ISOCountryInfo(name: "Israel", numeric: "376", alpha2: "IL", alpha3: "ISR"),
            ISOCountryInfo(name: "Italy", numeric: "380", alpha2: "IT", alpha3: "ITA"),
            ISOCountryInfo(name: "Jamaica", numeric: "388", alpha2: "JM", alpha3: "JAM"),
            ISOCountryInfo(name: "Japan", numeric: "392", alpha2: "JP", alpha3: "JPN"),
            ISOCountryInfo(name: "Jersey", numeric: "832", alpha2: "JE", alpha3: "JEY"),
            ISOCountryInfo(name: "Jordan", numeric: "400", alpha2: "JO", alpha3: "JOR"),
            ISOCountryInfo(name: "Kazakhstan", numeric: "398", alpha2: "KZ", alpha3: "KAZ"),
            ISOCountryInfo(name: "Kenya", numeric: "404", alpha2: "KE", alpha3: "KEN"),
            ISOCountryInfo(name: "Kiribati", numeric: "296", alpha2: "KI", alpha3: "KIR"),
            ISOCountryInfo(name: "Korea, Democratic People's Republic of", numeric: "408", alpha2: "KP", alpha3: "PRK"),
            ISOCountryInfo(name: "Korea, Republic of", numeric: "410", alpha2: "KR", alpha3: "KOR"),
            ISOCountryInfo(name: "Kuwait", numeric: "414", alpha2: "KW", alpha3: "KWT"),
            ISOCountryInfo(name: "Kyrgyzstan", numeric: "417", alpha2: "KG", alpha3: "KGZ"),
            ISOCountryInfo(name: "Lao People's Democratic Republic", numeric: "418", alpha2: "LA", alpha3: "LAO"),
            ISOCountryInfo(name: "Latvia", numeric: "428", alpha2: "LV", alpha3: "LVA"),
            ISOCountryInfo(name: "Lebanon", numeric: "422", alpha2: "LB", alpha3: "LBN"),
            ISOCountryInfo(name: "Lesotho", numeric: "426", alpha2: "LS", alpha3: "LSO"),
            ISOCountryInfo(name: "Liberia", numeric: "430", alpha2: "LR", alpha3: "LBR"),
            ISOCountryInfo(name: "Libya", numeric: "434", alpha2: "LY", alpha3: "LBY"),
            ISOCountryInfo(name: "Liechtenstein", numeric: "438", alpha2: "LI", alpha3: "LIE"),
            ISOCountryInfo(name: "Lithuania", numeric: "440", alpha2: "LT", alpha3: "LTU"),
            ISOCountryInfo(name: "Luxembourg", numeric: "442", alpha2: "LU", alpha3: "LUX"),
            ISOCountryInfo(name: "Macao", numeric: "446", alpha2: "MO", alpha3: "MAC"),
            ISOCountryInfo(name: "North Macedonia", numeric: "807", alpha2: "MK", alpha3: "MKD"),
            ISOCountryInfo(name: "Madagascar", numeric: "450", alpha2: "MG", alpha3: "MDG"),
            ISOCountryInfo(name: "Malawi", numeric: "454", alpha2: "MW", alpha3: "MWI"),
            ISOCountryInfo(name: "Malaysia", numeric: "458", alpha2: "MY", alpha3: "MYS"),
            ISOCountryInfo(name: "Maldives", numeric: "462", alpha2: "MV", alpha3: "MDV"),
            ISOCountryInfo(name: "Mali", numeric: "466", alpha2: "ML", alpha3: "MLI"),
            ISOCountryInfo(name: "Malta", numeric: "470", alpha2: "MT", alpha3: "MLT"),
            ISOCountryInfo(name: "Marshall Islands", numeric: "584", alpha2: "MH", alpha3: "MHL"),
            ISOCountryInfo(name: "Martinique", numeric: "474", alpha2: "MQ", alpha3: "MTQ"),
            ISOCountryInfo(name: "Mauritania", numeric: "478", alpha2: "MR", alpha3: "MRT"),
            ISOCountryInfo(name: "Mauritius", numeric: "480", alpha2: "MU", alpha3: "MUS"),
            ISOCountryInfo(name: "Mayotte", numeric: "175", alpha2: "YT", alpha3: "MYT"),
            ISOCountryInfo(name: "Mexico", numeric: "484", alpha2: "MX", alpha3: "MEX"),
            ISOCountryInfo(name: "Micronesia, Federated States of", numeric: "583", alpha2: "FM", alpha3: "FSM"),
            ISOCountryInfo(name: "Moldova, Republic of", numeric: "498", alpha2: "MD", alpha3: "MDA"),
            ISOCountryInfo(name: "Monaco", numeric: "492", alpha2: "MC", alpha3: "MCO"),
            ISOCountryInfo(name: "Mongolia", numeric: "496", alpha2: "MN", alpha3: "MNG"),
            ISOCountryInfo(name: "Montenegro", numeric: "499", alpha2: "ME", alpha3: "MNE"),
            ISOCountryInfo(name: "Montserrat", numeric: "500", alpha2: "MS", alpha3: "MSR"),
            ISOCountryInfo(name: "Morocco", numeric: "504", alpha2: "MA", alpha3: "MAR"),
            ISOCountryInfo(name: "Mozambique", numeric: "508", alpha2: "MZ", alpha3: "MOZ"),
            ISOCountryInfo(name: "Myanmar", numeric: "104", alpha2: "MM", alpha3: "MMR"),
            ISOCountryInfo(name: "Namibia", numeric: "516", alpha2: "NA", alpha3: "NAM"),
            ISOCountryInfo(name: "Nauru", numeric: "520", alpha2: "NR", alpha3: "NRU"),
            ISOCountryInfo(name: "Nepal", numeric: "524", alpha2: "NP", alpha3: "NPL"),
            ISOCountryInfo(name: "Netherlands", numeric: "528", alpha2: "NL", alpha3: "NLD"),
            ISOCountryInfo(name: "Netherlands Antilles", numeric: "530", alpha2: "AN", alpha3: "ANT"),
            ISOCountryInfo(name: "New Caledonia", numeric: "540", alpha2: "NC", alpha3: "NCL"),
            ISOCountryInfo(name: "New Zealand", numeric: "554", alpha2: "NZ", alpha3: "NZL"),
            ISOCountryInfo(name: "Nicaragua", numeric: "558", alpha2: "NI", alpha3: "NIC"),
            ISOCountryInfo(name: "Niger", numeric: "562", alpha2: "NE", alpha3: "NER"),
            ISOCountryInfo(name: "Nigeria", numeric: "566", alpha2: "NG", alpha3: "NGA"),
            ISOCountryInfo(name: "Niue", numeric: "570", alpha2: "NU", alpha3: "NIU"),
            ISOCountryInfo(name: "Norfolk Island", numeric: "574", alpha2: "NF", alpha3: "NFK"),
            ISOCountryInfo(name: "Northern Mariana Islands", numeric: "580", alpha2: "MP", alpha3: "MNP"),
            ISOCountryInfo(name: "Norway", numeric: "578", alpha2: "NO", alpha3: "NOR"),
            ISOCountryInfo(name: "Oman", numeric: "512", alpha2: "OM", alpha3: "OMN"),
            ISOCountryInfo(name: "Pakistan", numeric: "586", alpha2: "PK", alpha3: "PAK"),
            ISOCountryInfo(name: "Palau", numeric: "585", alpha2: "PW", alpha3: "PLW"),
            ISOCountryInfo(name: "Palestine, State of", numeric: "275", alpha2: "PS", alpha3: "PSE"),
            ISOCountryInfo(name: "Panama", numeric: "591", alpha2: "PA", alpha3: "PAN"),
            ISOCountryInfo(name: "Papua New Guinea", numeric: "598", alpha2: "PG", alpha3: "PNG"),
            ISOCountryInfo(name: "Paraguay", numeric: "600", alpha2: "PY", alpha3: "PRY"),
            ISOCountryInfo(name: "Peru", numeric: "604", alpha2: "PE", alpha3: "PER"),
            ISOCountryInfo(name: "Philippines", numeric: "608", alpha2: "PH", alpha3: "PHL"),
            ISOCountryInfo(name: "Pitcairn", numeric: "612", alpha2: "PN", alpha3: "PCN"),
            ISOCountryInfo(name: "Poland", numeric: "616", alpha2: "PL", alpha3: "POL"),
            ISOCountryInfo(name: "Portugal", numeric: "620", alpha2: "PT", alpha3: "PRT"),
            ISOCountryInfo(name: "Puerto Rico", numeric: "630", alpha2: "PR", alpha3: "PRI"),
            ISOCountryInfo(name: "Qatar", numeric: "634", alpha2: "QA", alpha3: "QAT"),
            ISOCountryInfo(name: "Réunion", numeric: "638", alpha2: "RE", alpha3: "REU"),
            ISOCountryInfo(name: "Romania", numeric: "642", alpha2: "RO", alpha3: "ROU"),
            ISOCountryInfo(name: "Russian Federation", numeric: "643", alpha2: "RU", alpha3: "RUS"),
            ISOCountryInfo(name: "Rwanda", numeric: "646", alpha2: "RW", alpha3: "RWA"),
            ISOCountryInfo(name: "Saint Barthélemy", numeric: "652", alpha2: "BL", alpha3: "BLM"),
            ISOCountryInfo(name: "Saint Helena, Ascension and Tristan da Cunha", numeric: "654", alpha2: "SH", alpha3: "SHN"),
            ISOCountryInfo(name: "Saint Kitts and Nevis", numeric: "659", alpha2: "KN", alpha3: "KNA"),
            ISOCountryInfo(name: "Saint Lucia", numeric: "662", alpha2: "LC", alpha3: "LCA"),
            ISOCountryInfo(name: "Saint Martin (French part)", numeric: "663", alpha2: "MF", alpha3: "MAF"),
            ISOCountryInfo(name: "Saint Pierre and Miquelon", numeric: "666", alpha2: "PM", alpha3: "SPM"),
            ISOCountryInfo(name: "Saint Vincent and the Grenadines", numeric: "670", alpha2: "VC", alpha3: "VCT"),
            ISOCountryInfo(name: "Samoa", numeric: "882", alpha2: "WS", alpha3: "WSM"),
            ISOCountryInfo(name: "San Marino", numeric: "674", alpha2: "SM", alpha3: "SMR"),
            ISOCountryInfo(name: "Sao Tome and Principe", numeric: "678", alpha2: "ST", alpha3: "STP"),
            ISOCountryInfo(name: "Saudi Arabia", numeric: "682", alpha2: "SA", alpha3: "SAU"),
            ISOCountryInfo(name: "Senegal", numeric: "686", alpha2: "SN", alpha3: "SEN"),
            ISOCountryInfo(name: "Serbia", numeric: "688", alpha2: "RS", alpha3: "SRB"),
            ISOCountryInfo(name: "Seychelles", numeric: "690", alpha2: "SC", alpha3: "SYC"),
            ISOCountryInfo(name: "Sierra Leone", numeric: "694", alpha2: "SL", alpha3: "SLE"),
            ISOCountryInfo(name: "Singapore", numeric: "702", alpha2: "SG", alpha3: "SGP"),
            ISOCountryInfo(name: "Sint Maarten (Dutch part)", numeric: "534", alpha2: "SX", alpha3: "SXM"),
            ISOCountryInfo(name: "Slovakia", numeric: "703", alpha2: "SK", alpha3: "SVK"),
            ISOCountryInfo(name: "Slovenia", numeric: "705", alpha2: "SI", alpha3: "SVN"),
            ISOCountryInfo(name: "Solomon Islands", numeric: "090", alpha2: "SB", alpha3: "SLB"),
            ISOCountryInfo(name: "Somalia", numeric: "706", alpha2: "SO", alpha3: "SOM"),
            ISOCountryInfo(name: "South Africa", numeric: "710", alpha2: "ZA", alpha3: "ZAF"),
            ISOCountryInfo(name: "South Georgia and the South Sandwich Islands", numeric: "239", alpha2: "GS", alpha3: "SGS"),
            ISOCountryInfo(name: "South Sudan", numeric: "728", alpha2: "SS", alpha3: "SSD"),
            ISOCountryInfo(name: "Spain", numeric: "724", alpha2: "ES", alpha3: "ESP"),
            ISOCountryInfo(name: "Sri Lanka", numeric: "144", alpha2: "LK", alpha3: "LKA"),
            ISOCountryInfo(name: "Sudan", numeric: "729", alpha2: "SD", alpha3: "SDN"),
            ISOCountryInfo(name: "Suriname", numeric: "740", alpha2: "SR", alpha3: "SUR"),
            ISOCountryInfo(name: "Svalbard and Jan Mayen", numeric: "744", alpha2: "SJ", alpha3: "SJM"),
            ISOCountryInfo(name: "Swaziland", numeric: "748", alpha2: "SZ", alpha3: "SWZ"),
            ISOCountryInfo(name: "Sweden", numeric: "752", alpha2: "SE", alpha3: "SWE"),
            ISOCountryInfo(name: "Switzerland", numeric: "756", alpha2: "CH", alpha3: "CHE"),
            ISOCountryInfo(name: "Syrian Arab Republic", numeric: "760", alpha2: "SY", alpha3: "SYR"),
            ISOCountryInfo(name: "Taiwan, Province of China", numeric: "158", alpha2: "TW", alpha3: "TWN"),
            ISOCountryInfo(name: "Tajikistan", numeric: "762", alpha2: "TJ", alpha3: "TJK"),
            ISOCountryInfo(name: "Tanzania, United Republic of", numeric: "834", alpha2: "TZ", alpha3: "TZA"),
            ISOCountryInfo(name: "Thailand", numeric: "764", alpha2: "TH", alpha3: "THA"),
            ISOCountryInfo(name: "Timor-Leste", numeric: "626", alpha2: "TL", alpha3: "TLS"),
            ISOCountryInfo(name: "Togo", numeric: "768", alpha2: "TG", alpha3: "TGO"),
            ISOCountryInfo(name: "Tokelau", numeric: "772", alpha2: "TK", alpha3: "TKL"),
            ISOCountryInfo(name: "Tonga", numeric: "776", alpha2: "TO", alpha3: "TON"),
            ISOCountryInfo(name: "Trinidad and Tobago", numeric: "780", alpha2: "TT", alpha3: "TTO"),
            ISOCountryInfo(name: "Tunisia", numeric: "788", alpha2: "TN", alpha3: "TUN"),
            ISOCountryInfo(name: "Turkey", numeric: "792", alpha2: "TR", alpha3: "TUR"),
            ISOCountryInfo(name: "Turkmenistan", numeric: "795", alpha2: "TM", alpha3: "TKM"),
            ISOCountryInfo(name: "Turks and Caicos Islands", numeric: "796", alpha2: "TC", alpha3: "TCA"),
            ISOCountryInfo(name: "Tuvalu", numeric: "798", alpha2: "TV", alpha3: "TUV"),
            ISOCountryInfo(name: "Uganda", numeric: "800", alpha2: "UG", alpha3: "UGA"),
            ISOCountryInfo(name: "Ukraine", numeric: "804", alpha2: "UA", alpha3: "UKR"),
            ISOCountryInfo(name: "United Arab Emirates", numeric: "784", alpha2: "AE", alpha3: "ARE"),
            ISOCountryInfo(name: "United Kingdom", numeric: "826", alpha2: "GB", alpha3: "GBR"),
            ISOCountryInfo(name: "United States of America", numeric: "840", alpha2: "US", alpha3: "USA"),
            ISOCountryInfo(name: "United States Minor Outlying Islands", numeric: "581", alpha2: "UM", alpha3: "UMI"),
            ISOCountryInfo(name: "Uruguay", numeric: "858", alpha2: "UY", alpha3: "URY"),
            ISOCountryInfo(name: "Uzbekistan", numeric: "860", alpha2: "UZ", alpha3: "UZB"),
            ISOCountryInfo(name: "Vanuatu", numeric: "548", alpha2: "VU", alpha3: "VUT"),
            ISOCountryInfo(name: "Venezuela, Bolivarian Republic of", numeric: "862", alpha2: "VE", alpha3: "VEN"),
            ISOCountryInfo(name: "Vietnam", numeric: "704", alpha2: "VN", alpha3: "VNM"),
            ISOCountryInfo(name: "Virgin Islands, British", numeric: "092", alpha2: "VG", alpha3: "VGB"),
            ISOCountryInfo(name: "Virgin Islands, U.S.", numeric: "850", alpha2: "VI", alpha3: "VIR"),
            ISOCountryInfo(name: "Wallis and Futuna", numeric: "876", alpha2: "WF", alpha3: "WLF"),
            ISOCountryInfo(name: "Western Sahara", numeric: "732", alpha2: "EH", alpha3: "ESH"),
            ISOCountryInfo(name: "Yemen", numeric: "887", alpha2: "YE", alpha3: "YEM"),
            ISOCountryInfo(name: "Zambia", numeric: "894", alpha2: "ZM", alpha3: "ZMB"),
            ISOCountryInfo(name: "Zimbabwe", numeric: "716", alpha2: "ZW", alpha3: "ZWE")
        ]
        
        public static let listCountryCode: [String:String] = {
            var phoneCodeMapByCountry = [String: String]()
            phoneCodeMapByCountry["Afghanistan"] = "93"
            phoneCodeMapByCountry["Åland Islands"] = "358"
            phoneCodeMapByCountry["Albania"] = "355"
            phoneCodeMapByCountry["Algeria"] = "213"
            phoneCodeMapByCountry["American Samoa"] = "1-684"
            phoneCodeMapByCountry["Andorra"] = "376"
            phoneCodeMapByCountry["Angola"] = "244"
            phoneCodeMapByCountry["Anguilla"] = "1-264"
            phoneCodeMapByCountry["Antarctica"] = "672"
            phoneCodeMapByCountry["Antigua and Barbuda"] = "1-268"
            phoneCodeMapByCountry["Argentina"] = "54"
            phoneCodeMapByCountry["Armenia"] = "374"
            phoneCodeMapByCountry["Aruba"] = "297"
            phoneCodeMapByCountry["Australia"] = "61"
            phoneCodeMapByCountry["Austria"] = "43"
            phoneCodeMapByCountry["Azerbaijan"] = "994"
            phoneCodeMapByCountry["Bahamas"] = "1-242"
            phoneCodeMapByCountry["Bahrain"] = "973"
            phoneCodeMapByCountry["Bangladesh"] = "880"
            phoneCodeMapByCountry["Barbados"] = "1-246"
            phoneCodeMapByCountry["Belarus"] = "375"
            phoneCodeMapByCountry["Belgium"] = "32"
            phoneCodeMapByCountry["Belize"] = "501"
            phoneCodeMapByCountry["Benin"] = "229"
            phoneCodeMapByCountry["Bermuda"] = "1-441"
            phoneCodeMapByCountry["Bhutan"] = "975"
            phoneCodeMapByCountry["Bolivia (Plurinational State of)"] = "591"
            phoneCodeMapByCountry["Bonaire, Sint Eustatius and Saba"] = "599"
            phoneCodeMapByCountry["Bosnia and Herzegovina"] = "387"
            phoneCodeMapByCountry["Botswana"] = "267"
            phoneCodeMapByCountry["Bouvet Island"] = "55"
            phoneCodeMapByCountry["Brazil"] = "55"
            phoneCodeMapByCountry["British Indian Ocean Territory"] = "246"
            phoneCodeMapByCountry["Brunei Darussalam"] = "673"
            phoneCodeMapByCountry["Bulgaria"] = "359"
            phoneCodeMapByCountry["Burkina Faso"] = "226"
            phoneCodeMapByCountry["Burundi"] = "257"
            phoneCodeMapByCountry["Cambodia"] = "855"
            phoneCodeMapByCountry["Cameroon"] = "237"
            phoneCodeMapByCountry["Canada"] = "1"
            phoneCodeMapByCountry["Cabo Verde"] = "238"
            phoneCodeMapByCountry["Cayman Islands"] = "1-345"
            phoneCodeMapByCountry["Central African Republic"] = "236"
            phoneCodeMapByCountry["Chad"] = "235"
            phoneCodeMapByCountry["Chile"] = "56"
            phoneCodeMapByCountry["China"] = "86"
            phoneCodeMapByCountry["Christmas Island"] = "61"
            phoneCodeMapByCountry["Cocos (Keeling) Islands"] = "61"
            phoneCodeMapByCountry["Colombia"] = "57"
            phoneCodeMapByCountry["Comoros"] = "269"
            phoneCodeMapByCountry["Congo"] = "242"
            phoneCodeMapByCountry["Congo, Democratic Republic of the"] = "243"
            phoneCodeMapByCountry["Cook Islands"] = "682"
            phoneCodeMapByCountry["Costa Rica"] = "506"
            phoneCodeMapByCountry["Côte d'Ivoire"] = "225"
            phoneCodeMapByCountry["Croatia"] = "385"
            phoneCodeMapByCountry["Cuba"] = "53"
            phoneCodeMapByCountry["Curaçao"] = "599"
            phoneCodeMapByCountry["Cyprus"] = "357"
            phoneCodeMapByCountry["Czechia"] = "420"
            phoneCodeMapByCountry["Denmark"] = "45"
            phoneCodeMapByCountry["Djibouti"] = "253"
            phoneCodeMapByCountry["Dominica"] = "1-767"
            phoneCodeMapByCountry["Dominican Republic"] = "1-809, 1-829, 1-849"
            phoneCodeMapByCountry["Ecuador"] = "593"
            phoneCodeMapByCountry["Egypt"] = "20"
            phoneCodeMapByCountry["El Salvador"] = "503"
            phoneCodeMapByCountry["Equatorial Guinea"] = "240"
            phoneCodeMapByCountry["Eritrea"] = "291"
            phoneCodeMapByCountry["Estonia"] = "372"
            phoneCodeMapByCountry["Ethiopia"] = "251"
            phoneCodeMapByCountry["Falkland Islands (Malvinas)"] = "500"
            phoneCodeMapByCountry["Faroe Islands"] = "298"
            phoneCodeMapByCountry["Fiji"] = "679"
            phoneCodeMapByCountry["Finland"] = "358"
            phoneCodeMapByCountry["France"] = "33"
            phoneCodeMapByCountry["French Guiana"] = "594"
            phoneCodeMapByCountry["French Polynesia"] = "689"
            phoneCodeMapByCountry["French Southern Territories"] = "262"
            phoneCodeMapByCountry["Gabon"] = "241"
            phoneCodeMapByCountry["Gambia"] = "220"
            phoneCodeMapByCountry["Georgia"] = "995"
            phoneCodeMapByCountry["Germany"] = "49"
            phoneCodeMapByCountry["Ghana"] = "233"
            phoneCodeMapByCountry["Gibraltar"] = "350"
            phoneCodeMapByCountry["Greece"] = "30"
            phoneCodeMapByCountry["Greenland"] = "299"
            phoneCodeMapByCountry["Grenada"] = "1-473"
            phoneCodeMapByCountry["Guadeloupe"] = "590"
            phoneCodeMapByCountry["Guam"] = "1-671"
            phoneCodeMapByCountry["Guatemala"] = "502"
            phoneCodeMapByCountry["Guernsey"] = "44-1481"
            phoneCodeMapByCountry["Guinea"] = "224"
            phoneCodeMapByCountry["Guinea-Bissau"] = "245"
            phoneCodeMapByCountry["Guyana"] = "592"
            phoneCodeMapByCountry["Haiti"] = "509"
            phoneCodeMapByCountry["Heard Island and McDonald Islands"] = "672"
            phoneCodeMapByCountry["Holy See"] = "379"
            phoneCodeMapByCountry["Honduras"] = "504"
            phoneCodeMapByCountry["Hong Kong"] = "852"
            phoneCodeMapByCountry["Hungary"] = "36"
            phoneCodeMapByCountry["Iceland"] = "354"
            phoneCodeMapByCountry["India"] = "91"
            phoneCodeMapByCountry["Indonesia"] = "62"
            phoneCodeMapByCountry["Iran (Islamic Republic of)"] = "98"
            phoneCodeMapByCountry["Iraq"] = "964"
            phoneCodeMapByCountry["Ireland"] = "353"
            phoneCodeMapByCountry["Isle of Man"] = "44-1624"
            phoneCodeMapByCountry["Israel"] = "972"
            phoneCodeMapByCountry["Italy"] = "39"
            phoneCodeMapByCountry["Jamaica"] = "1-876"
            phoneCodeMapByCountry["Japan"] = "81"
            phoneCodeMapByCountry["Jersey"] = "44-1534"
            phoneCodeMapByCountry["Jordan"] = "962"
            phoneCodeMapByCountry["Kazakhstan"] = "7"
            phoneCodeMapByCountry["Kenya"] = "254"
            phoneCodeMapByCountry["Kiribati"] = "686"
            phoneCodeMapByCountry["Korea (Democratic People's Republic of)"] = "850"
            phoneCodeMapByCountry["Korea, Republic of"] = "82"
            phoneCodeMapByCountry["Kuwait"] = "965"
            phoneCodeMapByCountry["Kyrgyzstan"] = "996"
            phoneCodeMapByCountry["Lao People's Democratic Republic"] = "856"
            phoneCodeMapByCountry["Latvia"] = "371"
            phoneCodeMapByCountry["Lebanon"] = "961"
            phoneCodeMapByCountry["Lesotho"] = "266"
            phoneCodeMapByCountry["Liberia"] = "231"
            phoneCodeMapByCountry["Libya"] = "218"
            phoneCodeMapByCountry["Liechtenstein"] = "423"
            phoneCodeMapByCountry["Lithuania"] = "370"
            phoneCodeMapByCountry["Luxembourg"] = "352"
            phoneCodeMapByCountry["Macao"] = "853"
            phoneCodeMapByCountry["Macedonia, the former Yugoslav Republic of"] = "389"
            phoneCodeMapByCountry["Madagascar"] = "261"
            phoneCodeMapByCountry["Malawi"] = "265"
            phoneCodeMapByCountry["Malaysia"] = "60"
            phoneCodeMapByCountry["Maldives"] = "960"
            phoneCodeMapByCountry["Mali"] = "223"
            phoneCodeMapByCountry["Malta"] = "356"
            phoneCodeMapByCountry["Marshall Islands"] = "692"
            phoneCodeMapByCountry["Martinique"] = "596"
            phoneCodeMapByCountry["Mauritania"] = "222"
            phoneCodeMapByCountry["Mauritius"] = "230"
            phoneCodeMapByCountry["Mayotte"] = "262"
            phoneCodeMapByCountry["Mexico"] = "52"
            phoneCodeMapByCountry["Micronesia (Federated States of)"] = "691"
            phoneCodeMapByCountry["Moldova, Republic of"] = "373"
            phoneCodeMapByCountry["Monaco"] = "377"
            phoneCodeMapByCountry["Mongolia"] = "976"
            phoneCodeMapByCountry["Montenegro"] = "382"
            phoneCodeMapByCountry["Montserrat"] = "1-664"
            phoneCodeMapByCountry["Morocco"] = "212"
            phoneCodeMapByCountry["Mozambique"] = "258"
            phoneCodeMapByCountry["Myanmar"] = "95"
            phoneCodeMapByCountry["Namibia"] = "264"
            phoneCodeMapByCountry["Nauru"] = "674"
            phoneCodeMapByCountry["Nepal"] = "977"
            phoneCodeMapByCountry["Netherlands"] = "31"
            phoneCodeMapByCountry["Netherlands Antilles"] = "599"
            phoneCodeMapByCountry["New Caledonia"] = "687"
            phoneCodeMapByCountry["New Zealand"] = "64"
            phoneCodeMapByCountry["Nicaragua"] = "505"
            phoneCodeMapByCountry["Niger"] = "227"
            phoneCodeMapByCountry["Nigeria"] = "234"
            phoneCodeMapByCountry["Niue"] = "683"
            phoneCodeMapByCountry["Norfolk Island"] = "672"
            phoneCodeMapByCountry["Northern Mariana Islands"] = "1-670"
            phoneCodeMapByCountry["Norway"] = "47"
            phoneCodeMapByCountry["Oman"] = "968"
            phoneCodeMapByCountry["Pakistan"] = "92"
            phoneCodeMapByCountry["Palau"] = "680"
            phoneCodeMapByCountry["Palestine, State of"] = "970"
            phoneCodeMapByCountry["Panama"] = "507"
            phoneCodeMapByCountry["Papua New Guinea"] = "675"
            phoneCodeMapByCountry["Paraguay"] = "595"
            phoneCodeMapByCountry["Peru"] = "51"
            phoneCodeMapByCountry["Philippines"] = "63"
            phoneCodeMapByCountry["Pitcairn"] = "64"
            phoneCodeMapByCountry["Poland"] = "48"
            phoneCodeMapByCountry["Portugal"] = "351"
            phoneCodeMapByCountry["Puerto Rico"] = "1-787, 1-939"
            phoneCodeMapByCountry["Qatar"] = "974"
            phoneCodeMapByCountry["Réunion"] = "262"
            phoneCodeMapByCountry["Romania"] = "40"
            phoneCodeMapByCountry["Russian Federation"] = "7"
            phoneCodeMapByCountry["Rwanda"] = "250"
            phoneCodeMapByCountry["Saint Barthélemy"] = "590"
            phoneCodeMapByCountry["Saint Helena, Ascension and Tristan da Cunha"] = "290"
            phoneCodeMapByCountry["Saint Kitts and Nevis"] = "1-869"
            phoneCodeMapByCountry["Saint Lucia"] = "1-758"
            phoneCodeMapByCountry["Saint Martin (French part)"] = "590"
            phoneCodeMapByCountry["Saint Pierre and Miquelon"] = "508"
            phoneCodeMapByCountry["Saint Vincent and the Grenadines"] = "1-784"
            phoneCodeMapByCountry["Samoa"] = "685"
            phoneCodeMapByCountry["San Marino"] = "378"
            phoneCodeMapByCountry["Sao Tome and Principe"] = "239"
            phoneCodeMapByCountry["Saudi Arabia"] = "966"
            phoneCodeMapByCountry["Senegal"] = "221"
            phoneCodeMapByCountry["Serbia"] = "381"
            phoneCodeMapByCountry["Seychelles"] = "248"
            phoneCodeMapByCountry["Sierra Leone"] = "232"
            phoneCodeMapByCountry["Singapore"] = "65"
            phoneCodeMapByCountry["Sint Maarten (Dutch part)"] = "1-721"
            phoneCodeMapByCountry["Slovakia"] = "421"
            phoneCodeMapByCountry["Slovenia"] = "386"
            phoneCodeMapByCountry["Solomon Islands"] = "677"
            phoneCodeMapByCountry["Somalia"] = "252"
            phoneCodeMapByCountry["South Africa"] = "27"
            phoneCodeMapByCountry["South Georgia and the South Sandwich Islands"] = "500"
            phoneCodeMapByCountry["South Sudan"] = "211"
            phoneCodeMapByCountry["Spain"] = "34"
            phoneCodeMapByCountry["Sri Lanka"] = "94"
            phoneCodeMapByCountry["Sudan"] = "249"
            phoneCodeMapByCountry["Suriname"] = "597"
            phoneCodeMapByCountry["Svalbard and Jan Mayen"] = "47"
            phoneCodeMapByCountry["Swaziland"] = "268"
            phoneCodeMapByCountry["Sweden"] = "46"
            phoneCodeMapByCountry["Switzerland"] = "41"
            phoneCodeMapByCountry["Syrian Arab Republic"] = "963"
            phoneCodeMapByCountry["Taiwan, Province of China"] = "886"
            phoneCodeMapByCountry["Tajikistan"] = "992"
            phoneCodeMapByCountry["Tanzania, United Republic of"] = "255"
            phoneCodeMapByCountry["Thailand"] = "66"
            phoneCodeMapByCountry["Timor-Leste"] = "670"
            phoneCodeMapByCountry["Togo"] = "228"
            phoneCodeMapByCountry["Tokelau"] = "690"
            phoneCodeMapByCountry["Tonga"] = "676"
            phoneCodeMapByCountry["Trinidad and Tobago"] = "1-868"
            phoneCodeMapByCountry["Tunisia"] = "216"
            phoneCodeMapByCountry["Turkey"] = "90"
            phoneCodeMapByCountry["Turkmenistan"] = "993"
            phoneCodeMapByCountry["Turks and Caicos Islands"] = "1-649"
            phoneCodeMapByCountry["Tuvalu"] = "688"
            phoneCodeMapByCountry["Uganda"] = "256"
            phoneCodeMapByCountry["Ukraine"] = "380"
            phoneCodeMapByCountry["United Arab Emirates"] = "971"
            phoneCodeMapByCountry["United Kingdom of Great Britain and Northern Ireland"] = "44"
            phoneCodeMapByCountry["United States of America"] = "1"
            phoneCodeMapByCountry["United States Minor Outlying Islands"] = "1"
            phoneCodeMapByCountry["Uruguay"] = "598"
            phoneCodeMapByCountry["Uzbekistan"] = "998"
            phoneCodeMapByCountry["Vanuatu"] = "678"
            phoneCodeMapByCountry["Venezuela (Bolivarian Republic of)"] = "58"
            phoneCodeMapByCountry["Vietnam"] = "84"
            phoneCodeMapByCountry["Virgin Islands (British)"] = "1-284"
            phoneCodeMapByCountry["Virgin Islands (U.S.)"] = "1-340"
            phoneCodeMapByCountry["Wallis and Futuna"] = "681"
            phoneCodeMapByCountry["Western Sahara"] = "212"
            phoneCodeMapByCountry["Yemen"] = "967"
            phoneCodeMapByCountry["Zambia"] = "260"
            phoneCodeMapByCountry["Zimbabwe"] = "263"
            return phoneCodeMapByCountry
        }()

        static var countryMapByCountryCode: [String: String] {
            ISOCountryInfo.allCountries.reduce(into: [String: String]()) { $0[$1.alpha2] = $1.name }
        }

        static var countryCodeMapByCountry: [String: String] {
            ISOCountryInfo.allCountries.reduce(into: [String: String]()) { $0[$1.name] = $1.alpha2 }
        }

        static var countryCodeMapByNumericCode: [String: String] {
            ISOCountryInfo.allCountries.reduce(into: [String: String]()) { $0[$1.numeric] = $1.alpha2 }
        }

        static var numericCodeMapByCountryCode: [String: String] {
            ISOCountryInfo.allCountries.reduce(into: [String: String]()) { $0[$1.alpha2] = $1.numeric }
        }
    }
}
