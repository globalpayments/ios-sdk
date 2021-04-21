import XCTest
import GlobalPayments_iOS_SDK

class CountryUtilsTests: XCTestCase {

    func test_get_country_code_exact() {
        // GIVEN
        let expectedResult = "IE"

        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("Ireland")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }

    func test_get_country_code_misspelled() {
        // GIVEN
        let expectedResult = "AF"

        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("Afganistan")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }

    func test_get_country_code_from_partial() {
        // GIVEN
        let expectedResult = "CF"

        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("African Republic")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }

    func test_get_country_code_by_exact_code() {
        // GIVEN
        let expectedResult = "IE"

        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("IE")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }

    func test_get_country_code_by_partial_code() {
        // GIVEN
        let expectedResult = "US"

        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("USA")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }

    func test_get_country_code_nil() {
        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry(nil)

        // THEN
        XCTAssertNil(result)
    }

    func test_get_country_code_fake_country() {
        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("FakeCountry")

        // THEN
        XCTAssertNil(result)
    }

    func test_get_country_code_fake_country_2() {
        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("Fakeistan")

        // THEN
        XCTAssertNil(result)
    }

    func test_get_country_code_fake_country_3() {
        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("MyRussia")

        // THEN
        XCTAssertNil(result)
    }

    func test_get_country_by_code_exact() {
        // GIVEN
        let expectedResult = "Ireland"

        // WHEN
        let result = CountryUtils.shared.countryByCode("IE")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }

    func test_get_country_by_three_digit_code() {
        // GIVEN
        let expectedResult = "United States of America"

        // WHEN
        let result = CountryUtils.shared.countryByCode("USA")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }

    func test_get_country_code_by_valid_numeric_code() {
        // GIVEN
        let expectedResult = "US"

        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("840")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }

    func test_get_country_code_by_invalid_numeric_code() {
        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry("1")

        // THEN
        XCTAssertNil(result)
    }

    func test_get_country_by_code_nil() {
        // WHEN
        let result = CountryUtils.shared.countryCodeByCountry(nil)

        // THEN
        XCTAssertNil(result)
    }

    func test_get_numeric_code_by_two_digit_code() {
        // WHEN
        let result = CountryUtils.shared.numericCodeByCountry("US")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "840")
    }

    func test_get_numeric_code_by_three_digit_code() {
        // WHEN
        let result = CountryUtils.shared.numericCodeByCountry("USA")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "840")
    }

    func test_get_numeric_code_by_country_name() {
        // WHEN
        let result = CountryUtils.shared.numericCodeByCountry("United States of America")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "840")
    }

    func test_get_numeric_code_by_numeric_code() {
        // WHEN
        let result = CountryUtils.shared.numericCodeByCountry("840")

        // THEN
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "840")
    }

    func test_get_numeric_code_by_non_existing_country_name() {
        // WHEN
        let result = CountryUtils.shared.numericCodeByCountry("Fake Country Name")

        // THEN
        XCTAssertNil(result)
    }

    func test_check_address_code_from_country_exact() {
        // GIVEN
        let address = Address()
        let expectedCountryCode = "US"

        // WHEN
        address.country = "United States of America"

        // THEN
        XCTAssertNotNil(address.countryCode)
        XCTAssertEqual(address.countryCode, expectedCountryCode)
    }

    func test_check_address_country_from_code_exact() {
        // GIVEN
        let address = Address()
        let expectedCountry = "United States of America"

        // WHEN
        address.countryCode = "US"

        // THEN
        XCTAssertNotNil(address.country)
        XCTAssertEqual(address.country, expectedCountry)
    }

    func test_check_address_code_from_country_fuzzy() {
        // GIVEN
        let address = Address()
        let expectedCountryCode = "AF"

        // WHEN
        address.country = "Afganistan"

        // THEN
        XCTAssertNotNil(address.countryCode)
        XCTAssertEqual(address.countryCode, expectedCountryCode)
    }

    func test_check_address_country_from_code_fuzzy() {
        // GIVEN
        let address = Address()
        let expectedCountry = "United States of America"

        // WHEN
        address.countryCode = "USA"

        // THEN
        XCTAssertNotNil(address.country)
        XCTAssertEqual(address.country, expectedCountry)
    }

    func test_address_isCountry_exact_match() {
        // GIVEN
        let address = Address()

        // WHEN
        address.country = "United States of America"

        // THEN
        XCTAssertTrue(address.isCountry("US"))
    }

    func test_check_address_country_code_from_valid_numeric_code() {
        // GIVEN
        let address = Address()

        // WHEN
        address.country = "056"

        // THEN
        XCTAssertNotNil(address.countryCode)
        XCTAssertEqual(address.countryCode, "BE")
    }

    func test_check_address_country_code_from_invalid_numeric_code() {
        // GIVEN
        let address = Address()

        // WHEN
        address.country = "1"

        // THEN
        XCTAssertNil(address.countryCode)
    }

    func test_address_isCountry_exact_missmatch() {
        // GIVEN
        let address = Address()

        // WHEN
        address.country = "United States"

        // THEN
        XCTAssertFalse(address.isCountry("GB"))
    }

    func test_address_isCountry_fuzzy_match() {
        // GIVEN
        let address = Address()

        // WHEN
        address.country = "Afganistan"

        // THEN
        XCTAssertTrue(address.isCountry("AF"))
    }

    func test_address_isCountry_fuzzy_mismatch() {
        // GIVEN
        let address = Address()

        // WHEN
        address.country = "Afganistan"

        // THEN
        XCTAssertFalse(address.isCountry("GB"))
    }

    func test_country_is_GB_no_street_address1() throws {
        // GIVEN
        let address = Address()
        address.country = "GB"
        address.postalCode = "E77 4Qj"

        let card = CreditCardData()
        card.number = "4111111111111111"
        card.expMonth = 12
        card.expYear = 2025
        card.cvn = "123"
        card.cardHolderName = "Joe Smith"

        let gpApiConfig = GpApiConfig(
            appId: "Uyq6PzRbkorv2D4RQGlldEtunEeGNZll",
            appKey: "QDsW1ETQKHX6Y4TA",
            country: "GB"
        )
        try ServicesContainer.configureService(config: gpApiConfig)

        let chargeExpectation = expectation(description: "Charge Expectation")
        var transactionResponse: Transaction?
        var transactionError: Error?

        // WHEN
        card.charge(amount: 10)
            .withCurrency("GBP")
            .withAddress(address)
            .execute { transaction, error in
                transactionResponse = transaction
                transactionError = error
                chargeExpectation.fulfill()
        }

        // THEN
        wait(for: [chargeExpectation], timeout: 10.0)
        XCTAssertNotNil(transactionResponse)
        XCTAssertNil(transactionError)
        XCTAssertEqual(transactionResponse?.responseCode, "SUCCESS")
    }
}
