import XCTest
@testable import GlobalPayments_iOS_SDK

/// Verifies the query parameter serialization for the settlement reporting endpoints.
/// These assertions are deterministic and do not depend on sandbox settlement data.
class GpApiReportingSettlementTests: XCTestCase {

    private let startDate = Date().addYears(-1).addDays(1)

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc",
            appKey: "DYcEE2GpSzblo0ib"
        ))
    }

    func test_report_find_settlement_transactions_query_params() {
        // GIVEN
        let builder = ReportingService
            .findSettlementTransactionsPaged(page: 2, pageSize: 50)
            .orderBy(transactionSortProperty: .timeCreated, .descending)
            .withOrderReference("order-1234")
            .withSettlementTransactionReference("stx-5678")
            .withSettlementCode("SETTLED")
            .withMerchantDbaName("Test Merchant")
            .withTerminalId("term-9012")
            .withMerchantAmount(NSDecimalNumber(string: "12.34"))
            .withChargeTypeRegion("US")
            .withStartTransactionTimeCreatedReference(startDate)
            .withEndTransactionTimeCreatedReference(Date())
            .withMerchantName("merchant-name")

        // WHEN
        let request = GpApiReportRequestBuilder<PagedResult<TransactionSummary>>()
            .generateRequest(for: builder, config: GpApiConfig())

        // THEN
        let params = request?.queryParams ?? [:]
        XCTAssertEqual(request?.endpoint, GpApiRequest.Endpoints.settlementTransactions())
        XCTAssertEqual(params["page"], "2")
        XCTAssertEqual(params["page_size"], "50")
        XCTAssertEqual(params["order_by"], "TIME_CREATED")
        XCTAssertEqual(params["order"], "DESC")
        XCTAssertEqual(params["order.reference"], "order-1234")
        XCTAssertEqual(params["settlement_transaction_reference"], "stx-5678")
        XCTAssertEqual(params["settlement_code"], "SETTLED")
        XCTAssertEqual(params["merchant_name"], "merchant-name")
        XCTAssertEqual(params["merchant_amount"], "1234")
        XCTAssertEqual(params["charge_type_region"], "US")
        XCTAssertEqual(params["from_time_created_reference"], startDate.format("yyyy-MM-dd"))
        XCTAssertNotNil(params["to_time_created_reference"])
    }

    func test_report_find_settlement_transactions_fee_params() {
        // GIVEN
        let builder = ReportingService
            .findSettlementTransactionsPaged(page: 1, pageSize: 10)
            .withFeeChargeType("GLOBAL")
            .withFeeTotalAmount(NSDecimalNumber(string: "1.25"))
            .withInterchangeProgram("VISA CREDIT")
            .withInterchangePerItemFlatAmount(NSDecimalNumber(string: "0.1"))
            .withInterchangePerItemCalculatedAmount(NSDecimalNumber(string: "0.2"))
            .withInterchangePercentage("1.75")
            .withInterchangePercentageAmount(NSDecimalNumber(string: "0.3"))
            .withInterchangeTotalRate("1.85")
            .withInterchangeTotalAmount(NSDecimalNumber(string: "0.4"))
            .withDiscountRate1Percentage("0.1")
            .withDiscountRate2Percentage("0.2")
            .withDiscountTotalAmount(NSDecimalNumber(string: "0.5"))
            .withExchangeRate("1.01")
            .withAssessmentTotalAmount(NSDecimalNumber(string: "0.6"))
            .withAssessmentDescription(1, "Assessment One")
            .withAssessmentPercentage(1, "0.7")
            .withAssessmentAmount(1, NSDecimalNumber(string: "0.8"))
            .withMarkUpDccPercentage("3")
            .withMarkUpMulticurrencyPercentage("2")
            .withFixedAmount(NSDecimalNumber(string: "1.29"))
            .withFeeTaxAmount(NSDecimalNumber(string: "0.98"))

        // WHEN
        let request = GpApiReportRequestBuilder<PagedResult<TransactionSummary>>()
            .generateRequest(for: builder, config: GpApiConfig())

        // THEN
        let params = request?.queryParams ?? [:]
        XCTAssertEqual(params["fees.charge_type"], "GLOBAL")
        XCTAssertEqual(params["fees.total_amount_decimal"], "1.25")
        XCTAssertEqual(params["fees.interchange.program"], "VISA CREDIT")
        XCTAssertEqual(params["fees.interchange.per_item_flat_amount_decimal"], "0.1")
        XCTAssertEqual(params["fees.interchange.per_item_calculated_amount_decimal"], "0.2")
        XCTAssertEqual(params["fees.interchange.percentage"], "1.75")
        XCTAssertEqual(params["fees.interchange.percentage_amount_decimal"], "0.3")
        XCTAssertEqual(params["fees.interchange.total_rate"], "1.85")
        XCTAssertEqual(params["fees.interchange.total_amount_decimal"], "0.4")
        XCTAssertEqual(params["fees.discount.rate_1_percentage"], "0.1")
        XCTAssertEqual(params["fees.discount.rate_2_percentage"], "0.2")
        XCTAssertEqual(params["fees.discount.total_amount_decimal"], "0.5")
        XCTAssertEqual(params["fees.exchange_rate"], "1.01")
        XCTAssertEqual(params["fees.assessment_total_amount_decimal"], "0.6")
        XCTAssertEqual(params["fees.assessment_1.description"], "Assessment One")
        XCTAssertEqual(params["fees.assessment_1.percentage"], "0.7")
        XCTAssertEqual(params["fees.assessment_1.amount_decimal"], "0.8")
        XCTAssertEqual(params["fees.mark_up.dcc_percentage"], "3")
        XCTAssertEqual(params["fees.mark_up.multicurrency_percentage"], "2")
        XCTAssertEqual(params["fees.fixed_amount_decimal"], "1.29")
        XCTAssertEqual(params["fees.tax_amount_decimal"], "0.98")
    }

    func test_report_find_settlement_disputes_query_params() {
        // GIVEN
        let builder = ReportingService
            .findSettlementDisputesPaged(page: 1, pageSize: 10)
            .withSettlementDisputeId("DIS_SAND_1234")
            .withOrderReference("order-1234")
            .withBrandReference("brand-5678")
            .withAuthCode("auth-9012")
            .withReferenceNumber("reference-3456")
            .withDepositId("DEP_1234")
            .withDisputeStatus(.underReview)

        // WHEN
        let request = GpApiReportRequestBuilder<PagedResult<DisputeSummary>>()
            .generateRequest(for: builder, config: GpApiConfig())

        // THEN
        let params = request?.queryParams ?? [:]
        XCTAssertEqual(request?.endpoint, GpApiRequest.Endpoints.settlementDisputes())
        XCTAssertEqual(params["id"], "DIS_SAND_1234")
        XCTAssertEqual(params["order.reference"], "order-1234")
        XCTAssertEqual(params["brand_reference"], "brand-5678")
        XCTAssertEqual(params["authcode"], "auth-9012")
        XCTAssertEqual(params["reference"], "reference-3456")
        XCTAssertEqual(params["deposit.id"], "DEP_1234")
        XCTAssertEqual(params["status"], DisputeStatus.underReview.mapped(for: .gpApi))
    }

    func test_report_find_monthly_fees_query_params() {
        // GIVEN
        let builder = ReportingService
            .findMonthlyFeesPaged(page: 3, pageSize: 25)
            .orderBy(monthlyFeeOrderBy: .timeCreated, .descending)

        // WHEN
        let request = GpApiReportRequestBuilder<PagedResult<MonthlyFeeSummary>>()
            .generateRequest(for: builder, config: GpApiConfig())

        // THEN
        let params = request?.queryParams ?? [:]
        XCTAssertEqual(request?.endpoint, GpApiRequest.Endpoints.monthlyFees())
        XCTAssertEqual(params["page"], "3")
        XCTAssertEqual(params["page_size"], "25")
        XCTAssertEqual(params["order_by"], "TIME_CREATED")
        XCTAssertEqual(params["order"], "DESC")
        XCTAssertNil(params["from_time_created"])
    }

    func test_report_deposit_detail_query_params_are_empty() {
        // GIVEN
        let builder = ReportingService
            .depositDetail(depositReference: "DEP_1234")

        // WHEN
        let request = GpApiReportRequestBuilder<DepositSummary>()
            .generateRequest(for: builder, config: GpApiConfig())

        // THEN
        XCTAssertEqual(request?.endpoint, GpApiRequest.Endpoints.deposit(id: "DEP_1234"))
        XCTAssertTrue(request?.queryParams?.isEmpty ?? true)
    }
}