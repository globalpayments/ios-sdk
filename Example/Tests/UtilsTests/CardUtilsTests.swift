import XCTest
import GlobalPayments_iOS_SDK

class CardUtilsTests: XCTestCase {

    func test_mapCardType_missingNumber() {
        // GIVEN
        let expectedResult = "Unknown"

        // WHEN
        let result = CardUtils.mapCardType(cardNumber: nil)

        // THEN
        XCTAssertEqual(result, expectedResult)
    }

    func test_mapCardType_Amex() {
        // GIVEN
        let validAmex = "3400 0000 0000 009"
        let invalidAmex = "lorem ipsum"
        let expectedResult = "Amex"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validAmex)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidAmex)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_Mastercard() {
        // GIVEN
        let validMC = "5500 0000 0000 0004"
        let invalidMC = "lorem ipsum"
        let expectedResult = "MC"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validMC)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidMC)

        // THEN
        XCTAssertEqual(expectedResult, successfulResult)
        XCTAssertEqual(expectedFailure, failureResult)
    }

    func test_mapCardType_Visa() {
        // GIVEN
        let validVisa = "4111-1111-1111-1111"
        let invalidVisa = "lorem ipsum"
        let expectedResult = "Visa"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validVisa)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidVisa)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_DinersClub() {
        // GIVEN
        let validDinersClub = "3000 0000 0000 04"
        let invalidDinersClub = "lorem ipsum"
        let expectedResult = "DinersClub"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validDinersClub)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidDinersClub)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_EnRoute() {
        // GIVEN
        let validEnRoute = "2014 0000 0000 009"
        let invalidEnRoute = "lorem ipsum"
        let expectedResult = "EnRoute"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validEnRoute)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidEnRoute)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_Discover() {
        // GIVEN
        let validDiscover = "6011 0000 0000 0004"
        let invalidDiscover = "lorem ipsum"
        let expectedResult = "Discover"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validDiscover)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidDiscover)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_Jcb() {
        // GIVEN
        let validJcb = "3569 9900 1009 5841"
        let invalidJcb = "lorem ipsum"
        let expectedResult = "Jcb"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validJcb)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidJcb)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_Voyager() {
        // GIVEN
        let validVoyager = "7088869008250005056"
        let invalidVoyager = "lorem ipsum"
        let expectedResult = "Voyager"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validVoyager)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidVoyager)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_HeartlandGift() {
        // GIVEN
        let validHeartlandGift = "70835500000001113=20121019999888877712"
        let invalidHeartlandGift = "lorem ipsum"
        let expectedResult = "HeartlandGift"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validHeartlandGift)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidHeartlandGift)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_StoredValue() {
        // GIVEN
        let validStoredValue = "6394700000001113=20121019999888877712"
        let invalidStoredValue = "lorem ipsum"
        let expectedResult = "StoredValue"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validStoredValue)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidStoredValue)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_mapCardType_ValueLink() {
        // GIVEN
        let validValueLink = "6032250000001113=20121019999888877712"
        let invalidValueLink = "lorem ipsum"
        let expectedResult = "ValueLink"
        let expectedFailure = "Unknown"

        // WHEN
        let successfulResult = CardUtils.mapCardType(cardNumber: validValueLink)
        let failureResult = CardUtils.mapCardType(cardNumber: invalidValueLink)

        // THEN
        XCTAssertEqual(successfulResult, expectedResult)
        XCTAssertEqual(failureResult, expectedFailure)
    }

    func test_strip_fleet_cardType() {
        // GIVEN
        let validValueCardType = "MCFLEET"
        let expectedResult = "MC"

        // WHEN
        let result = CardUtils.getBaseCardType(cardType: validValueCardType)

        // THEN
        XCTAssertEqual(result, expectedResult)
    }
}
