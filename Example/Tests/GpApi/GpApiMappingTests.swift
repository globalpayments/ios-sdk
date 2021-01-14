import XCTest
import GlobalPayments_iOS_SDK

class GpApiMappingTests: XCTestCase {

    func test_map_transaction_without_card() {
        // GIVEN
        let rawJson = "{\"id\":\"TRN_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7\",\"time_created\":\"2020-05-01T01:53:20.649Z\",\"time_last_updated\":\"2020-05-01T01:53:24.481Z\",\"status\":\"CAPTURED\",\"type\":\"SALE\",\"merchant_id\":\"MER_c4c0df11039c48a9b63701adeaa296c3\",\"merchant_name\":\"Sandbox_merchant_2\",\"account_id\":\"TRA_6716058969854a48b33347043ff8225f\",\"account_name\":\"Transaction_Processing\",\"channel\":\"CNP\",\"amount\":\"10000\",\"currency\":\"CAD\",\"reference\":\"My-TRANS-184398064\",\"description\":\"\",\"order_reference\":\"\",\"time_created_reference\":\"\",\"batch_id\":\"BAT_783464\",\"initiator\":\"\",\"country\":\"US\",\"language\":\"\",\"ip_address\":\"97.107.232.5\",\"site_reference\":\"\",\"payment_method\":{\"result\":\"00\",\"message\":\"Settled Successfully\",\"entry_mode\":\"ECOM\",\"name\":\"\",\"card\":{\"funding\":\"CREDIT\",\"brand\":\"MC\",\"authcode\":\"12345\",\"brand_reference\":\"\",\"masked_number_first6last4\":\"\",\"cvv_indicator\":\"\",\"cvv_result\":\"\",\"avs_address_result\":\"\",\"avs_postal_code_result\":\"\"}},\"action_create_id\":\"ACT_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7\",\"parent_resource_id\":\"TRN_JP9qn3ivl6iPNFRFSiCHesn0I5gs7t\",\"action\":{\"id\":\"ACT_k2incP0JYsIVRSJ8nzzSZm3gGWoNbr\",\"type\":\"TRANSACTION_SINGLE\",\"time_created\":\"2020-12-04T12:28:25.712Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"i9R0byBBor6RqTQNj3g4MuVBwH5rd7yR\",\"app_name\":\"demo_app\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedTransactionId = "TRN_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7"
        let expectedBalanceAmount: NSDecimalNumber = 100
        let expectedTimestamp = "2020-05-01T01:53:20.649Z"
        let expectedResponseMessage = "CAPTURED"
        let expectedReferenceNumber = "My-TRANS-184398064"
        let expectedBatchSummary = "BAT_783464"
        let expectedResponseCode = "SUCCESS"
        let expectedToken = "TRN_ImiKh03hpvpjJDPMLmCbpRMyv5v6Q7"
        let expectedAuthorizationCode = "00"

        // WHEN
        let transaction = GpApiMapping.mapTransaction(doc)

        // THEN
        XCTAssertEqual(transaction.transactionId, expectedTransactionId)
        XCTAssertEqual(transaction.balanceAmount, expectedBalanceAmount)
        XCTAssertEqual(transaction.timestamp, expectedTimestamp)
        XCTAssertEqual(transaction.responseMessage, expectedResponseMessage)
        XCTAssertEqual(transaction.referenceNumber, expectedReferenceNumber)
        XCTAssertEqual(transaction.batchSummary?.sequenceNumber, expectedBatchSummary)
        XCTAssertEqual(transaction.responseCode, expectedResponseCode)
        XCTAssertEqual(transaction.token, expectedToken)
        XCTAssertEqual(transaction.authorizationCode, expectedAuthorizationCode)
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
        XCTAssertEqual(transaction.cardLast4, expectedMaskedNumberLast4)
        XCTAssertEqual(transaction.cardType, expectedBrand)
        XCTAssertEqual(transaction.cardExpMonth, expectedCardExpMonth)
        XCTAssertEqual(transaction.cardExpYear, expectedCardExpYear)
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
        let rawJson = "{\"id\":\"DIS_SAND_abcd1235\",\"time_created\":\"2020-11-25T09:01:28.143Z\",\"merchant_id\":\"MER_62251730c5574bbcb268191b5f315de8\",\"merchant_name\":\"TEST MERCHANT\",\"account_id\":\"DIA_882c832d13e04185bb6e213d6303ed98\",\"account_name\":\"testdispute\",\"status\":\"WITH_MERCHANT\",\"status_time_created\":\"2020-11-27T09:01:28.143Z\",\"stage\":\"CHARGEBACK\",\"stage_time_created\":\"2020-11-30T09:01:28.143Z\",\"amount\":\"1500\",\"currency\":\"USD\",\"payer_amount\":\"1500\",\"payer_currency\":\"USD\",\"merchant_amount\":\"1500\",\"merchant_currency\":\"USD\",\"reason_code\":\"132\",\"reason_description\":\"Cancelled Recurring\",\"time_to_respond_by\":\"2020-12-12T09:01:28.143Z\",\"result\":\"PENDING\",\"investigator_comment\":\"WITH_MERCHANT CHARGEBACK PENDING 1500 USD 1500 USD\",\"system\":{\"mid\":\"627384967\",\"hierarchy\":\"111-23-099-001-001\",\"name\":\"ABC INC.\"},\"last_adjustment_amount\":\"1500\",\"last_adjustment_currency\":\"USD\",\"last_adjustment_funding\":\"DEBIT\",\"last_adjustment_time_created\":\"2020-12-03T09:01:28.143Z\",\"net_financial_amount\":\"1500\",\"net_financial_currency\":\"USD\",\"net_financial_funding\":\"DEBIT\",\"payment_method_provider\":[{\"comment\":\"issuer comments 34524\",\"reference\":\"issuer-reference-0002\",\"documents\":[]}],\"transaction\":{\"time_created\":\"2020-10-18T09:01:28.143Z\",\"type\":\"SALE\",\"amount\":\"1500\",\"currency\":\"USD\",\"reference\":\"my-trans-AAA2\",\"remarks\":\"my-trans-AAA2\",\"payment_method\":{\"card\":{\"number\":\"424242xxxxxx4242\",\"arn\":\"123934529762282\",\"brand\":\"VISA\",\"authcode\":\"AA2399\",\"brand_reference\":\"898375467348954\"}}},\"documents\":[{\"id\":\"DOC_MyEvidence_234234AVCDE-1\",\"type\":\"SALES_RECEIPT\"}],\"action\":{\"id\":\"ACT_5blBTHnIs4aOCIvGwG7KizYUpsGI0g\",\"type\":\"DISPUTE_SINGLE\",\"time_created\":\"2020-12-07T09:01:28.199Z\",\"result_code\":\"SUCCESS\",\"app_id\":\"i9R0byBBor6RqTQNj3g4MuVBwH5rd7yR\",\"app_name\":\"demo_app\"}}"
        let doc = JsonDoc.parse(rawJson)
        let expectedCaseId = "DIS_SAND_abcd1235"
        let expectedCaseIdTime = "2020-11-25T09:01:28.143Z".format()
        let expectedCaseStatus = "WITH_MERCHANT"
        let expectedCaseStage = DisputeStage.chargeback
        let expectedCaseAmount: NSDecimalNumber = 15
        let expectedCaseCurrency = "USD"
        let expectedCaseMerchantId = "627384967"
        let expectedMerchantHierarchy = "111-23-099-001-001"
        let expectedTransactionARN = "123934529762282"
        let expectedTransactionReferenceNumber = "my-trans-AAA2"
        let expectedTransactionAuthCode = "AA2399"
        let expectedTransactionCardType = "VISA"
        let expectedTransactionMaskedCardNumber = "424242xxxxxx4242"
        let expectedReason = "Cancelled Recurring"
        let expectedReasonCode = "132"
        let expectedRespondByDate = "2020-12-12T09:01:28.143Z".format()
        let expectedLastAdjustmentFunding = AdjustmentFunding.debit
        let expectedLastAdjustmentAmount: NSDecimalNumber = 15
        let expectedLastAdjustmentCurrency = "USD"
        let expectedLastAdjustmentTimeCreated = "2020-12-03T09:01:28.143Z".format()
        let expectedResult = "PENDING"
        let expectedDocuments = [DisputeDocument(id: "DOC_MyEvidence_234234AVCDE-1", type: DocumentType.salesReceipt)]

        // WHEN
        let disputeSummary = GpApiMapping.mapDisputeSummary(doc)

        // THEN
        XCTAssertEqual(disputeSummary.caseId, expectedCaseId)
        XCTAssertEqual(disputeSummary.caseIdTime, expectedCaseIdTime)
        XCTAssertEqual(disputeSummary.caseStatus, expectedCaseStatus)
        XCTAssertEqual(disputeSummary.caseStage, expectedCaseStage)
        XCTAssertEqual(disputeSummary.caseAmount, expectedCaseAmount)
        XCTAssertEqual(disputeSummary.caseCurrency, expectedCaseCurrency)
        XCTAssertEqual(disputeSummary.caseMerchantId, expectedCaseMerchantId)
        XCTAssertEqual(disputeSummary.merchantHierarchy, expectedMerchantHierarchy)
        XCTAssertEqual(disputeSummary.transactionARN, expectedTransactionARN)
        XCTAssertEqual(disputeSummary.transactionReferenceNumber, expectedTransactionReferenceNumber)
        XCTAssertEqual(disputeSummary.transactionAuthCode, expectedTransactionAuthCode)
        XCTAssertEqual(disputeSummary.transactionCardType, expectedTransactionCardType)
        XCTAssertEqual(disputeSummary.transactionMaskedCardNumber, expectedTransactionMaskedCardNumber)
        XCTAssertEqual(disputeSummary.reason, expectedReason)
        XCTAssertEqual(disputeSummary.reasonCode, expectedReasonCode)
        XCTAssertEqual(disputeSummary.respondByDate, expectedRespondByDate)
        XCTAssertEqual(disputeSummary.lastAdjustmentFunding, expectedLastAdjustmentFunding)
        XCTAssertEqual(disputeSummary.lastAdjustmentAmount, expectedLastAdjustmentAmount)
        XCTAssertEqual(disputeSummary.lastAdjustmentCurrency, expectedLastAdjustmentCurrency)
        XCTAssertEqual(disputeSummary.lastAdjustmentTimeCreated, expectedLastAdjustmentTimeCreated)
        XCTAssertEqual(disputeSummary.result, expectedResult)
        guard let documents = disputeSummary.documents, !documents.isEmpty else {
            XCTFail("documents cannot be nil or empty")
            return
        }
        XCTAssertEqual(documents, expectedDocuments)
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
}
