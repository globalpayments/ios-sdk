import XCTest
import GlobalPayments_iOS_SDK

class GpApiMappingTests: XCTestCase {

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
        let expectedToken = "PMT_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7"
        let expectedAuthorizationCode = "00"
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
}
