import Foundation

/// Represents a billing or shipping address for the consumer.
public class Address: NSObject {
    /// Address type. Default is billing
    public var type: AddressType = .billing
    /// Consumer's street address 1.
    public var streetAddress1: String?
    /// Consumer's street address 2.
    public var streetAddress2: String?
    /// Consumer's street address 3.
    public var streetAddress3: String?
    /// Consumer's city.
    public var city: String?
    /// Consumer's name.
    public var name: String?
    /// Consumer's province.
    public var province: String?
    /// Consumer's postal/zip code.
    public var postalCode: String?
    /// Consumer's country.
    public var country: String? {
        didSet {
            if countryCode == nil {
                countryCode = CountryUtils.shared.getCountryCodeByCountry(country)
            }
        }
    }
    /// Consumer's country code
    public var countryCode: String? {
        didSet {
            if country == nil {
                country = CountryUtils.shared.getCountryByCode(countryCode)
            }
        }
    }
}
