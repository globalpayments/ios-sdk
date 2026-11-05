import XCTest
import GlobalPayments_iOS_SDK

class GpApiMappingTests: XCTestCase {
    
    private let dataTest = "PMT_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7"

    func test_map_transaction_without_card() {
        // GIVEN
        let rawJson = "{\"id\":\"PMT_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7\",\"time_created\":\"2020-05-01T01:53:20.649Z\",\"time_last_updated\":\"2020-05-01T01:53:24.481Z\",\"status\":\"CAPTURED\",\"type\":\"SALE\",\"merchant_id\":\"MER_c4c0df11039c48a9b63701adeaa296c3\",\"merchant_name\":\"Sandbox_merchant_2\",\"account_id\":\"TRA_6716058969854a48b33347043ff8225f\",\"account_name\":\"Transaction_Processing\",\"channel\":\"CNP\",\"amount\":\"10000\",\"currency\":\"CAD\",\"reference\":\"My-TRANS-184398064\",\"description\":\"\",\"order_reference\":\"\",\"time_created_reference\":\"\",\"batch_id\":\"BAT_783464\",\"initiator\":\"\",\"country\":\"US\",\"language\":\"\",\"ip_address\":\"97.107.232.5\",\"site_reference\":\"\",\"payment_method\":{\"result\":\"00\",\"message\":\"Settled Successfully\",\"entry_mode\":\"ECOM\",\"name\":\"\",\"card\":{\"funding\":\"CREDIT\",\"brand\":\"MC\",\"authcode\":\"12345\",\"brand_reference\":\"\",\"masked_number_first6last4\":\"\",\"cvv_indicator\":\"\",\"cvv_result\":\"\",\"avs_address_result\":\"\",\"avs_postal_code_result\":\"MATCHED\",\"avs_address_result\":\"MATCHED\",\"avs_action\":\"\"}},\"action_create_id\":\"ACT_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7\",\"parent_resource_id\":\"TRN_JP9qn3ivl6iPNFRFSiCHesn0I5gs7t\",\"action\":{\"id\":\"ACT_k2incP0JYsIVRSJ8nzzSZm3gGWoNbr\",\"type\":\"TRANSACTION_SINGLE\",\"time_created\":\"2020-12-04T12:28:25.712Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"i9R0byBBor6RqTQNj3g4MuVBwH5rd7yR\",\"app_name\":\"demo_app\"}}"
        
        let doc = JsonDoc.parse(rawJson)
        let expectedTransactionId = "PMT_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7"
        let expectedBalanceAmount: NSDecimalNumber = 100
        let expectedTimestamp = "2020-05-01T01:53:20.649Z"
        let expectedResponseMessage = "CAPTURED"
        let expectedReferenceNumber = "My-TRANS-184398064"
        let expectedBatchSummary = "BAT_783464"
        let expectedResponseCode = "SUCCESS"
        let expectedToken = dataTest
        // authorizationCode is sourced from payment_method.card.authcode, not payment_method.result.
        let expectedAuthorizationCode = "12345"
        let expectedAvsAddressResult = "MATCHED"
        let expectedAvsPostalCode = "MATCHED"
        

        // WHEN
        let transaction = GpApiMapping.mapTransaction(doc)

        // THEN
        XCTAssertEqual(transaction.transactionId, expectedTransactionId)
        XCTAssertEqual(transaction.balanceAmount, expectedBalanceAmount)
        XCTAssertEqual(transaction.timestamp, expectedTimestamp)
        XCTAssertEqual(transaction.responseMessage, expectedResponseMessage)
        XCTAssertEqual(transaction.referenceNumber, expectedReferenceNumber)
        XCTAssertEqual(transaction.batchSummary?.batchReference, expectedBatchSummary)
        XCTAssertEqual(transaction.responseCode, expectedResponseCode)
        XCTAssertEqual(transaction.token, expectedToken)
        XCTAssertEqual(transaction.authorizationCode, expectedAuthorizationCode)
        XCTAssertEqual(transaction.avsAddressResponse, expectedAvsAddressResult)
        XCTAssertEqual(transaction.avsResponseCode, expectedAvsPostalCode)
    }

    func test_map_transaction_with_card() {
        // GIVEN
        let rawJson = "{\"id\":\"PMT_973812df-08f8-408e-9256-0000a540dd4f\",\"time_created\":\"2020-12-04T13:13:13.680Z\",\"status\":\"ACTIVE\",\"reference\":\"7EC6BAA5-4E21-4DAA-99D3-1F1315D7F8C6\",\"merchant_id\":\"MER_c4c0df11039c48a9b63701adeaa296c3\",\"merchant_name\":\"Sandbox_merchant_2\",\"account_id\":\"TKA_eba30a1b5c4a468d90ceeef2ffff7f5e\",\"account_name\":\"Tokenization\",\"result\":\"00\",\"message\":\"Successful\",\"card\":{\"masked_number_last4\":\"XXXXXXXXXXXX1111\",\"brand\":\"VISA\",\"expiry_month\":\"12\",\"expiry_year\":\"25\"},\"action\":{\"id\":\"ACT_3BEE01W8AKc8dDutEQmavbhdM9SAUc\",\"type\":\"PAYMENT_METHOD_CREATE\",\"time_created\":\"2020-12-04T13:13:13.680Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"Uyq6PzRbkorv2D4RQGlldEtunEeGNZll\",\"app_name\":\"sample_app_CERT\"}}"

        let doc = JsonDoc.parse(rawJson)
        let expectedTransactionId = "PMT_973812df-08f8-408e-9256-0000a540dd4f"
        let expectedTimestamp = "2020-12-04T13:13:13.680Z"
        let expectedResponseMessage = "ACTIVE"
        let expectedReferenceNumber = "7EC6BAA5-4E21-4DAA-99D3-1F1315D7F8C6"
        let expectedResponseCode = "SUCCESS"
        let expectedToken = "PMT_973812df-08f8-408e-9256-0000a540dd4f"
        let expectedMaskedNumberLast4 = "XXXXXXXXXXXX1111"
        let expectedBrand = "VISA"
        let expectedCardExpMonth = 12
        let expectedCardExpYear = 25

        // WHEN
        let transaction = GpApiMapping.mapTransaction(doc)

        // THEN
        XCTAssertEqual(transaction.transactionId, expectedTransactionId)
        XCTAssertEqual(transaction.timestamp, expectedTimestamp)
        XCTAssertEqual(transaction.responseMessage, expectedResponseMessage)
        XCTAssertEqual(transaction.referenceNumber, expectedReferenceNumber)
        XCTAssertEqual(transaction.responseCode, expectedResponseCode)
        XCTAssertEqual(transaction.token, expectedToken)
        XCTAssertEqual(transaction.cardDetails?.maskedNumberLast4, expectedMaskedNumberLast4)
        XCTAssertEqual(transaction.cardDetails?.brand, expectedBrand)
        XCTAssertEqual(transaction.cardDetails?.cardExpMonth, expectedCardExpMonth)
        XCTAssertEqual(transaction.cardDetails?.cardExpYear, expectedCardExpYear)
    }

    func test_map_transaction_summary() {
        // GIVEN
        let rawJson = "{\"id\":\"TRN_TvY1QFXxQKtaFSjNaLnDVdo3PZ7ivz\",\"time_created\":\"2020-06-05T03:08:20.896Z\",\"time_last_updated\":\"\",\"status\":\"PREAUTHORIZED\",\"type\":\"SALE\",\"merchant_id\":\"MER_c4c0df11039c48a9b63701adeaa296c3\",\"merchant_name\":\"Sandbox_merchant_2\",\"account_id\":\"TRA_6716058969854a48b33347043ff8225f\",\"account_name\":\"Transaction_Processing\",\"channel\":\"CNP\",\"amount\":\"10000\",\"currency\":\"CAD\",\"reference\":\"My-TRANS-184398775\",\"description\":\"41e7877b-da90-4c5f-befe-7f024b96311e\",\"order_reference\":\"\",\"time_created_reference\":\"\",\"batch_id\":\"123HG\",\"initiator\":\"\",\"country\":\"USA\",\"language\":\"\",\"ip_address\":\"97.107.232.5\",\"site_reference\":\"\",\"payment_method\":{\"result\":\"00\",\"message\":\"SUCCESS\",\"entry_mode\":\"ECOM\",\"name\":\"James Mason\",\"card\":{\"funding\":\"CREDIT\",\"brand\":\"VISA\",\"authcode\":\"12345\",\"brand_reference\":\"TQ76bJf7qzkC30U0\",\"masked_number_first6last4\":\"411111XXXXXX1111\",\"cvv_indicator\":\"PRESENT\",\"cvv_result\":\"MATCHED\",\"avs_address_result\":\"MATCHED\",\"avs_postal_code_result\":\"MATCHED\"}},\"action_create_id\":\"ACT_TvY1QFXxQKtaFSjNaLnDVdo3PZ7ivz\",\"parent_resource_id\":\"TRN_TvY1QFXxQKtaFSjNaLnDVdo3PZ7ivz\",\"action\":{\"id\":\"ACT_kLkU0qND7wyuW0Br76ZNyAnlPTjHsb\",\"type\":\"TRANSACTION_SINGLE\",\"time_created\":\"2020-11-24T15:43:43.990Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"JF2GQpeCrOivkBGsTRiqkpkdKp67Gxi0\",\"app_name\":\"test_app\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedTransactionId = "TRN_TvY1QFXxQKtaFSjNaLnDVdo3PZ7ivz"
        let expectedTransactionDate = "2020-06-05T03:08:20.896Z".format()
        let expectedTransactionStatus: TransactionStatus = .preauthorized
        let expectedTransactionType = "SALE"
        let expectedChannel = "CNP"
        let expectedAmount: NSDecimalNumber = 100
        let expectedCurrency = "CAD"
        let expectedReferenceNumber = "My-TRANS-184398775"
        let expectedClientTransactionId = "My-TRANS-184398775"
        let expectedBatchSequenceNumber = "123HG"
        let expectedCountry = "USA"
        let expectedOriginalTransactionId = "TRN_TvY1QFXxQKtaFSjNaLnDVdo3PZ7ivz"
        let expectedGatewayResponseMessage = "SUCCESS"
        let expectedEntryMode = "ECOM"
        let expectedCardType = "VISA"
        let expectedAuthCode = "12345"
        let expectedBrandReference = "TQ76bJf7qzkC30U0"
        let expectedAquirerReferenceNumber: String? = nil
        let expectedMaskedCardNumber = "411111XXXXXX1111"
        let expectedDepositReference: String? = nil
        let expectedDepositStatus: DepositStatus? = nil
        let expectedCardHolderName = "James Mason"

        // WHEN
        let transactionSummary = GpApiMapping.mapTransactionSummary(doc)

        // THEN
        XCTAssertEqual(transactionSummary.transactionId, expectedTransactionId)
        XCTAssertEqual(transactionSummary.transactionDate, expectedTransactionDate)
        XCTAssertEqual(transactionSummary.transactionStatus, expectedTransactionStatus)
        XCTAssertEqual(transactionSummary.transactionType, expectedTransactionType)
        XCTAssertEqual(transactionSummary.channel, expectedChannel)
        XCTAssertEqual(transactionSummary.amount, expectedAmount)
        XCTAssertEqual(transactionSummary.currency, expectedCurrency)
        XCTAssertEqual(transactionSummary.referenceNumber, expectedReferenceNumber)
        XCTAssertEqual(transactionSummary.clientTransactionId, expectedClientTransactionId)
        XCTAssertEqual(transactionSummary.batchSequenceNumber, expectedBatchSequenceNumber)
        XCTAssertEqual(transactionSummary.country, expectedCountry)
        XCTAssertEqual(transactionSummary.originalTransactionId, expectedOriginalTransactionId)
        XCTAssertEqual(transactionSummary.gatewayResponseMessage, expectedGatewayResponseMessage)
        XCTAssertEqual(transactionSummary.entryMode, expectedEntryMode)
        XCTAssertEqual(transactionSummary.cardType, expectedCardType)
        XCTAssertEqual(transactionSummary.authCode, expectedAuthCode)
        XCTAssertEqual(transactionSummary.brandReference, expectedBrandReference)
        XCTAssertEqual(transactionSummary.aquirerReferenceNumber, expectedAquirerReferenceNumber)
        XCTAssertEqual(transactionSummary.maskedCardNumber, expectedMaskedCardNumber)
        XCTAssertEqual(transactionSummary.depositReference, expectedDepositReference)
        XCTAssertEqual(transactionSummary.depositStatus, expectedDepositStatus)
        XCTAssertEqual(transactionSummary.cardHolderName, expectedCardHolderName)
    }

    func test_map_deposit_summary() {
        // GIVEN
        let rawJson = "{\"id\":\"DEP_2342423423\",\"time_created\":\"2020-11-21\",\"status\":\"FUNDED\",\"funding_type\":\"CREDIT\",\"amount\":\"11400\",\"currency\":\"USD\",\"aggregation_model\":\"H-By Date\",\"bank_transfer\":{\"masked_account_number_last4\":\"XXXXXX9999\",\"bank\":{\"code\":\"XXXXX0001\"}},\"system\":{\"mid\":\"101023947262\",\"hierarchy\":\"055-70-024-011-019\",\"name\":\"XYZ LTD.\",\"dba\":\"XYZ Group\"},\"sales\":{\"count\":4,\"amount\":\"12400\"},\"refunds\":{\"count\":1,\"amount\":\"-1000\"},\"discounts\":{\"count\":0,\"amount\":\"\"},\"tax\":{\"count\":0,\"amount\":\"\"},\"disputes\":{\"chargebacks\":{\"count\":0,\"amount\":\"\"},\"reversals\":{\"count\":0,\"amount\":\"\"}},\"fees\":{\"amount\":\"\"},\"action\":{\"id\":\"ACT_TWdmMMOBZ91iQX1DcvxYermuVJ6E6h\",\"type\":\"DEPOSIT_SINGLE\",\"time_created\":\"2020-11-24T18:43:43.370Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"JF2GQpeCrOivkBGsTRiqkpkdKp67Gxi0\",\"app_name\":\"test_app\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedDepositId = "DEP_2342423423"
        let expectedDepositDate = "2020-11-21".format("yyyy-MM-dd")
        let expectedStatus = "FUNDED"
        let expectedType = "CREDIT"
        let expectedAmount: NSDecimalNumber = 114
        let expectedCurrency = "USD"
        let expectedMerchantNumber = "101023947262"
        let expectedMerchantHierarchy = "055-70-024-011-019"
        let expectedMerchantName = "XYZ LTD."
        let expectedMerchantDbaName = "XYZ Group"
        let expectedSalesTotalCount = 4
        let expectedSalesTotalAmount: NSDecimalNumber = 124
        let expectedRefundsTotalCount = 1
        let expectedRefundsTotalAmount: NSDecimalNumber = -10
        let expectedChargebackTotalCount = 0
        let expectedChargebackTotalAmount: NSDecimalNumber? = nil
        let expectedAdjustmentTotalCount = 0
        let expectedAdjustmentTotalAmount: NSDecimalNumber? = nil
        let expectedFeesTotalAmount: NSDecimalNumber? = nil

        // WHEN
        let depositSummary = GpApiMapping.mapDepositSummary(doc)

        // THEN
        XCTAssertEqual(depositSummary.depositId, expectedDepositId)
        XCTAssertEqual(depositSummary.depositDate, expectedDepositDate)
        XCTAssertEqual(depositSummary.status, expectedStatus)
        XCTAssertEqual(depositSummary.type, expectedType)
        XCTAssertEqual(depositSummary.amount, expectedAmount)
        XCTAssertEqual(depositSummary.currency, expectedCurrency)
        XCTAssertEqual(depositSummary.merchantNumber, expectedMerchantNumber)
        XCTAssertEqual(depositSummary.merchantHierarchy, expectedMerchantHierarchy)
        XCTAssertEqual(depositSummary.merchantName, expectedMerchantName)
        XCTAssertEqual(depositSummary.merchantDbaName, expectedMerchantDbaName)
        XCTAssertEqual(depositSummary.salesTotalCount, expectedSalesTotalCount)
        XCTAssertEqual(depositSummary.salesTotalAmount, expectedSalesTotalAmount)
        XCTAssertEqual(depositSummary.refundsTotalCount, expectedRefundsTotalCount)
        XCTAssertEqual(depositSummary.refundsTotalAmount, expectedRefundsTotalAmount)
        XCTAssertEqual(depositSummary.chargebackTotalCount, expectedChargebackTotalCount)
        XCTAssertEqual(depositSummary.chargebackTotalAmount, expectedChargebackTotalAmount)
        XCTAssertEqual(depositSummary.adjustmentTotalCount, expectedAdjustmentTotalCount)
        XCTAssertEqual(depositSummary.adjustmentTotalAmount, expectedAdjustmentTotalAmount)
        XCTAssertEqual(depositSummary.feesTotalAmount, expectedFeesTotalAmount)
    }

    func test_map_dispute_summary() {
        // GIVEN
        let rawJson = "{\"id\":\"DIS_SAND_abcd1240\",\"time_created\":\"2021-03-13T12:34:40.292Z\",\"status\":\"WITH_MERCHANT\",\"stage\":\"COMPLIANCE\",\"amount\":\"4000\",\"currency\":\"USD\",\"system\":{\"mid\":\"101023947262\",\"hierarchy\":\"111-23-099-001-001\"},\"payment_method\":{\"card\":{\"number\":\"543267xxxxxx7207\",\"arn\":\"210286643954856\",\"brand\":\"MASTERCARD\"}},\"reason_code\":\"4837\",\"reason_description\":\"No Cardholder Authorization\",\"time_to_respond_by\":\"2021-03-30T12:34:40.293Z\",\"result\":\"PENDING\",\"last_adjustment_amount\":\"4000\",\"last_adjustment_currency\":\"USD\",\"last_adjustment_funding\":\"DEBIT\",\"documents\":[{\"id\":\"DOC_MyEvidence_234234AVCDE-1\",\"type\":\"SALES_RECEIPT\"}]}"
        let doc = JsonDoc.parse(rawJson)
        let expectedCaseID = "DIS_SAND_abcd1240"
        let expectedCaseTimeCreated = "2021-03-13T12:34:40.292Z".format()
        let expectedCaseStatus = "WITH_MERCHANT"
        let expectedCaseStage = DisputeStage.compliance
        let expectedCaseAmount: NSDecimalNumber = 40
        let expectedCaseCurrency = "USD"
        let expectedMid = "101023947262"
        let expectedMidHierarchy = "111-23-099-001-001"
        let expectedCardNumber = "543267xxxxxx7207"
        let expectedCardArn = "210286643954856"
        let expectedCardBrand = "MASTERCARD"
        let expectedReasonCode = "4837"
        let expectedReasonDescription = "No Cardholder Authorization"
        let expectedTimeToRespondBy = "2021-03-30T12:34:40.293Z".format()
        let expectedResult = "PENDING"
        let expectedLastAdjustmentAmount: NSDecimalNumber = 40
        let expectedLastAdjustmentCurrency = "USD"
        let expectedLastAdjustmentFunding = "DEBIT"
        let expectedDocuments = [DisputeDocument(id: "DOC_MyEvidence_234234AVCDE-1", type: DocumentType.salesReceipt)]

        // WHEN
        let disputeSummary = GpApiMapping.mapDisputeSummary(doc)

        // THEN
        XCTAssertEqual(disputeSummary.caseId, expectedCaseID)
        XCTAssertEqual(disputeSummary.caseIdTime, expectedCaseTimeCreated)
        XCTAssertEqual(disputeSummary.caseStatus, expectedCaseStatus)
        XCTAssertEqual(disputeSummary.caseStage, expectedCaseStage)
        XCTAssertEqual(disputeSummary.caseAmount, expectedCaseAmount)
        XCTAssertEqual(disputeSummary.caseCurrency, expectedCaseCurrency)
        XCTAssertEqual(disputeSummary.caseMerchantId, expectedMid)
        XCTAssertEqual(disputeSummary.merchantHierarchy, expectedMidHierarchy)
        XCTAssertEqual(disputeSummary.transactionMaskedCardNumber, expectedCardNumber)
        XCTAssertEqual(disputeSummary.transactionARN, expectedCardArn)
        XCTAssertEqual(disputeSummary.transactionCardType, expectedCardBrand)
        XCTAssertEqual(disputeSummary.reasonCode, expectedReasonCode)
        XCTAssertEqual(disputeSummary.reason, expectedReasonDescription)
        XCTAssertEqual(disputeSummary.respondByDate, expectedTimeToRespondBy)
        XCTAssertEqual(disputeSummary.result, expectedResult)
        XCTAssertEqual(disputeSummary.lastAdjustmentAmount, expectedLastAdjustmentAmount)
        XCTAssertEqual(disputeSummary.lastAdjustmentCurrency, expectedLastAdjustmentCurrency)
        XCTAssertEqual(disputeSummary.lastAdjustmentFunding, expectedLastAdjustmentFunding)
        guard let documents = disputeSummary.documents, !documents.isEmpty else {
            XCTFail("documents cannot be nil or empty")
            return
        }
        XCTAssertEqual(documents, expectedDocuments)
    }

    func test_map_settlement_dispute_summary() {
        // GIVEN
        let rawJson = "{\"id\":\"DIS_812\",\"status\":\"FUNDED\",\"stage\":\"CHARGEBACK\",\"stage_time_created\":\"2021-03-18T12:35:28\",\"amount\":\"200\",\"currency\":\"GBP\",\"reason_code\":\"PM\",\"reason_description\":\"Paid by Other Means\",\"time_to_respond_by\":\"2021-04-04T12:35:28\",\"result\":\"LOST\",\"funding_type\":\"DEBIT\",\"deposit_time_created\":\"2021-03-22\",\"deposit_id\":\"DEP_2342423443\",\"last_adjustment_amount\":\"4000\",\"last_adjustment_currency\":\"USD\",\"last_adjustment_funding\":\"DEBIT\",\"last_adjustment_time_created\":\"2020-12-03T09:01:28.143Z\",\"system\":{\"mid\":\"101023947262\",\"hierarchy\":\"055-70-024-011-019\",\"name\":\"XYZ LTD.\"},\"transaction\":{\"time_created\":\"2021-02-23T12:35:28\",\"merchant_time_created\":\"2021-02-23T14:35:28\",\"type\":\"SALE\",\"amount\":\"200\",\"currency\":\"GBP\",\"reference\":\"28012076eb6M\",\"payment_method\":{\"card\":{\"masked_number_first6last4\":\"379132XXXXX1007\",\"arn\":\"71400011203688701393903\",\"brand\":\"AMEX\",\"authcode\":\"129623\",\"brand_reference\":\"MWE1P0JG80110\"}}}}"

        let doc = JsonDoc.parse(rawJson)
        let expectedCaseId = "DIS_812"
        let expectedCaseStatus = "FUNDED"
        let expectedCaseStage = DisputeStage.chargeback
        let expectedCaseIdTime = "2021-03-18T12:35:28".format()
        let expectedCaseAmount: NSDecimalNumber = 2
        let expectedCaseCurrency = "GBP"
        let expectedReasonCode = "PM"
        let expectedReasonDescription = "Paid by Other Means"
        let expectedRespondByDate = "2021-04-04T12:35:28".format()
        let expectedResult = "LOST"
        let expectedFundingType = "DEBIT"
        let expectedDepositTimeCreated = "2021-03-22".format("YYYY-MM-dd")
        let expectedDepositID = "DEP_2342423443"
        let expectedLastAdjustmentAmount: NSDecimalNumber = 40
        let expectedLastAdjustmentCurrency = "USD"
        let expectedLastAdjustmentFunding = "DEBIT"
        let expectedLastAdjustmentTimeCreated = "2020-12-03T09:01:28.143Z".format()
        let expectedCaseMerchantId = "101023947262"
        let expectedMerchantHierarchy = "055-70-024-011-019"
        let expectedMerchantName = "XYZ LTD."
        let expectedTransactionTimeCreated = "2021-02-23T12:35:28".format()
        let expectedTransactionType = "SALE"
        let expectedTransactionAmount: NSDecimalNumber = 2
        let expectedTransactionCurrency = "GBP"
        let expectedTransactionReference = "28012076eb6M"
        let expectedCardMaskedNumberFirst6last4 = "379132XXXXX1007"
        let expectedCardARN = "71400011203688701393903"
        let expectedCardBrand = "AMEX"
        let expectedCardAuthcode = "129623"

        // WHEN
        let disputeSummary = GpApiMapping.mapDisputeSummary(doc)

        // THEN
        XCTAssertEqual(disputeSummary.caseId, expectedCaseId)
        XCTAssertEqual(disputeSummary.caseStatus, expectedCaseStatus)
        XCTAssertEqual(disputeSummary.caseStage, expectedCaseStage)
        XCTAssertEqual(disputeSummary.caseIdTime, expectedCaseIdTime)
        XCTAssertEqual(disputeSummary.caseAmount, expectedCaseAmount)
        XCTAssertEqual(disputeSummary.caseCurrency, expectedCaseCurrency)
        XCTAssertEqual(disputeSummary.reasonCode, expectedReasonCode)
        XCTAssertEqual(disputeSummary.reason, expectedReasonDescription)
        XCTAssertEqual(disputeSummary.respondByDate, expectedRespondByDate)
        XCTAssertEqual(disputeSummary.result, expectedResult)
        XCTAssertEqual(disputeSummary.type, expectedFundingType)
        XCTAssertEqual(disputeSummary.depositDate, expectedDepositTimeCreated)
        XCTAssertEqual(disputeSummary.depositReference, expectedDepositID)
        XCTAssertEqual(disputeSummary.lastAdjustmentAmount, expectedLastAdjustmentAmount)
        XCTAssertEqual(disputeSummary.lastAdjustmentCurrency, expectedLastAdjustmentCurrency)
        XCTAssertEqual(disputeSummary.lastAdjustmentFunding, expectedLastAdjustmentFunding)
        XCTAssertEqual(disputeSummary.lastAdjustmentTimeCreated, expectedLastAdjustmentTimeCreated)
        XCTAssertEqual(disputeSummary.caseMerchantId, expectedCaseMerchantId)
        XCTAssertEqual(disputeSummary.merchantHierarchy, expectedMerchantHierarchy)
        XCTAssertEqual(disputeSummary.merchantName, expectedMerchantName)
        XCTAssertEqual(disputeSummary.caseIdTime, expectedTransactionTimeCreated)
        XCTAssertEqual(disputeSummary.transactionType, expectedTransactionType)
        XCTAssertEqual(disputeSummary.transactionAmount, expectedTransactionAmount)
        XCTAssertEqual(disputeSummary.transactionCurrency, expectedTransactionCurrency)
        XCTAssertEqual(disputeSummary.transactionReferenceNumber, expectedTransactionReference)
        XCTAssertEqual(disputeSummary.transactionMaskedCardNumber, expectedCardMaskedNumberFirst6last4)
        XCTAssertEqual(disputeSummary.transactionARN, expectedCardARN)
        XCTAssertEqual(disputeSummary.transactionCardType, expectedCardBrand)
        XCTAssertEqual(disputeSummary.transactionAuthCode, expectedCardAuthcode)
    }

    func test_map_batch_summary() {
        // GIVEN
        let rawJson = "{\"id\":\"BAT_633828-717\",\"time_last_updated\":\"2021-04-28T07:59:07.525Z\",\"status\":\"CLOSED\",\"amount\":\"199\",\"currency\":\"USD\",\"country\":\"US\",\"transaction_count\":1,\"action\":{\"id\":\"ACT_MBc4l40ZTiEb90sSq55S4GOY7gZj6h\",\"type\":\"CLOSE\",\"time_created\":\"2021-04-28T07:59:07.525Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg\",\"app_name\":\"colleens_app\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedBatchReference = "BAT_633828-717"
        let expectedStatus = "CLOSED"
        let expectedTransactionCount = 1
        let expectedTotalAmount: NSDecimalNumber = 1.99

        // WHEN
        let transaction = GpApiMapping.mapTransaction(doc)

        // THEN
        XCTAssertNotNil(transaction.batchSummary)
        XCTAssertEqual(transaction.batchSummary?.batchReference, expectedBatchReference)
        XCTAssertEqual(transaction.batchSummary?.status, expectedStatus)
        XCTAssertEqual(transaction.batchSummary?.transactionCount, expectedTransactionCount)
        XCTAssertEqual(transaction.batchSummary?.totalAmount, expectedTotalAmount)
    }

    func test_map_action_summary() {
        // GIVEN
        let rawJson = "{\"id\":\"ACT_PJiFWTaNcLW8aVBo2fA8E5Dqd8ZyrH\",\"type\":\"CREATE_TOKEN\",\"time_created\":\"2021-03-24T02:02:27.158Z\",\"resource\":\"ACCESS_TOKENS\",\"resource_request_url\":\"http://localhost:8998/v7/unifiedcommerce/accesstoken\",\"version\":\"2020-12-22\",\"resource_parent_id\":\"\",\"resource_id\":\"ACT_PJiFWTaNcLW8aVBo2fA8E5Dqd8ZyrH\",\"resource_status\":\"PREAUTHORIZED\",\"http_response_code\":\"200\",\"http_response_message\":\"OK\",\"response_code\":\"SUCCESS\",\"response_detailed_code\":\"\",\"response_detailed_message\":\"\",\"app_id\":\"P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg\",\"app_name\":\"colleens_app\",\"app_developer\":\"colleen.mcgloin@globalpay.com\",\"merchant_id\":\"MER_c4c0df11039c48a9b63701adeaa296c3\",\"merchant_name\":\"Sandbox_merchant_2\",\"account_id\":\"TRA_6716058969854a48b33347043ff8225f\",\"account_name\":\"Transaction_Processing\",\"source_location\":\"63.241.252.2\",\"destination_location\":\"74.125.196.153\",\"metrics\":{\"X-GP-Version\":\"2020-12-22\"},\"action\":{\"id\":\"ACT_qOTwHG38UvuWwjcI6DBNu0uqbg8eoR\",\"type\":\"ACTION_SINGLE\",\"time_created\":\"2021-04-23T18:23:05.824Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg\",\"app_name\":\"colleens_app\"}}"
        let doc = JsonDoc.parse(rawJson)

        let expectedId = "ACT_PJiFWTaNcLW8aVBo2fA8E5Dqd8ZyrH"
        let expectedType = "CREATE_TOKEN"
        let expectedTimeCreated = "2021-03-24T02:02:27.158Z".format()
        let expectedResource = "ACCESS_TOKENS"
        let expectedVersion = "2020-12-22"
        let expectedResourceId = "ACT_PJiFWTaNcLW8aVBo2fA8E5Dqd8ZyrH"
        let expectedResourceStatus = "PREAUTHORIZED"
        let expectedHttpResponseCode = "200"
        let expectedResponseCode = "SUCCESS"
        let expectedAppId = "P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg"
        let expectedAppName = "colleens_app"
        let expectedAccountId = "TRA_6716058969854a48b33347043ff8225f"
        let expectedAccountName = "Transaction_Processing"
        let expectedMerchantName = "Sandbox_merchant_2"

        // WHEN
        let actionSummary = GpApiMapping.mapActionSummary(doc)

        // THEN
        XCTAssertEqual(actionSummary.id, expectedId)
        XCTAssertEqual(actionSummary.type, expectedType)
        XCTAssertEqual(actionSummary.timeCreated, expectedTimeCreated)
        XCTAssertEqual(actionSummary.resource, expectedResource)
        XCTAssertEqual(actionSummary.version, expectedVersion)
        XCTAssertEqual(actionSummary.resourceId, expectedResourceId)
        XCTAssertEqual(actionSummary.resourceStatus, expectedResourceStatus)
        XCTAssertEqual(actionSummary.httpResponseCode, expectedHttpResponseCode)
        XCTAssertEqual(actionSummary.responseCode, expectedResponseCode)
        XCTAssertEqual(actionSummary.appId, expectedAppId)
        XCTAssertEqual(actionSummary.appName, expectedAppName)
        XCTAssertEqual(actionSummary.accountId, expectedAccountId)
        XCTAssertEqual(actionSummary.accountName, expectedAccountName)
        XCTAssertEqual(actionSummary.merchantName, expectedMerchantName)
    }

    func test_map_dispute_detail_sandbox_response() {
        // GIVEN
        let rawJson = #"""
        {"id":"DIS_SAND_abcd1236","time_created":"2026-10-18T06:29:39.517Z","merchant_id":"MER_62251730c5574bbcb268191b5f315de8","merchant_name":"TEST MERCHANT","account_id":"DIA_882c832d13e04185bb6e213d6303ed98","account_name":"testdispute","status":"WITH_MERCHANT","status_time_created":"2026-10-20T06:29:39.517Z","stage":"SECOND_CHARGEBACK","stage_time_created":"2026-10-23T06:29:39.517Z","amount":"2000","currency":"USD","payer_amount":"1500","payer_currency":"USD","merchant_amount":"2500","merchant_currency":"USD","reason_code":"137","reason_description":"Cancelled Merchandise/Services","order":{"reference":"889654","invoice_number":"325rqadf"},"time_to_respond_by":"2026-11-04T06:29:39.517Z","result":"PENDING","investigator_comment":"WITH_MERCHANT SECOND_CHARGEBACK PENDING 2000 USD 2000 USD","region_code":"AP","system":{"mid":"627384967","hierarchy":"111-23-099-001-001","name":"ABC INC."},"last_adjustment_amount":"2000","last_adjustment_currency":"USD","last_adjustment_funding":"DEBIT","last_adjustment_time_created":"2026-10-26T06:29:39.517Z","net_financial_amount":"2000","net_financial_currency":"USD","net_financial_funding":"DEBIT","foreign_issued_card":"YES","disposition_description":"Response sent to Issuer","disposition_date":"2025-01-08 05:21:40","case_time_created":"2025-01-08 05:21:40","store_reference":"MOTO - 91889","payment_method_provider":[{"comment":"issuer comments 34525","reference":"issuer-reference-0003","documents":[{"id":"DOC_MyEvidence_234234AVCDE-2","type":"ACQUIRER_DOC_FOR_SCHEMES"}]}],"transaction":{"time_created":"2026-09-10T06:29:39.517Z","type":"SALE","amount":"2000","currency":"USD","reference":"my-trans-AAA3","remarks":"my-trans-AAA3","terminal_capability_code":"E00809","merchant_category_code":"6300","provider":{"avs_result":"Z","payment_method":{"entry_mode_code":"90","card":{"number":"424242xxxxxx4242","arn":"549365667487346","brand":"VISA","authcode":"0234AB","brand_reference":"23423421342323A","issuer_bin":"401738","acquirer_bin":"401739"}},"device":{"terminal_capacity_code":"2"}}},"documents":[{"id":"DOC_MyEvidence_234234AVCDE-2","type":"ACQUIRER_DOC_FOR_SCHEMES"}],"action":{"id":"ACT_71d0IODihGKWZxcDhfIaVofFHTt4Qh","type":"DISPUTE_SINGLE","time_created":"2026-10-30T06:29:39.537Z","result_code":"SUCCESS","app_id":"X2QS2alAbhURA3NLwr73pNicdoPijJEp","app_name":"SDK_DEV_TEST"}}
        """#

        // WHEN
        let summary = GpApiMapping.mapDisputeSummary(JsonDoc.parse(rawJson))

        // THEN
        XCTAssertEqual(summary.caseId, "DIS_SAND_abcd1236")
        XCTAssertEqual(summary.caseIdTime, "2026-10-18T06:29:39.517Z".format())
        XCTAssertEqual(summary.merchantId, "MER_62251730c5574bbcb268191b5f315de8")
        XCTAssertEqual(summary.merchantLabel, "TEST MERCHANT")
        XCTAssertEqual(summary.accountId, "DIA_882c832d13e04185bb6e213d6303ed98")
        XCTAssertEqual(summary.accountName, "testdispute")
        XCTAssertEqual(summary.caseStatus, "WITH_MERCHANT")
        XCTAssertEqual(summary.caseStatusTime, "2026-10-20T06:29:39.517Z".format())
        XCTAssertEqual(summary.caseStage, .secondChargeback)
        XCTAssertEqual(summary.caseStageTime, "2026-10-23T06:29:39.517Z".format())
        XCTAssertEqual(summary.caseAmount, 20)
        XCTAssertEqual(summary.caseCurrency, "USD")
        XCTAssertEqual(summary.disputeCustomerAmount, 15)
        XCTAssertEqual(summary.disputeCustomerCurrency, "USD")
        XCTAssertEqual(summary.disputeAmount, 25)
        XCTAssertEqual(summary.disputeCurrency, "USD")
        XCTAssertEqual(summary.reasonCode, "137")
        XCTAssertEqual(summary.reason, "Cancelled Merchandise/Services")
        XCTAssertEqual(summary.transactionOrderId, "889654")
        XCTAssertEqual(summary.orderInvoiceNumber, "325rqadf")
        XCTAssertEqual(summary.respondByDate, "2026-11-04T06:29:39.517Z".format())
        XCTAssertEqual(summary.result, "PENDING")
        XCTAssertEqual(summary.investigatorComment, "WITH_MERCHANT SECOND_CHARGEBACK PENDING 2000 USD 2000 USD")
        XCTAssertEqual(summary.regionCode, "AP")
        XCTAssertEqual(summary.caseMerchantId, "627384967")
        XCTAssertEqual(summary.merchantHierarchy, "111-23-099-001-001")
        XCTAssertEqual(summary.merchantName, "ABC INC.")
        XCTAssertEqual(summary.lastAdjustmentAmount, 20)
        XCTAssertEqual(summary.lastAdjustmentCurrency, "USD")
        XCTAssertEqual(summary.lastAdjustmentFunding, "DEBIT")
        XCTAssertEqual(summary.lastAdjustmentTimeCreated, "2026-10-26T06:29:39.517Z".format())
        XCTAssertEqual(summary.netFinancialAmount, 20)
        XCTAssertEqual(summary.netFinancialCurrency, "USD")
        XCTAssertEqual(summary.netFinancialFunding, "DEBIT")
        XCTAssertEqual(summary.foreignIssuedCard, "YES")
        XCTAssertEqual(summary.dispositionDescription, "Response sent to Issuer")
        XCTAssertNotNil(summary.dispositionDate)
        XCTAssertEqual(summary.dispositionDate, "2025-01-08 05:21:40".format("yyyy-MM-dd HH:mm:ss"))
        XCTAssertNotNil(summary.caseTime)
        XCTAssertEqual(summary.caseTime, "2025-01-08 05:21:40".format("yyyy-MM-dd HH:mm:ss"))
        XCTAssertEqual(summary.storeReference, "MOTO - 91889")

        XCTAssertEqual(summary.paymentMethodProviders?.count, 1)
        XCTAssertEqual(summary.paymentMethodProviders?.first?.comment, "issuer comments 34525")
        XCTAssertEqual(summary.paymentMethodProviders?.first?.reference, "issuer-reference-0003")
        XCTAssertEqual(summary.paymentMethodProviders?.first?.documents?.first?.id, "DOC_MyEvidence_234234AVCDE-2")
        XCTAssertEqual(summary.paymentMethodProviders?.first?.documents?.first?.rawType, "ACQUIRER_DOC_FOR_SCHEMES")
        XCTAssertEqual(summary.issuerComment, "issuer comments 34525")
        XCTAssertEqual(summary.issuerCaseNumber, "issuer-reference-0003")

        XCTAssertEqual(summary.transactionTime, "2026-09-10T06:29:39.517Z".format())
        XCTAssertEqual(summary.transactionType, "SALE")
        XCTAssertEqual(summary.transactionAmount, 20)
        XCTAssertEqual(summary.transactionCurrency, "USD")
        XCTAssertEqual(summary.transactionReferenceNumber, "my-trans-AAA3")
        XCTAssertEqual(summary.transactionRemarks, "my-trans-AAA3")
        XCTAssertEqual(summary.terminalCapabilityCode, "E00809")
        XCTAssertEqual(summary.merchantCategory, "6300")
        XCTAssertEqual(summary.avsResult, "Z")
        XCTAssertEqual(summary.entryModeCode, "90")
        XCTAssertEqual(summary.transactionMaskedCardNumber, "424242xxxxxx4242")
        XCTAssertEqual(summary.transactionARN, "549365667487346")
        XCTAssertEqual(summary.transactionCardType, "VISA")
        XCTAssertEqual(summary.transactionAuthCode, "0234AB")
        XCTAssertEqual(summary.cardBrandReference, "23423421342323A")
        XCTAssertEqual(summary.cardIssuerBin, "401738")
        XCTAssertEqual(summary.cardAcquirerBin, "401739")
        XCTAssertEqual(summary.terminalCapacityCode, "2")

        XCTAssertEqual(summary.documents?.count, 1)
        XCTAssertEqual(summary.documents?.first?.id, "DOC_MyEvidence_234234AVCDE-2")
        XCTAssertEqual(summary.documents?.first?.rawType, "ACQUIRER_DOC_FOR_SCHEMES")
        XCTAssertNil(summary.documents?.first?.type)

        XCTAssertEqual(summary.action?.id, "ACT_71d0IODihGKWZxcDhfIaVofFHTt4Qh")
        XCTAssertEqual(summary.action?.type, "DISPUTE_SINGLE")
        XCTAssertEqual(summary.action?.timeCreated, "2026-10-30T06:29:39.537Z".format())
        XCTAssertEqual(summary.action?.resultCode, "SUCCESS")
        XCTAssertEqual(summary.action?.appId, "X2QS2alAbhURA3NLwr73pNicdoPijJEp")
        XCTAssertEqual(summary.action?.appName, "SDK_DEV_TEST")
    }

    func test_map_dispute_detail_documented_response() {
        // GIVEN: order, payment_method and device nested as documented, document content and the documented key typos
        let rawJson = #"""
        {"id":"DIS_SAND_abcd1236","stage":"GOOD_FAITH","amount":"1999","currency":"USD","system":{"mid":"MID1","tid":"TID1","hierarchy":"h","name":"MERCHANT ABC INC","dba":"MERCHANT XYZ INC"," global_transaction_reference":"rrt-6037ed91","global_transaction_source":"gp-apigee"},"acquirer_code":"ACQ1","transaction":{"amount":"11099","currency":"USD","reference":"becf9f3e","payment_method":{"entry_mode_code":"81","card":{"number":"411111xxxxxx1111","brand":"VISA"}},"order":{"reference":"b636294sd5b6826hjdnde92","invoice_number":"1234"}},"documents":[{"id":"DOC_1","b64_conent":"R0lGODlhigPCAXAAACwAAAAAigPCAYf","type":"SALES_RECEIPT"}],"device":{"terminal_capacity_code":"1"}}
        """#

        // WHEN
        let summary = GpApiMapping.mapDisputeSummary(JsonDoc.parse(rawJson))

        // THEN
        XCTAssertEqual(summary.caseStage, .goodFaith)
        XCTAssertEqual(summary.caseAmount, NSDecimalNumber(string: "19.99"))
        XCTAssertEqual(summary.transactionAmount, NSDecimalNumber(string: "110.99"))
        XCTAssertEqual(summary.caseTerminalId, "TID1")
        XCTAssertEqual(summary.merchantDbaName, "MERCHANT XYZ INC")
        XCTAssertEqual(summary.globalTransactionReference, "rrt-6037ed91")
        XCTAssertEqual(summary.globalTransactionSource, "gp-apigee")
        XCTAssertEqual(summary.acquirerCode, "ACQ1")
        XCTAssertEqual(summary.transactionOrderId, "b636294sd5b6826hjdnde92")
        XCTAssertEqual(summary.orderInvoiceNumber, "1234")
        XCTAssertEqual(summary.entryModeCode, "81")
        XCTAssertEqual(summary.transactionMaskedCardNumber, "411111xxxxxx1111")
        XCTAssertEqual(summary.terminalCapacityCode, "1")
        XCTAssertEqual(summary.documents?.first?.type, .salesReceipt)
        XCTAssertEqual(summary.documents?.first?.rawType, "SALES_RECEIPT")
        XCTAssertNotNil(summary.documents?.first?.base64Content)
    }

    func test_map_disputes_list_sandbox_response() {
        // GIVEN
        let rawJson = #"""
        {"total_record_count":22,"current_page_size":5,"merchant_id":"MER_62251730c5574bbcb268191b5f315de8","merchant_name":"TEST MERCHANT","account_id":"DIA_882c832d13e04185bb6e213d6303ed98","account_name":"testdispute","filter":{"from_stage_time_created":"2026-09-30","to_stage_time_created":"2026-10-30"},"paging":{"page_size":5,"page":1,"order":"ASC","order_by":"FROM_STAGE_TIME_CREATED"},"disputes":[{"id":"DIS_SAND_abcd1234","acquirer_code":"GPN","status":"WITH_MERCHANT","stage":"RETRIEVAL","stage_time_created":"2026-10-23T10:24:41.040Z","amount":"1000","currency":"USD","system":{"mid":"627384967","hierarchy":"111-23-099-001-001"},"payment_method":{"card":{"number":"424242xxxxxx4242","arn":"834523482349123","brand":"VISA"}},"reason_code":"104","reason_description":"Other Fraud-Card Absent Environment","order":{"reference":"889654"},"time_to_respond_by":"2026-11-04T10:24:41.040Z","result":"PENDING","last_adjustment_amount":"","last_adjustment_currency":"","last_adjustment_funding":""},{"id":"DIS_SAND_abcd1235","acquirer_code":"HPY","status":"WITH_MERCHANT","stage":"CHARGEBACK","stage_time_created":"2026-10-23T10:24:41.040Z","amount":"1500","currency":"USD","system":{"mid":"627384967","hierarchy":"111-23-099-001-001"},"payment_method":{"card":{"number":"543267xxxxxx7207","arn":"123934529762282","brand":"MASTERCARD"}},"reason_code":"132","reason_description":"Cancelled Recurring","order":{"reference":"889655"},"time_to_respond_by":"2026-11-04T10:24:41.040Z","result":"PENDING","last_adjustment_amount":"1500","last_adjustment_currency":"USD","last_adjustment_funding":"DEBIT"}],"action":{"id":"ACT_QVBj7Ylpp831r7ocGXbRBy6ekGNJrE","type":"DISPUTE_LIST","time_created":"2026-10-30T10:24:41.062Z","result_code":"SUCCESS","app_id":"X2QS2alAbhURA3NLwr73pNicdoPijJEp","app_name":"SDK_DEV_TEST"}}
        """#

        // WHEN
        let result: PagedResult<DisputeSummary>? = GpApiMapping.mapReportResponse(rawJson, .findDisputesPaged)

        // THEN
        guard let result = result else {
            XCTFail("result cannot be nil")
            return
        }
        XCTAssertEqual(result.totalRecordCount, 22)
        XCTAssertEqual(result.currentPageSize, 5)
        XCTAssertEqual(result.merchantId, "MER_62251730c5574bbcb268191b5f315de8")
        XCTAssertEqual(result.merchantName, "TEST MERCHANT")
        XCTAssertEqual(result.accountId, "DIA_882c832d13e04185bb6e213d6303ed98")
        XCTAssertEqual(result.accountName, "testdispute")
        XCTAssertEqual(result.filterFromStageTimeCreated, "2026-09-30")
        XCTAssertEqual(result.filterToStageTimeCreated, "2026-10-30")
        XCTAssertEqual(result.pageSize, 5)
        XCTAssertEqual(result.page, 1)
        XCTAssertEqual(result.order, "ASC")
        XCTAssertEqual(result.orderBy, "FROM_STAGE_TIME_CREATED")
        XCTAssertEqual(result.action?.id, "ACT_QVBj7Ylpp831r7ocGXbRBy6ekGNJrE")
        XCTAssertEqual(result.action?.type, "DISPUTE_LIST")
        XCTAssertEqual(result.action?.timeCreated, "2026-10-30T10:24:41.062Z".format())
        XCTAssertEqual(result.action?.resultCode, "SUCCESS")
        XCTAssertEqual(result.action?.appId, "X2QS2alAbhURA3NLwr73pNicdoPijJEp")
        XCTAssertEqual(result.action?.appName, "SDK_DEV_TEST")

        XCTAssertEqual(result.results.count, 2)
        let first = result.results[0]
        XCTAssertEqual(first.caseId, "DIS_SAND_abcd1234")
        XCTAssertEqual(first.acquirerCode, "GPN")
        XCTAssertEqual(first.caseStatus, "WITH_MERCHANT")
        XCTAssertEqual(first.caseStage, .retrieval)
        XCTAssertEqual(first.caseStageTime, "2026-10-23T10:24:41.040Z".format())
        XCTAssertEqual(first.caseAmount, 10)
        XCTAssertEqual(first.caseCurrency, "USD")
        XCTAssertEqual(first.caseMerchantId, "627384967")
        XCTAssertEqual(first.merchantHierarchy, "111-23-099-001-001")
        XCTAssertEqual(first.transactionMaskedCardNumber, "424242xxxxxx4242")
        XCTAssertEqual(first.transactionARN, "834523482349123")
        XCTAssertEqual(first.transactionCardType, "VISA")
        XCTAssertEqual(first.reasonCode, "104")
        XCTAssertEqual(first.reason, "Other Fraud-Card Absent Environment")
        XCTAssertEqual(first.transactionOrderId, "889654")
        XCTAssertEqual(first.respondByDate, "2026-11-04T10:24:41.040Z".format())
        XCTAssertEqual(first.result, "PENDING")
        XCTAssertNil(first.lastAdjustmentAmount)

        let second = result.results[1]
        XCTAssertEqual(second.caseId, "DIS_SAND_abcd1235")
        XCTAssertEqual(second.acquirerCode, "HPY")
        XCTAssertEqual(second.caseStage, .chargeback)
        XCTAssertEqual(second.transactionCardType, "MASTERCARD")
        XCTAssertEqual(second.transactionOrderId, "889655")
        XCTAssertEqual(second.lastAdjustmentAmount, 15)
        XCTAssertEqual(second.lastAdjustmentCurrency, "USD")
        XCTAssertEqual(second.lastAdjustmentFunding, "DEBIT")
    }

    func test_map_disputes_list_documented_response() {
        // GIVEN: filter echoed back, transaction.order and top level payment_method as documented
        let rawJson = #"""
        {"total_record_count":1000,"current_page_size":564,"filter":{"page":1,"page_size":5,"order":"ASC","order_by":"TIME_CREATED","arn":"ARN1","brand":"VISA","status":"UNDER_REVIEW","stage":"RETRIEVAL","from_stage_time_created":"2021-01-01","to_stage_time_created":"2021-02-01","system.mid":"MID1","system.hierarchy":"HIER1"},"paging":{"page":1,"page_size":5,"order_by":"TIME_CREATED","order":"ASC"},"disputes":[{"id":"DIS_SAND_abcd1236","status":"UNDER_REVIEW","stage":"RETRIEVAL","amount":"11099","currency":"USD","acquirer_code":"GPN","system":{"mid":"MID1","tid":"TID1","hierarchy":"HIER1","name":"MERCHANT ABC INC","dba":"MERCHANT XYZ INC"},"transaction":{"order":{"reference":"b636294sd5b6826hjdnde92"}},"payment_method":{"card":{"number":"411111xxxxxx1111","arn":"ARN1","brand":"VISA"}}}]}
        """#

        // WHEN
        let result: PagedResult<DisputeSummary>? = GpApiMapping.mapReportResponse(rawJson, .findDisputesPaged)

        // THEN
        XCTAssertEqual(result?.totalRecordCount, 1000)
        XCTAssertEqual(result?.currentPageSize, 564)
        XCTAssertEqual(result?.filterPage, 1)
        XCTAssertEqual(result?.filterPageSize, 5)
        XCTAssertEqual(result?.filterOrder, "ASC")
        XCTAssertEqual(result?.filterOrderBy, "TIME_CREATED")
        XCTAssertEqual(result?.filterArn, "ARN1")
        XCTAssertEqual(result?.filterBrand, "VISA")
        XCTAssertEqual(result?.filterStatus, "UNDER_REVIEW")
        XCTAssertEqual(result?.filterStage, "RETRIEVAL")
        XCTAssertEqual(result?.filterFromStageTimeCreated, "2021-01-01")
        XCTAssertEqual(result?.filterToStageTimeCreated, "2021-02-01")
        XCTAssertEqual(result?.filterSystemMid, "MID1")
        XCTAssertEqual(result?.filterSystemHierarchy, "HIER1")
        XCTAssertNil(result?.action)

        let dispute = result?.results.first
        XCTAssertEqual(result?.results.count, 1)
        XCTAssertEqual(dispute?.caseAmount, NSDecimalNumber(string: "110.99"))
        XCTAssertEqual(dispute?.caseTerminalId, "TID1")
        XCTAssertEqual(dispute?.merchantName, "MERCHANT ABC INC")
        XCTAssertEqual(dispute?.merchantDbaName, "MERCHANT XYZ INC")
        XCTAssertEqual(dispute?.transactionOrderId, "b636294sd5b6826hjdnde92")
        XCTAssertEqual(dispute?.transactionMaskedCardNumber, "411111xxxxxx1111")
        XCTAssertEqual(dispute?.acquirerCode, "GPN")
    }

    func test_map_dispute_action() {
        // GIVEN
        let rawJson = "{\"id\":\"DIS_SAND_abcd1234\",\"status\":\"CLOSED\",\"stage\":\"RETRIEVAL\",\"amount\":\"1000\",\"currency\":\"USD\",\"reason_code\":\"104\",\"reason_description\":\"Other Fraud-Card Absent Environment\",\"result\":\"FULFILLED\",\"documents\":[{\"id\":\"DOC_MyEvidence_234234AVCDE-0\"}],\"action\":{\"id\":\"ACT_5blBTHnIs4aOCIvGwG7KizYUpsGI0g\",\"type\":\"CHALLENGE\",\"time_created\":\"2020-12-07T10:26:20.124Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"i9R0byBBor6RqTQNj3g4MuVBwH5rd7yR\",\"app_name\":\"demo_app\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedReference = "DIS_SAND_abcd1234"
        let expectedStatus = DisputeStatus.closed
        let expectedStage = DisputeStage.retrieval
        let expectedAmount: NSDecimalNumber = 10
        let expectedCurrency = "USD"
        let expectedReasonCode = "104"
        let expectedReasonDescription = "Other Fraud-Card Absent Environment"
        let expectedResult = DisputeResult.fulfilled
        let expectedDocuments = ["DOC_MyEvidence_234234AVCDE-0"]

        // WHEN
        let disputeAction = GpApiMapping.mapDisputeAction(doc)

        // THEN
        XCTAssertEqual(disputeAction.reference, expectedReference)
        XCTAssertEqual(disputeAction.status, expectedStatus)
        XCTAssertEqual(disputeAction.stage, expectedStage)
        XCTAssertEqual(disputeAction.amount, expectedAmount)
        XCTAssertEqual(disputeAction.currency, expectedCurrency)
        XCTAssertEqual(disputeAction.reasonCode, expectedReasonCode)
        XCTAssertEqual(disputeAction.reasonDescription, expectedReasonDescription)
        XCTAssertEqual(disputeAction.result, expectedResult)
        XCTAssertEqual(disputeAction.documents, expectedDocuments)
        XCTAssertEqual(disputeAction.action?.id, "ACT_5blBTHnIs4aOCIvGwG7KizYUpsGI0g")
        XCTAssertEqual(disputeAction.action?.type, "CHALLENGE")
        XCTAssertNotNil(disputeAction.action?.timeCreated)
        XCTAssertEqual(disputeAction.action?.resultCode, "SUCCESS")
        XCTAssertEqual(disputeAction.action?.appId, "i9R0byBBor6RqTQNj3g4MuVBwH5rd7yR")
        XCTAssertEqual(disputeAction.action?.appName, "demo_app")
    }

    func test_map_accept_dispute_response() {
        // GIVEN
        let rawJson = "{\"id\":\"DIS_SAND_abcd1236\",\"status\":\"CLOSED\",\"stage\":\"SECOND_CHARGEBACK\",\"amount\":\"2000\",\"currency\":\"USD\",\"reason_code\":\"137\",\"reason_description\":\"Cancelled Merchandise/Services\",\"result\":\"ACCEPTED\",\"action\":{\"id\":\"ACT_QSq6x17pZWO6ssVSmVsf1Hs106jJAv\",\"type\":\"ACCEPT\",\"time_created\":\"2026-10-29T08:02:15.853Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"X2QS2alAbhURA3NLwr73pNicdoPijJEp\",\"app_name\":\"SDK_DEV_TEST\"}}"
        let doc = JsonDoc.parse(rawJson)

        // WHEN
        let disputeAction = GpApiMapping.mapDisputeAction(doc)

        // THEN
        XCTAssertEqual(disputeAction.reference, "DIS_SAND_abcd1236")
        XCTAssertEqual(disputeAction.status, .closed)
        XCTAssertEqual(disputeAction.stage, .secondChargeback)
        XCTAssertEqual(disputeAction.amount, 20)
        XCTAssertEqual(disputeAction.currency, "USD")
        XCTAssertEqual(disputeAction.reasonCode, "137")
        XCTAssertEqual(disputeAction.reasonDescription, "Cancelled Merchandise/Services")
        XCTAssertEqual(disputeAction.result, .accepted)
        XCTAssertNil(disputeAction.documents)
        XCTAssertEqual(disputeAction.action?.id, "ACT_QSq6x17pZWO6ssVSmVsf1Hs106jJAv")
        XCTAssertEqual(disputeAction.action?.type, "ACCEPT")
        XCTAssertNotNil(disputeAction.action?.timeCreated)
        XCTAssertEqual(disputeAction.action?.resultCode, "SUCCESS")
        XCTAssertEqual(disputeAction.action?.appId, "X2QS2alAbhURA3NLwr73pNicdoPijJEp")
        XCTAssertEqual(disputeAction.action?.appName, "SDK_DEV_TEST")
    }

    func test_map_challenge_dispute_response_documents_content() {
        // GIVEN
        let rawJson = "{\"id\":\"DIS_SAND_abcd1236\",\"status\":\"UNDER_REVIEW\",\"stage\":\"RETRIEVAL\",\"amount\":\"11099\",\"currency\":\"USD\",\"result\":\"PENDING\",\"documents\":[{\"id\":\"DOC_lskdnfosdfjsdfsdf23dasd\",\"b64_content\":\"R0lGODlhAQ\"},{\"id\":\"DOC_second\",\"b64_content\":\"R0lGODlh\"},{\"id\":\"DOC_no_content\"}],\"action\":{\"id\":\"ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d\",\"type\":\"DISPUTE_SINGLE\",\"time_created\":\"2021-05-03T21:23:39.718Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"uzFr7t4VOqxdLDI44hHmXIjHtOOE8d\",\"app_name\":\"my_lovely_app\"}}"
        let doc = JsonDoc.parse(rawJson)

        // WHEN
        let disputeAction = GpApiMapping.mapDisputeAction(doc)

        // THEN
        XCTAssertEqual(disputeAction.reference, "DIS_SAND_abcd1236")
        XCTAssertEqual(disputeAction.status, .underReview)
        XCTAssertEqual(disputeAction.stage, .retrieval)
        XCTAssertEqual(disputeAction.amount, NSDecimalNumber(string: "110.99"))
        XCTAssertEqual(disputeAction.currency, "USD")
        XCTAssertEqual(disputeAction.result, .pending)
        XCTAssertEqual(disputeAction.documents, ["DOC_lskdnfosdfjsdfsdf23dasd", "DOC_second", "DOC_no_content"])
        XCTAssertEqual(disputeAction.disputeDocuments?.count, 3)
        XCTAssertEqual(disputeAction.disputeDocuments?[0].id, "DOC_lskdnfosdfjsdfsdf23dasd")
        XCTAssertEqual(disputeAction.disputeDocuments?[0].base64Content, Data(base64Encoded: "R0lGODlhAQ=="))
        XCTAssertEqual(disputeAction.disputeDocuments?[1].base64Content, Data(base64Encoded: "R0lGODlh"))
        XCTAssertEqual(disputeAction.disputeDocuments?[2].id, "DOC_no_content")
        XCTAssertNil(disputeAction.disputeDocuments?[2].base64Content)
        XCTAssertEqual(disputeAction.action?.id, "ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(disputeAction.action?.type, "DISPUTE_SINGLE")
        XCTAssertNotNil(disputeAction.action?.timeCreated)
        XCTAssertEqual(disputeAction.action?.resultCode, "SUCCESS")
        XCTAssertEqual(disputeAction.action?.appId, "uzFr7t4VOqxdLDI44hHmXIjHtOOE8d")
        XCTAssertEqual(disputeAction.action?.appName, "my_lovely_app")
    }

    func test_map_accept_dispute_response_good_faith_stage() {
        // GIVEN
        let rawJson = "{\"id\":\"DIS_SAND_abcd1241\",\"status\":\"UNDER_REVIEW\",\"stage\":\"GOOD_FAITH\",\"amount\":\"4500\",\"currency\":\"USD\",\"reason_code\":\"4863\",\"reason_description\":\"Cardholder Does Not Recognize-Potential Fraud\",\"result\":\"PENDING\",\"action\":{\"id\":\"ACT_JJ1xKqAWqPku6e0xNlIpcoIZmiTAMo\",\"type\":\"ACCEPT\",\"time_created\":\"2026-10-29T10:50:10.463Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc\",\"app_name\":\"gpapisdktesting\"}}"
        let doc = JsonDoc.parse(rawJson)

        // WHEN
        let disputeAction = GpApiMapping.mapDisputeAction(doc)

        // THEN
        XCTAssertEqual(disputeAction.reference, "DIS_SAND_abcd1241")
        XCTAssertEqual(disputeAction.status, .underReview)
        XCTAssertEqual(disputeAction.stage, .goodFaith)
        XCTAssertEqual(disputeAction.amount, 45)
        XCTAssertEqual(disputeAction.result, .pending)
        XCTAssertEqual(disputeAction.action?.type, "ACCEPT")
    }

    func test_map_accept_dispute_response_mastercard_pre_dispute_stage() {
        // GIVEN
        let rawJson = "{\"id\":\"DIS_SAND_abcd1236\",\"status\":\"UNDER_REVIEW\",\"stage\":\"MASTERCARD PRE-DISPUTE\",\"amount\":\"2000\",\"currency\":\"USD\",\"result\":\"PENDING\"}"
        let doc = JsonDoc.parse(rawJson)

        // WHEN
        let disputeAction = GpApiMapping.mapDisputeAction(doc)

        // THEN
        XCTAssertEqual(disputeAction.stage, .mastercardPreDispute)
        XCTAssertEqual(disputeAction.result, .pending)
        XCTAssertNil(disputeAction.action)
    }

    func test_map_document_metadata() {
        // GIVEN
        let rawJson = "{\"id\":\"DOC_MyEvidence_234234AVCDE-1\",\"b64_content\":\"VGVzdA==\",\"action\":{\"id\":\"ACT_5blBTHnIs4aOCIvGwG7KizYUpsGI0g\",\"type\":\"DOCUMENT_SINGLE\",\"time_created\":\"2020-12-07T10:32:12.037Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"GkwdYGzQrEy1SdTz7S10P8uRjFMlEsJg\",\"app_name\":\"sample_app_CERT\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedId = "DOC_MyEvidence_234234AVCDE-1"
        let expectedB64Content = "Test".data(using: .utf8)

        // WHEN
        let disputeDocumentMetadata = GpApiMapping.mapDocumentMetadata(doc)

        // THEN
        guard let metadata = disputeDocumentMetadata else {
            XCTFail("disputeDocumentMetadata cannot be nil")
            return
        }
        XCTAssertEqual(metadata.id, expectedId)
        XCTAssertEqual(metadata.b64Content, expectedB64Content)
        XCTAssertEqual(metadata.action?.id, "ACT_5blBTHnIs4aOCIvGwG7KizYUpsGI0g")
        XCTAssertEqual(metadata.action?.type, "DOCUMENT_SINGLE")
        XCTAssertNotNil(metadata.action?.timeCreated)
        XCTAssertEqual(metadata.action?.resultCode, "SUCCESS")
        XCTAssertEqual(metadata.action?.appId, "GkwdYGzQrEy1SdTz7S10P8uRjFMlEsJg")
        XCTAssertEqual(metadata.action?.appName, "sample_app_CERT")
    }

    func test_map_document_metadata_documented_response_without_padding() {
        // GIVEN
        let rawJson = "{\"id\":\"DOC_lskdnfosdfjsdfsdf23dasd\",\"b64_content\":\"R0lGODlhAQ\"}"
        let doc = JsonDoc.parse(rawJson)

        // WHEN
        let metadata = GpApiMapping.mapDocumentMetadata(doc)

        // THEN
        XCTAssertEqual(metadata?.id, "DOC_lskdnfosdfjsdfsdf23dasd")
        XCTAssertEqual(metadata?.b64Content, Data(base64Encoded: "R0lGODlhAQ=="))
        XCTAssertNil(metadata?.action)
    }

    func test_map_document_metadata_sandbox_response() {
        // GIVEN
        let rawJson = "{\"id\":\"DOC_MyEvidence_234234AVCDE-1\",\"b64_content\":\"JVBERi0xLjcK\",\"action\":{\"id\":\"ACT_JQMEVTW9urBMyD8uK2cV5XI0HO93VL\",\"type\":\"DOCUMENT_SINGLE\",\"time_created\":\"2026-10-30T12:40:21.469Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc\",\"app_name\":\"gpapisdktesting\"}}"
        let doc = JsonDoc.parse(rawJson)

        // WHEN
        let metadata = GpApiMapping.mapDocumentMetadata(doc)

        // THEN
        XCTAssertEqual(metadata?.id, "DOC_MyEvidence_234234AVCDE-1")
        XCTAssertEqual(metadata?.b64Content, "%PDF-1.7\n".data(using: .utf8))
        XCTAssertEqual(metadata?.action?.id, "ACT_JQMEVTW9urBMyD8uK2cV5XI0HO93VL")
        XCTAssertEqual(metadata?.action?.type, "DOCUMENT_SINGLE")
        XCTAssertEqual(metadata?.action?.resultCode, "SUCCESS")
        XCTAssertEqual(metadata?.action?.appId, "x0lQh0iLV0fOkmeAyIDyBqrP9U5QaiKc")
        XCTAssertEqual(metadata?.action?.appName, "gpapisdktesting")
    }

    func test_map_document_metadata_without_content_returns_nil() {
        // GIVEN
        let doc = JsonDoc.parse("{\"id\":\"DOC_no_content\"}")

        // THEN
        XCTAssertNil(GpApiMapping.mapDocumentMetadata(doc))
    }

    func test_map_stored_payment_summary() {
        // GIVEN
        let rawJson = "{\"id\":\"PMT_476ef932-7412-42ce-b2bd-082c01a77f70\",\"time_created\":\"2021-04-21T11:56:07.000Z\",\"status\":\"ACTIVE\",\"merchant_id\":\"MER_c4c0df11039c48a9b63701adeaa296c3\",\"merchant_name\":\"Sandbox_merchant_2\",\"account_id\":\"TKA_eba30a1b5c4a468d90ceeef2ffff7f5e\",\"account_name\":\"Tokenization\",\"reference\":\"86D32E17-A5BB-4CDC-8B81-21E2B7C67F10\",\"name\":\"James Mason\",\"card\":{\"number_last4\":\"xxxxxxxxxxxx1111\",\"brand\":\"VISA\",\"expiry_month\":\"12\",\"expiry_year\":\"25\"},\"action\":{\"id\":\"ACT_f7SPGvaFnosJCZCHAUCNddgyUBoBWt\",\"type\":\"PAYMENT_METHOD_SINGLE\",\"time_created\":\"2021-04-21T11:56:07.917Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"P3LRVjtGRGxWQQJDE345mSkEh2KfdAyg\",\"app_name\":\"colleens_app\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedId: String? = "PMT_476ef932-7412-42ce-b2bd-082c01a77f70"
        let expectedTimeCreated: Date? = "2021-04-21T11:56:07.000Z".format()
        let expectedStatus: String? = "ACTIVE"
        let expectedReference: String? = "86D32E17-A5BB-4CDC-8B81-21E2B7C67F10"
        let expectedName: String? = "James Mason"
        let expectedCardLast4: String? = "xxxxxxxxxxxx1111"
        let expectedCardType: String? = "VISA"
        let expectedCardExpMonth: String? = "12"
        let expectedCardExpYear: String? = "25"

        // WHEN
        let storedPaymentMethodSummary = GpApiMapping.mapStoredPaymentMethodSummary(doc)

        // THEN
        XCTAssertEqual(storedPaymentMethodSummary.id, expectedId)
        XCTAssertEqual(storedPaymentMethodSummary.timeCreated, expectedTimeCreated)
        XCTAssertEqual(storedPaymentMethodSummary.status, expectedStatus)
        XCTAssertEqual(storedPaymentMethodSummary.reference, expectedReference)
        XCTAssertEqual(storedPaymentMethodSummary.name, expectedName)
        XCTAssertEqual(storedPaymentMethodSummary.cardLast4, expectedCardLast4)
        XCTAssertEqual(storedPaymentMethodSummary.cardType, expectedCardType)
        XCTAssertEqual(storedPaymentMethodSummary.cardExpMonth, expectedCardExpMonth)
        XCTAssertEqual(storedPaymentMethodSummary.cardExpYear, expectedCardExpYear)
    }

    func test_map_deposit_summary_with_settlement_fields() {
        // GIVEN
        let rawJson = "{\"id\":\"DEP_2342423423\",\"time_created\":\"2020-11-21\",\"status\":\"FUNDED\",\"funding_type\":\"CREDIT\",\"amount\":\"11400\",\"currency\":\"USD\",\"aggregation_model\":\"4-No Summary\",\"bank_transfer\":{\"masked_account_number_last4\":\"XXXXXX9999\",\"bank\":{\"code\":\"124002971\"}},\"system\":{\"mid\":\"101023947262\",\"hierarchy\":\"055-70-024-011-019\",\"name\":\"XYZ LTD.\",\"dba\":\"XYZ Group\"},\"sales\":{\"count\":4,\"amount\":\"12400\"},\"action\":{\"id\":\"ACT_TWdmMMOBZ91iQX1DcvxYermuVJ6E6h\",\"type\":\"DEPOSIT_SINGLE\",\"time_created\":\"2020-11-24T18:43:43.370Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"JF2GQpeCrOivkBGsTRiqkpkdKp67Gxi0\",\"app_name\":\"test_app\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedAggregationModel = "4-No Summary"
        let expectedMaskedAccountNumberLast4 = "XXXXXX9999"
        let expectedBankCode = "124002971"
        let expectedActionId = "ACT_TWdmMMOBZ91iQX1DcvxYermuVJ6E6h"
        let expectedActionType = "DEPOSIT_SINGLE"
        let expectedActionResultCode = "SUCCESS"

        // WHEN
        let depositSummary = GpApiMapping.mapDepositSummary(doc)

        // THEN
        XCTAssertEqual(depositSummary.aggregationModel, expectedAggregationModel)
        XCTAssertEqual(depositSummary.bankTransfer?.maskedAccountNumberLast4, expectedMaskedAccountNumberLast4)
        XCTAssertEqual(depositSummary.bankTransfer?.bank?.code, expectedBankCode)
        XCTAssertEqual(depositSummary.action?.id, expectedActionId)
        XCTAssertEqual(depositSummary.action?.type, expectedActionType)
        XCTAssertEqual(depositSummary.action?.resultCode, expectedActionResultCode)
    }

    func test_map_settlement_dispute_summary_with_transaction_fields() {
        // GIVEN
        let rawJson = "{\"id\":\"DIS_812\",\"status\":\"FUNDED\",\"stage\":\"CHARGEBACK\",\"stage_time_created\":\"2021-03-18T12:35:28\",\"amount\":\"200\",\"currency\":\"GBP\",\"funding_type\":\"DEBIT\",\"deposit_id\":\"DEP_2342423443\",\"deposit_time_created\":\"2021-03-22\",\"system\":{\"mid\":\"101023947262\",\"hierarchy\":\"055-70-024-011-019\",\"tid\":\"55555555\",\"name\":\"XYZ LTD.\"},\"transaction\":{\"time_created\":\"2021-02-23T12:35:28\",\"merchant_time_created\":\"2021-02-23T14:35:28\",\"type\":\"SALE\",\"amount\":\"200\",\"currency\":\"GBP\",\"reference\":\"28012076eb6M\",\"order\":{\"reference\":\"b636294sd5b6826hjdnde92\"},\"payment_method\":{\"card\":{\"masked_number_first6last4\":\"379132XXXXX1007\",\"arn\":\"71400011203688701393903\",\"brand\":\"AMEX\",\"authcode\":\"129623\",\"brand_reference\":\"MWE1P0JG80110\"}}}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedDepositType = "DEBIT"
        let expectedTerminalId = "55555555"
        let expectedTransactionLocalTime = "2021-02-23T14:35:28".format()
        let expectedTransactionOrderId = "b636294sd5b6826hjdnde92"
        let expectedTransactionBrandReference = "MWE1P0JG80110"

        // WHEN
        let disputeSummary = GpApiMapping.mapDisputeSummary(doc)

        // THEN
        XCTAssertEqual(disputeSummary.depositType, expectedDepositType)
        XCTAssertEqual(disputeSummary.caseTerminalId, expectedTerminalId)
        XCTAssertEqual(disputeSummary.transactionLocalTime, expectedTransactionLocalTime)
        XCTAssertEqual(disputeSummary.transactionOrderId, expectedTransactionOrderId)
        XCTAssertEqual(disputeSummary.transactionBrandReference, expectedTransactionBrandReference)
    }

    func test_map_settlement_transaction_summary() {
        // GIVEN
        let rawJson = "{\"id\":\"TRN_1234\",\"settlement_transaction_reference\":\"STR_1234\",\"time_created\":\"2021-03-18T12:35:28\",\"status\":\"FUNDED\",\"type\":\"SALE\",\"amount\":\"11099\",\"currency\":\"USD\",\"merchant_amount\":\"9000\",\"merchant_currency\":\"CAD\",\"discount_amount\":\"500\",\"merchant_discount_amount\":\"450\",\"tax_amount\":\"200\",\"merchant_tax_amount\":\"180\",\"tax_in_merchant_amount\":\"true\",\"reference\":\"TRX_REF_1\",\"time_created_reference\":\"2021-03-18T14:35:28\",\"deposit_id\":\"DEP_1234\",\"deposit_time_created\":\"2021-03-19\",\"deposit_status\":\"FUNDED\",\"deposit_amount\":\"11000\",\"batch_id\":\"BAT_1234\",\"batch_time_created\":\"2021-03-19T10:00:00\",\"order\":{\"reference\":\"INV#88547\"},\"payment_method\":{\"entry_mode\":\"ECOM\",\"card\":{\"brand\":\"VISA\",\"authcode\":\"12345\",\"brand_reference\":\"BR_1234\",\"masked_number_first6last4\":\"411111XXXXXX1111\",\"settlement_code\":\"07\",\"funding\":\"CREDIT\",\"arn\":\"210286643954856\"}},\"system\":{\"mid\":\"101023947262\",\"tid\":\"55555555\",\"hierarchy\":\"055-70-024-011-019\",\"name\":\"XYZ LTD.\",\"dba\":\"XYZ Group\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedSettlementTransactionReference = "STR_1234"
        let expectedAmount = NSDecimalNumber(string: "110.99")
        let expectedMerchantAmount: NSDecimalNumber = 90
        let expectedMerchantCurrency = "CAD"
        let expectedDiscountAmount: NSDecimalNumber = 5
        let expectedMerchantDiscountAmount = NSDecimalNumber(string: "4.5")
        let expectedTaxAmount: NSDecimalNumber = 2
        let expectedMerchantTaxAmount = NSDecimalNumber(string: "1.8")
        let expectedTaxInMerchantAmount = true
        let expectedBatchId = "BAT_1234"
        let expectedBatchTimeCreated = "2021-03-19T10:00:00".format()
        let expectedOrderReference = "INV#88547"
        let expectedSettlementCode = "07"
        let expectedCardFunding = "CREDIT"
        let expectedDepositAmount: NSDecimalNumber = 110
        let expectedDepositCurrency = "USD"
        let expectedMerchantDeviceIdentifier = "55555555"

        // WHEN
        let transactionSummary = GpApiMapping.mapTransactionSummary(doc)

        // THEN
        XCTAssertEqual(transactionSummary.settlementTransactionReference, expectedSettlementTransactionReference)
        XCTAssertEqual(transactionSummary.amount, expectedAmount)
        XCTAssertEqual(transactionSummary.merchantAmount, expectedMerchantAmount)
        XCTAssertEqual(transactionSummary.merchantCurrency, expectedMerchantCurrency)
        XCTAssertEqual(transactionSummary.discountAmount, expectedDiscountAmount)
        XCTAssertEqual(transactionSummary.merchantDiscountAmount, expectedMerchantDiscountAmount)
        XCTAssertEqual(transactionSummary.taxAmount, expectedTaxAmount)
        XCTAssertEqual(transactionSummary.merchantTaxAmount, expectedMerchantTaxAmount)
        XCTAssertEqual(transactionSummary.taxInMerchantAmount, expectedTaxInMerchantAmount)
        XCTAssertEqual(transactionSummary.batchId, expectedBatchId)
        XCTAssertEqual(transactionSummary.batchTimeCreated, expectedBatchTimeCreated)
        XCTAssertEqual(transactionSummary.orderReference, expectedOrderReference)
        XCTAssertEqual(transactionSummary.settlementCode, expectedSettlementCode)
        XCTAssertEqual(transactionSummary.cardFunding, expectedCardFunding)
        XCTAssertEqual(transactionSummary.depositAmount, expectedDepositAmount)
        XCTAssertEqual(transactionSummary.depositCurrency, expectedDepositCurrency)
        XCTAssertEqual(transactionSummary.merchantDeviceIdentifier, expectedMerchantDeviceIdentifier)
    }

    func test_map_settlement_transaction_fees() {
        // GIVEN
        let rawJson = "{\"id\":\"TRN_1234\",\"amount\":\"11099\",\"currency\":\"USD\",\"fees\":{\"total_amount_decimal\":\"12.98\",\"other_fees_amount_decimal\":\"1.10\",\"fixed_amount_decimal\":\"1.29\",\"tax_amount_decimal\":\"0.98\",\"assessment_total_amount_decimal\":\"0.75\",\"charge_type\":\"GLOBAL\",\"charge_type_description\":\"Global Fee\",\"charge_type_region\":\"US\",\"exchange_rate\":\"1.25\",\"interchange\":{\"total_amount_decimal\":\"9.99\",\"total_rate\":\"1.85\",\"program\":\"VISA CREDIT\",\"percentage\":\"1.75\",\"percentage_amount_decimal\":\"9.00\",\"per_item_flat_amount_decimal\":\"0.30\",\"per_item_calculated_amount_decimal\":\"8.70\"},\"discount\":{\"rate_1_percentage\":\"0.10\",\"rate_2_percentage\":\"0.20\",\"total_amount_decimal\":\"1.50\"},\"assessment_1\":{\"description\":\"Assessment One\",\"percentage\":\"0.10\",\"amount_decimal\":\"0.20\"},\"assessment_2\":{\"description\":\"Assessment Two\",\"percentage\":\"0.30\",\"amount_decimal\":\"0.40\"},\"assessment_3\":{\"description\":\"Assessment Three\",\"percentage\":\"0.50\",\"amount_decimal\":\"0.60\"},\"assessment_4\":{\"description\":\"Assessment Four\",\"percentage\":\"0.70\",\"amount_decimal\":\"0.80\"},\"assessment_5\":{\"description\":\"Assessment Five\",\"percentage\":\"0.90\",\"amount_decimal\":\"1.00\"},\"mark_up\":{\"dcc_percentage\":\"3.00\",\"multicurrency_percentage\":\"2.00\"}}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedTotalAmount = NSDecimalNumber(string: "12.98")
        let expectedOtherFeesAmount = NSDecimalNumber(string: "1.10")
        let expectedFixedAmount = NSDecimalNumber(string: "1.29")
        let expectedTaxAmount = NSDecimalNumber(string: "0.98")
        let expectedAssessmentTotalAmount = NSDecimalNumber(string: "0.75")
        let expectedChargeType = "GLOBAL"
        let expectedChargeTypeDescription = "Global Fee"
        let expectedChargeTypeRegion = "US"
        let expectedExchangeRate = "1.25"
        let expectedInterchangeTotalAmount = NSDecimalNumber(string: "9.99")
        let expectedInterchangeTotalRate = "1.85"
        let expectedInterchangeProgram = "VISA CREDIT"
        let expectedInterchangePercentage = "1.75"
        let expectedInterchangePercentageAmount = NSDecimalNumber(string: "9.00")
        let expectedInterchangePerItemFlatAmount = NSDecimalNumber(string: "0.30")
        let expectedInterchangePerItemCalculatedAmount = NSDecimalNumber(string: "8.70")
        let expectedDiscountRate1Percentage = "0.10"
        let expectedDiscountRate2Percentage = "0.20"
        let expectedDiscountTotalAmount = NSDecimalNumber(string: "1.50")
        let expectedMarkUpDccPercentage = "3.00"
        let expectedMarkUpMulticurrencyPercentage = "2.00"

        // WHEN
        let transactionSummary = GpApiMapping.mapTransactionSummary(doc)

        // THEN
        guard let fees = transactionSummary.fees else {
            XCTFail("fees cannot be nil")
            return
        }
        XCTAssertEqual(fees.totalAmount, expectedTotalAmount)
        XCTAssertEqual(fees.otherFeesAmount, expectedOtherFeesAmount)
        XCTAssertEqual(fees.fixedAmount, expectedFixedAmount)
        XCTAssertEqual(fees.taxAmount, expectedTaxAmount)
        XCTAssertEqual(fees.assessmentTotalAmount, expectedAssessmentTotalAmount)
        XCTAssertEqual(fees.chargeType, expectedChargeType)
        XCTAssertEqual(fees.chargeTypeDescription, expectedChargeTypeDescription)
        XCTAssertEqual(fees.chargeTypeRegion, expectedChargeTypeRegion)
        XCTAssertEqual(fees.exchangeRate, expectedExchangeRate)
        XCTAssertEqual(fees.interchange?.totalAmount, expectedInterchangeTotalAmount)
        XCTAssertEqual(fees.interchange?.totalRate, expectedInterchangeTotalRate)
        XCTAssertEqual(fees.interchange?.program, expectedInterchangeProgram)
        XCTAssertEqual(fees.interchange?.percentage, expectedInterchangePercentage)
        XCTAssertEqual(fees.interchange?.percentageAmount, expectedInterchangePercentageAmount)
        XCTAssertEqual(fees.interchange?.perItemFlatAmount, expectedInterchangePerItemFlatAmount)
        XCTAssertEqual(fees.interchange?.perItemCalculatedAmount, expectedInterchangePerItemCalculatedAmount)
        XCTAssertEqual(fees.discount?.rate1Percentage, expectedDiscountRate1Percentage)
        XCTAssertEqual(fees.discount?.rate2Percentage, expectedDiscountRate2Percentage)
        XCTAssertEqual(fees.discount?.totalAmount, expectedDiscountTotalAmount)
        XCTAssertEqual(fees.markUp?.dccPercentage, expectedMarkUpDccPercentage)
        XCTAssertEqual(fees.markUp?.multicurrencyPercentage, expectedMarkUpMulticurrencyPercentage)
        XCTAssertEqual(fees.assessment1?.chargeDescription, "Assessment One")
        XCTAssertEqual(fees.assessment1?.percentage, "0.10")
        XCTAssertEqual(fees.assessment1?.amount, NSDecimalNumber(string: "0.20"))
        XCTAssertEqual(fees.assessment2?.chargeDescription, "Assessment Two")
        XCTAssertEqual(fees.assessment3?.chargeDescription, "Assessment Three")
        XCTAssertEqual(fees.assessment4?.chargeDescription, "Assessment Four")
        XCTAssertEqual(fees.assessment5?.chargeDescription, "Assessment Five")
        XCTAssertEqual(fees.assessment5?.amount, NSDecimalNumber(string: "1.00"))
    }

    func test_map_monthly_fee_summary() {
        // GIVEN
        let rawJson = "{\"time_created\":\"2021-05-03T21:23:39.718Z\",\"status\":\"FINALIZED\",\"amount\":\"11099\",\"currency\":\"USD\",\"interchange_amount\":\"100\",\"assessment_amount\":\"200\",\"authorization_amount\":\"300\",\"chargeback_amount\":\"400\",\"supplies_amount\":\"500\",\"device_amount\":\"600\",\"discount_amount\":\"700\",\"other_amount\":\"1600\",\"transaction_count\":123,\"sales\":{\"count\":100,\"amount\":\"9000\"},\"refunds\":{\"count\":20,\"amount\":\"1000\"},\"passthrough\":{\"amount\":\"500\"},\"merchant\":{\"name\":\"XYZ LTD.\",\"address\":{\"line_1\":\"1 Main St\",\"line_2\":\"Suite 2\",\"line_3\":\"Building B\",\"city\":\"Phoenix\",\"state\":\"AZ\",\"postal_code\":\"90210\",\"country\":\"US\"}},\"system\":{\"mid\":\"101023947262\",\"hierarchy\":\"055-70-024-011-019\",\"name\":\"XYZ LTD.\",\"dba\":\"XYZ Group\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedTimeCreated = "2021-05-03T21:23:39.718Z".format()
        let expectedStatus: MonthlyFeeStatus = .finalized
        let expectedAmount = NSDecimalNumber(string: "110.99")
        let expectedCurrency = "USD"
        let expectedInterchangeAmount: NSDecimalNumber = 1
        let expectedAssessmentAmount: NSDecimalNumber = 2
        let expectedAuthorizationAmount: NSDecimalNumber = 3
        let expectedChargebackAmount: NSDecimalNumber = 4
        let expectedSuppliesAmount: NSDecimalNumber = 5
        let expectedDeviceAmount: NSDecimalNumber = 6
        let expectedDiscountAmount: NSDecimalNumber = 7
        let expectedOtherAmount: NSDecimalNumber = 16
        let expectedTransactionCount = 123
        let expectedSalesCount = 100
        let expectedSalesAmount: NSDecimalNumber = 90
        let expectedRefundsCount = 20
        let expectedRefundsAmount: NSDecimalNumber = 10
        let expectedPassthroughAmount: NSDecimalNumber = 5
        let expectedMerchantName = "XYZ LTD."
        let expectedMerchantAddressLine1 = "1 Main St"
        let expectedMerchantAddressCity = "Phoenix"
        let expectedMerchantAddressState = "AZ"
        let expectedMerchantAddressPostalCode = "90210"
        let expectedMerchantAddressCountry = "US"
        let expectedMid = "101023947262"
        let expectedHierarchy = "055-70-024-011-019"
        let expectedSystemName = "XYZ LTD."
        let expectedSystemDba = "XYZ Group"

        // WHEN
        let monthlyFeeSummary = GpApiMapping.mapMonthlyFeeSummary(doc)

        // THEN
        XCTAssertEqual(monthlyFeeSummary.timeCreated, expectedTimeCreated)
        XCTAssertEqual(monthlyFeeSummary.status, expectedStatus)
        XCTAssertEqual(monthlyFeeSummary.amount, expectedAmount)
        XCTAssertEqual(monthlyFeeSummary.currency, expectedCurrency)
        XCTAssertEqual(monthlyFeeSummary.interchangeAmount, expectedInterchangeAmount)
        XCTAssertEqual(monthlyFeeSummary.assessmentAmount, expectedAssessmentAmount)
        XCTAssertEqual(monthlyFeeSummary.authorizationAmount, expectedAuthorizationAmount)
        XCTAssertEqual(monthlyFeeSummary.chargebackAmount, expectedChargebackAmount)
        XCTAssertEqual(monthlyFeeSummary.suppliesAmount, expectedSuppliesAmount)
        XCTAssertEqual(monthlyFeeSummary.deviceAmount, expectedDeviceAmount)
        XCTAssertEqual(monthlyFeeSummary.discountAmount, expectedDiscountAmount)
        XCTAssertEqual(monthlyFeeSummary.otherAmount, expectedOtherAmount)
        XCTAssertEqual(monthlyFeeSummary.transactionCount, expectedTransactionCount)
        XCTAssertEqual(monthlyFeeSummary.sales?.count, expectedSalesCount)
        XCTAssertEqual(monthlyFeeSummary.sales?.amount, expectedSalesAmount)
        XCTAssertEqual(monthlyFeeSummary.refunds?.count, expectedRefundsCount)
        XCTAssertEqual(monthlyFeeSummary.refunds?.amount, expectedRefundsAmount)
        XCTAssertEqual(monthlyFeeSummary.passthrough?.amount, expectedPassthroughAmount)
        XCTAssertEqual(monthlyFeeSummary.merchant?.name, expectedMerchantName)
        XCTAssertEqual(monthlyFeeSummary.merchant?.address?.line1, expectedMerchantAddressLine1)
        XCTAssertEqual(monthlyFeeSummary.merchant?.address?.city, expectedMerchantAddressCity)
        XCTAssertEqual(monthlyFeeSummary.merchant?.address?.state, expectedMerchantAddressState)
        XCTAssertEqual(monthlyFeeSummary.merchant?.address?.postalCode, expectedMerchantAddressPostalCode)
        XCTAssertEqual(monthlyFeeSummary.merchant?.address?.country, expectedMerchantAddressCountry)
        XCTAssertEqual(monthlyFeeSummary.system?.mid, expectedMid)
        XCTAssertEqual(monthlyFeeSummary.system?.hierarchy, expectedHierarchy)
        XCTAssertEqual(monthlyFeeSummary.system?.name, expectedSystemName)
        XCTAssertEqual(monthlyFeeSummary.system?.dba, expectedSystemDba)
    }

    func test_map_paged_monthly_fee_result() {
        // GIVEN
        let rawJson = "{\"total_record_count\":2,\"current_page_size\":2,\"merchant_id\":\"101023947262\",\"merchant_name\":\"Sandbox_merchant_2\",\"account_id\":\"TRA_6716058969854a48b33347043ff8225f\",\"account_name\":\"Settlement_Reporting\",\"filter\":{\"from_time_created\":\"2021-05-01\",\"to_time_created\":\"2021-05-31\"},\"paging\":{\"page\":1,\"page_size\":5,\"order_by\":\"TIME_CREATED\",\"order\":\"ASC\"},\"monthly_fees\":[{\"time_created\":\"2021-05-01T00:00:00.000Z\",\"status\":\"ESTIMATED\",\"amount\":\"100\",\"currency\":\"USD\"},{\"time_created\":\"2021-05-02T00:00:00.000Z\",\"status\":\"FINALIZED\",\"amount\":\"200\",\"currency\":\"USD\"}],\"action\":{\"id\":\"ACT_uzFr7t4VOqxdLDI44hHmXIjHtOOE8d\",\"type\":\"MONTHLY_FEES_LIST\",\"time_created\":\"2021-05-03T21:23:39.718Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"uzFr7t4VOqxdLDI44hHmXIjHtOOE8d\",\"app_name\":\"my_lovely_app\"}}"
        let expectedTotalRecordCount = 2
        let expectedPage = 1
        let expectedPageSize = 5
        let expectedActionType = "MONTHLY_FEES_LIST"
        let expectedFirstFeeAmount: NSDecimalNumber = 1
        let expectedSecondFeeAmount: NSDecimalNumber = 2

        // WHEN
        let result: PagedResult<MonthlyFeeSummary>? = GpApiMapping.mapReportResponse(rawJson, .findMonthlyFeesPaged)

        // THEN
        guard let pagedResult = result else {
            XCTFail("pagedResult cannot be nil")
            return
        }
        XCTAssertEqual(pagedResult.totalRecordCount, expectedTotalRecordCount)
        XCTAssertEqual(pagedResult.page, expectedPage)
        XCTAssertEqual(pagedResult.pageSize, expectedPageSize)
        XCTAssertEqual(pagedResult.action?.type, expectedActionType)
        XCTAssertEqual(pagedResult.results.count, 2)
        XCTAssertEqual(pagedResult.results.first?.amount, expectedFirstFeeAmount)
        XCTAssertEqual(pagedResult.results.first?.status, MonthlyFeeStatus.estimated)
        XCTAssertEqual(pagedResult.results.last?.amount, expectedSecondFeeAmount)
        XCTAssertEqual(pagedResult.results.last?.status, MonthlyFeeStatus.finalized)
    }
}
