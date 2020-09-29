import Foundation

extension GpApiConnector: IReportingService {

    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?, Error?) -> Void)?) {

        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }

            var reportUrl: String = .empty
            var queryStringParams = [String: String]()

            if let builder = builder as? TransactionReportBuilder<T> {

                if builder.reportType == .transactionDetail,
                   let transactionId = builder.transactionId {
                    reportUrl = Endpoints.transactionsWith(transactionId: transactionId)
                }
                else if builder.reportType == .findTransactions {
                    reportUrl = Endpoints.transactions()

                    if let page = builder.page {
                        queryStringParams["PAGE"] = "\(page)"
                    }
                    if let pageSize = builder.pageSize {
                        queryStringParams["PAGE_SIZE"] = "\(pageSize)"
                    }
                    queryStringParams["ORDER_BY"] = builder.transactionOrderBy?.mapped(for: .gpApi)
                    queryStringParams["ORDER"] = builder.transactionOrder?.mapped(for: .gpApi)
                    queryStringParams["ACCOUNT_NAME"] = builder.searchCriteriaBuilder.accountName
                    queryStringParams["ID"] = builder.transactionId
                    queryStringParams["BRAND"] = builder.searchCriteriaBuilder.cardBrand
                    queryStringParams["MASKED_NUMBER_FIRST6LAST4"] = builder.searchCriteriaBuilder.maskedCardNumber
                    queryStringParams["ARN"] = builder.searchCriteriaBuilder.aquirerReferenceNumber
                    queryStringParams["BRAND_REFERENCE"] = builder.searchCriteriaBuilder.brandReference
                    queryStringParams["AUTHCODE"] = builder.searchCriteriaBuilder.authCode
                    queryStringParams["REFERENCE"] = builder.searchCriteriaBuilder.referenceNumber
                    queryStringParams["STATUS"] = builder.searchCriteriaBuilder.transactionStatus?.mapped(for: .gpApi)
                    queryStringParams["FROM_TIME_CREATED"] = (builder.startDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["TO_TIME_CREATED"] = (builder.endDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["DEPOSIT_ID"] = builder.searchCriteriaBuilder.depositReference
                    queryStringParams["FROM_DEPOSIT_TIME_CREATED"] = builder.searchCriteriaBuilder.startDepositDate?.format("yyyy-MM-dd")
                    queryStringParams["TO_DEPOSIT_TIME_CREATED"] = builder.searchCriteriaBuilder.endDepositDate?.format("yyyy-MM-dd")
                    queryStringParams["FROM_BATCH_TIME_CREATED"] = builder.searchCriteriaBuilder.startBatchDate?.format("yyyy-MM-dd")
                    queryStringParams["TO_BATCH_TIME_CREATED"] = builder.searchCriteriaBuilder.endBatchDate?.format("yyyy-MM-dd")
                    queryStringParams["SYSTEM.MID"] = builder.searchCriteriaBuilder.merchantId
                    queryStringParams["SYSTEM.HIERARCHY"] = builder.searchCriteriaBuilder.systemHierarchy
                }
                else if builder.reportType == .findDeposits {
                    reportUrl = Endpoints.deposits()

                    queryStringParams["account_name"] = self?.dataAccountName
                    if let page = builder.page {
                        queryStringParams["page"] = "\(page)"
                    }
                    if let pageSize = builder.pageSize {
                        queryStringParams["page_size"] = "\(pageSize)"
                    }
                    queryStringParams["order_by"] = builder.depositOrderBy?.mapped(for: .gpApi)
                    queryStringParams["order"] = builder.depositOrder?.mapped(for: .gpApi)
                    queryStringParams["from_deposit_time_created"] = (builder.startDate ?? Date()).format("yyyy-MM-dd")
                }
                else if builder.reportType == .findDisputes {
                    reportUrl = Endpoints.disputes()

                    if let page = builder.page {
                        queryStringParams["page"] = "\(page)"
                    }
                    if let pageSize = builder.pageSize {
                        queryStringParams["page_size"] = "\(pageSize)"
                    }
                    queryStringParams["order_by"] = builder.disputeOrderBy?.mapped(for: .gpApi)
                    queryStringParams["order"] = builder.disputeOrder?.mapped(for: .gpApi)
                    queryStringParams["arn"] = builder.searchCriteriaBuilder.aquirerReferenceNumber
                    queryStringParams["brand"] = builder.searchCriteriaBuilder.cardBrand
                    queryStringParams["status"] = builder.searchCriteriaBuilder.disputeStatus?.mapped(for: .gpApi)
                    queryStringParams["stage"] = builder.searchCriteriaBuilder.disputeStage?.mapped(for: .gpApi)
                    queryStringParams["from_stage_time_created"] = (builder.searchCriteriaBuilder.startStageDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["to_stage_time_created"] = (builder.searchCriteriaBuilder.endStageDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["adjustment_funding"] = builder.searchCriteriaBuilder.adjustmentFunding?.mapped(for: .gpApi)

                    queryStringParams["from_adjustment_time_created"] = (builder.searchCriteriaBuilder.startAdjustmentDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["to_adjustment_time_created"] = (builder.searchCriteriaBuilder.endAdjustmentDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["system.mid"] = builder.searchCriteriaBuilder.merchantId
                    queryStringParams["system.hierarchy"] = builder.searchCriteriaBuilder.systemHierarchy
                }
            }

            self?.doTransaction(
                method: .get,
                endpoint: reportUrl,
                queryStringParams: queryStringParams) { [weak self] response, error in
                if let error = error {
                    completion?(nil, error)
                    return
                }
                guard let response = response else {
                    completion?(nil, error)
                    return
                }

                completion?(self?.mapReportResponse(
                    response,
                    reportType: builder.reportType
                ), nil
                )
            }
        }
    }

    private func mapReportResponse<T>(_ rawResponse: String, reportType: ReportType) -> T? {
        var result: T?
        let json = JsonDoc.parse(rawResponse)

        if reportType == .transactionDetail && result is TransactionSummary? {
            result = mapTransactionSummary(json) as? T
        } else if reportType == .findTransactions && result is [TransactionSummary]? {
            if let transactions: [JsonDoc] = json?.getValue(key: "transactions") {
                let mapped = transactions.map { mapTransactionSummary($0) }
                result = mapped as? T
            }
        } else if reportType == .findDeposits && result is DepositSummary? {
            result = mapDepositSummary(json) as? T
        } else if reportType == .findDeposits && result is [DepositSummary]? {
            if let deposits: [JsonDoc] = json?.getValue(key: "deposits") {
                let mapped = deposits.map { mapDepositSummary($0) }
                result = mapped as? T
            }
        } else if reportType == .findDeposits && result is DisputeSummary? {
            result = mapDisputeSummary(json) as? T
        } else if reportType == .findDeposits && result is [DisputeSummary]? {
            if let disputes: [JsonDoc] = json?.getValue(key: "disputes") {
                let mapped = disputes.map { mapDisputeSummary($0) }
                result = mapped as? T
            }
        }

        return result
    }

    private func mapTransactionSummary(_ doc: JsonDoc?) -> TransactionSummary {
        let paymentMethod: JsonDoc? = doc?.get(valueFor: "payment_method")
        let card: JsonDoc? = paymentMethod?.get(valueFor: "card")

        let summary = TransactionSummary()
        //TODO: Map all transaction properties
        summary.transactionId = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.transactionDate = timeCreated?.format()
        summary.transactionStatus = doc?.getValue(key: "status")
        summary.transactionType = doc?.getValue(key: "type")
        summary.channel = doc?.getValue(key: "channel")
        summary.amount = NSDecimalNumber(string: doc?.getValue(key: "amount"))
        summary.currency = doc?.getValue(key: "currency")
        summary.referenceNumber = doc?.getValue(key: "reference")
        summary.clientTransactionId = doc?.getValue(key: "reference")
        // ?? = doc.getValue(key: "time_created_reference")
        summary.batchSequenceNumber = doc?.getValue(key: "batch_id")
        summary.country = doc?.getValue(key: "country")
        // ?? = doc.getValue(key: "action_create_id")
        summary.originalTransactionId = doc?.getValue(key: "parent_resource_id")

        summary.gatewayResponseMessage = paymentMethod?.getValue(key: "message")
        summary.entryMode = paymentMethod?.getValue(key: "entry_mode")
        //?? = paymentMethod?.getValue(key: "name")

        summary.cardType = card?.getValue(key: "brand")
        summary.authCode = card?.getValue(key: "authcode")
        //?? = card?.getValue(key: "brand_reference")
        summary.aquirerReferenceNumber = card?.getValue(key: "arn")
        summary.maskedCardNumber = card?.getValue(key: "masked_number_first6last4")

        return summary
    }

    private func mapDepositSummary(_ doc: JsonDoc?) -> DepositSummary {
        let summary = DepositSummary()
        // TODO: map all available fields
        return summary
    }

    private func mapDisputeSummary(_ doc: JsonDoc?) -> DisputeSummary {
        let summary = DisputeSummary()
        // TODO: map all available fields
        summary.caseId = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.caseIdTime = timeCreated?.format()
        summary.caseStatus = doc?.getValue(key: "status")
        //stage
        summary.caseAmount = NSDecimalNumber(string: doc?.getValue(key: "amount"))
        summary.caseCurrency = doc?.getValue(key: "currency")
        summary.caseMerchantId = doc?.get(valueFor: "system")?.getValue(key: "mid")
        summary.merchantHierarchy = doc?.get(valueFor: "system")?.getValue(key: "hierarchy")
        summary.transactionMaskedCardNumber = doc?.get(valueFor: "payment_method")?.get(valueFor: "card")?.getValue(key: "number")
        summary.transactionARN = doc?.get(valueFor: "payment_method")?.get(valueFor: "card")?.getValue(key: "arn")
        summary.transactionCardType = doc?.get(valueFor: "payment_method")?.get(valueFor: "card")?.getValue(key: "brand")
        //reason_code
        summary.reason = doc?.getValue(key: "reason_description")
        let timeToRespondBy: String? = doc?.getValue(key: "time_to_respond_by")
        summary.respondByDate = timeToRespondBy?.format()
        //result
        //last_adjustment_amount
        //last_adjustment_currency
        //last_adjustment_funding

        return summary
    }
}
