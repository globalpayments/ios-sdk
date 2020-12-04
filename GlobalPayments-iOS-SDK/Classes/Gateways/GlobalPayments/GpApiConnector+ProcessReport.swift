import Foundation

extension GpApiConnector: ReportingServiceType {

    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?, Error?) -> Void)?) {

        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }

            var reportUrl: String = .empty
            var queryStringParams = [String: String]()
            var method: HTTPMethod = .get

            func addQueryStringParam(params: inout [String: String], key: String, value: String?) {
                guard let value = value, !value.isEmpty else { return }
                params[key] = value
            }

            if let builder = builder as? TransactionReportBuilder<T> {

                if builder.reportType == .transactionDetail,
                   let transactionId = builder.transactionId {
                    reportUrl = Endpoints.transactionsWith(transactionId: transactionId)
                }
                else if builder.reportType == .findTransactions {
                    reportUrl = Endpoints.transactions()
                    if let page = builder.page {
                        addQueryStringParam(params: &queryStringParams, key: "page", value: "\(page)")
                    }
                    if let pageSize = builder.pageSize {
                        addQueryStringParam(params: &queryStringParams, key: "page_size", value: "\(pageSize)")
                    }
                    addQueryStringParam(params: &queryStringParams, key: "order_by", value: builder.transactionOrderBy?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "order", value: builder.transactionOrder?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "id", value: builder.transactionId)
                    addQueryStringParam(params: &queryStringParams, key: "type", value: builder.searchCriteriaBuilder.paymentType?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "channel", value: builder.searchCriteriaBuilder.channel?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "amount", value: builder.searchCriteriaBuilder.amount?.toNumericCurrencyString())
                    addQueryStringParam(params: &queryStringParams, key: "currency", value: builder.searchCriteriaBuilder.currency)
                    addQueryStringParam(params: &queryStringParams, key: "number_first6", value: builder.searchCriteriaBuilder.cardNumberFirstSix)
                    addQueryStringParam(params: &queryStringParams, key: "number_last4", value: builder.searchCriteriaBuilder.cardNumberLastFour)
                    addQueryStringParam(params: &queryStringParams, key: "token_first6", value: builder.searchCriteriaBuilder.tokenFirstSix)
                    addQueryStringParam(params: &queryStringParams, key: "token_last4", value: builder.searchCriteriaBuilder.tokenLastFour)
                    addQueryStringParam(params: &queryStringParams, key: "account_name", value: builder.searchCriteriaBuilder.accountName)
                    addQueryStringParam(params: &queryStringParams, key: "brand", value: builder.searchCriteriaBuilder.cardBrand)
                    addQueryStringParam(params: &queryStringParams, key: "brand_reference", value: builder.searchCriteriaBuilder.brandReference)
                    addQueryStringParam(params: &queryStringParams, key: "authcode", value: builder.searchCriteriaBuilder.authCode)
                    addQueryStringParam(params: &queryStringParams, key: "reference", value: builder.searchCriteriaBuilder.referenceNumber)
                    addQueryStringParam(params: &queryStringParams, key: "status", value: builder.searchCriteriaBuilder.transactionStatus?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "from_time_created", value: (builder.startDate ?? Date()).format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "to_time_created", value: builder.endDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "country", value: builder.searchCriteriaBuilder.country)
                    addQueryStringParam(params: &queryStringParams, key: "batch_id", value: builder.searchCriteriaBuilder.batchId)
                    addQueryStringParam(params: &queryStringParams, key: "entry_mode", value: builder.searchCriteriaBuilder.paymentEntryMode?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "name", value: builder.searchCriteriaBuilder.name)
                }
                else if builder.reportType == .findSettlementTransactions {
                    reportUrl = Endpoints.settlementTransactions()

                    if let page = builder.page {
                        addQueryStringParam(params: &queryStringParams, key: "page", value: "\(page)")
                    }
                    if let pageSize = builder.pageSize {
                        addQueryStringParam(params: &queryStringParams, key: "page_size", value: "\(pageSize)")
                    }
                    addQueryStringParam(params: &queryStringParams, key: "order_by", value: builder.transactionOrderBy?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "order", value: builder.transactionOrder?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "number_first6", value: builder.searchCriteriaBuilder.cardNumberFirstSix)
                    addQueryStringParam(params: &queryStringParams, key: "number_last4", value: builder.searchCriteriaBuilder.cardNumberLastFour)
                    addQueryStringParam(params: &queryStringParams, key: "deposit_status", value: builder.searchCriteriaBuilder.depositStatus?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "account_name", value: self?.dataAccountName)
                    addQueryStringParam(params: &queryStringParams, key: "brand", value: builder.searchCriteriaBuilder.cardBrand)
                    addQueryStringParam(params: &queryStringParams, key: "arn", value: builder.searchCriteriaBuilder.aquirerReferenceNumber)
                    addQueryStringParam(params: &queryStringParams, key: "brand_reference", value: builder.searchCriteriaBuilder.brandReference)
                    addQueryStringParam(params: &queryStringParams, key: "authcode", value: builder.searchCriteriaBuilder.authCode)
                    addQueryStringParam(params: &queryStringParams, key: "reference", value: builder.searchCriteriaBuilder.referenceNumber)
                    addQueryStringParam(params: &queryStringParams, key: "status", value: builder.searchCriteriaBuilder.transactionStatus?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "from_time_created", value: (builder.startDate ?? Date()).format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "to_time_created", value: builder.endDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "deposit_id", value: builder.searchCriteriaBuilder.depositReference)
                    addQueryStringParam(params: &queryStringParams, key: "from_deposit_time_created", value: builder.searchCriteriaBuilder.startDepositDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "to_deposit_time_created", value: builder.searchCriteriaBuilder.endDepositDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "from_batch_time_created", value: builder.searchCriteriaBuilder.startBatchDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "to_batch_time_created", value: builder.searchCriteriaBuilder.endBatchDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "system.mid", value: builder.searchCriteriaBuilder.merchantId)
                    addQueryStringParam(params: &queryStringParams, key: "system.hierarchy", value: builder.searchCriteriaBuilder.systemHierarchy)
                }
                else if builder.reportType == .findDeposits {
                    reportUrl = Endpoints.deposits()

                    addQueryStringParam(params: &queryStringParams, key: "account_name", value: self?.dataAccountName)
                    if let page = builder.page {
                        addQueryStringParam(params: &queryStringParams, key: "page", value: "\(page)")
                    }
                    if let pageSize = builder.pageSize {
                        addQueryStringParam(params: &queryStringParams, key: "page_size", value: "\(pageSize)")
                    }
                    addQueryStringParam(params: &queryStringParams, key: "status", value: builder.depositStatus?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "order_by", value: builder.depositOrderBy?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "order", value: builder.depositOrder?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "from_time_created", value: (builder.startDate ?? Date()).format("yyyy-MM-dd"))
                }
                else if builder.reportType == .depositDetail,
                          let depositId = builder.searchCriteriaBuilder.depositReference {
                    reportUrl = Endpoints.deposit(id: depositId)
                }
                else if builder.reportType == .findDisputes {

                    reportUrl = Endpoints.disputes()

                    if let page = builder.page {
                        addQueryStringParam(params: &queryStringParams, key: "page", value: "\(page)")
                    }
                    if let pageSize = builder.pageSize {
                        addQueryStringParam(params: &queryStringParams, key: "page_size", value: "\(pageSize)")
                    }
                    addQueryStringParam(params: &queryStringParams, key: "order_by", value: builder.disputeOrderBy?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "order", value: builder.disputeOrder?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "arn", value: builder.searchCriteriaBuilder.aquirerReferenceNumber)
                    addQueryStringParam(params: &queryStringParams, key: "brand", value: builder.searchCriteriaBuilder.cardBrand)
                    addQueryStringParam(params: &queryStringParams, key: "status", value: builder.searchCriteriaBuilder.disputeStatus?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "stage", value: builder.searchCriteriaBuilder.disputeStage?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "from_stage_time_created", value: (builder.searchCriteriaBuilder.startStageDate ?? Date()).format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "to_stage_time_created", value: builder.searchCriteriaBuilder.endStageDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "adjustment_funding", value: builder.searchCriteriaBuilder.adjustmentFunding?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "from_adjustment_time_created", value: builder.searchCriteriaBuilder.startAdjustmentDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "to_adjustment_time_created", value: builder.searchCriteriaBuilder.endAdjustmentDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "system.mid", value: builder.searchCriteriaBuilder.merchantId)
                    addQueryStringParam(params: &queryStringParams, key: "system.hierarchy", value: builder.searchCriteriaBuilder.systemHierarchy)
                }
                else if builder.reportType == .findSettlementDisputes {
                    reportUrl = Endpoints.settlementDisputes()

                    if let page = builder.page {
                        addQueryStringParam(params: &queryStringParams, key: "page", value: "\(page)")
                    }
                    if let pageSize = builder.pageSize {
                        addQueryStringParam(params: &queryStringParams, key: "page_size", value: "\(pageSize)")
                    }
                    addQueryStringParam(params: &queryStringParams, key: "order_by", value: builder.disputeOrderBy?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "order", value: builder.disputeOrder?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "arn", value: builder.searchCriteriaBuilder.aquirerReferenceNumber)
                    addQueryStringParam(params: &queryStringParams, key: "brand", value: builder.searchCriteriaBuilder.cardBrand)
                    addQueryStringParam(params: &queryStringParams, key: "STATUS", value: builder.searchCriteriaBuilder.disputeStatus?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "stage", value: builder.searchCriteriaBuilder.disputeStage?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "from_stage_time_created", value: (builder.searchCriteriaBuilder.startStageDate ?? Date()).format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "to_stage_time_created", value: builder.searchCriteriaBuilder.endStageDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "adjustment_funding", value: builder.searchCriteriaBuilder.adjustmentFunding?.mapped(for: .gpApi))
                    addQueryStringParam(params: &queryStringParams, key: "from_adjustment_time_created", value: builder.searchCriteriaBuilder.startAdjustmentDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "to_adjustment_time_created", value: builder.searchCriteriaBuilder.endAdjustmentDate?.format("yyyy-MM-dd"))
                    addQueryStringParam(params: &queryStringParams, key: "system.mid", value: builder.searchCriteriaBuilder.merchantId)
                    addQueryStringParam(params: &queryStringParams, key: "system.hierarchy", value: builder.searchCriteriaBuilder.systemHierarchy)
                    addQueryStringParam(params: &queryStringParams, key: "account_name", value: self?.dataAccountName)
                }
                else if builder.reportType == .disputeDetail,
                         let disputeId = builder.searchCriteriaBuilder.disputeReference {
                   reportUrl = Endpoints.dispute(id: disputeId)
               }
                else if builder.reportType == .settlementDisputeDetail,
                        let settlementDisputeId = builder.searchCriteriaBuilder.settlementDisputeId {
                    addQueryStringParam(params: &queryStringParams, key: "account_name", value: self?.dataAccountName)
                    reportUrl = Endpoints.settlementDispute(id: settlementDisputeId)
                }
                else if builder.reportType == .acceptDispute,
                        let disputeId = builder.searchCriteriaBuilder.disputeReference {
                    reportUrl = Endpoints.acceptDispute(id: disputeId)
                    method = .post
                }
                else if builder.reportType == .challangeDispute,
                        let disputeId = builder.searchCriteriaBuilder.disputeReference,
                        let documents = builder.disputeDocuments,
                        let data = try? ["documents": documents].asString() {

                    self?.doTransaction(
                        method: .post,
                        endpoint: Endpoints.challengeDispute(id: disputeId),
                        data: data,
                        idempotencyKey: nil) { [weak self] response, error in
                        if let error = error {
                            completion?(nil, error)
                            return
                        }
                        guard let response = response else {
                            completion?(nil, error)
                            return
                        }

                        completion?(self?.mapReportResponse(response, builder.reportType), nil)
                        return
                    }
                    return
                }
                else if builder.reportType == .disputeDocument,
                        let disputeId = builder.searchCriteriaBuilder.disputeReference,
                        let documentId = builder.searchCriteriaBuilder.disputeDocumentReference {
                    reportUrl = Endpoints.document(id: documentId, disputeId: disputeId)
                }
            }

            self?.doTransaction(
                method: method,
                endpoint: reportUrl,
                idempotencyKey: nil,
                queryStringParams: queryStringParams) { [weak self] response, error in
                if let error = error {
                    completion?(nil, error)
                    return
                }
                guard let response = response else {
                    completion?(nil, error)
                    return
                }

                completion?(self?.mapReportResponse(response, builder.reportType), nil)
            }
        }
    }

    private func mapReportResponse<T>(_ rawResponse: String, _ reportType: ReportType) -> T? {
        var result: Any?
        let json = JsonDoc.parse(rawResponse)

        if reportType == .transactionDetail && TransactionSummary() is T {
            result = GpApiMapping.mapTransactionSummary(json)
        } else if reportType == .findTransactions && [TransactionSummary]() is T {
            if let transactions: [JsonDoc] = json?.getValue(key: "transactions") {
                let mapped = transactions.map { GpApiMapping.mapTransactionSummary($0) }
                result = mapped
            }
        } else if reportType == .findSettlementTransactions && [TransactionSummary]() is T {
            if let transactions: [JsonDoc] = json?.getValue(key: "transactions") {
                let mapped = transactions.map { GpApiMapping.mapTransactionSummary($0) }
                result = mapped
            }
        } else if reportType == .depositDetail && DepositSummary() is T {
            result = GpApiMapping.mapDepositSummary(json)
        } else if reportType == .findDeposits && [DepositSummary]() is T {
            if let deposits: [JsonDoc] = json?.getValue(key: "deposits") {
                let mapped = deposits.map { GpApiMapping.mapDepositSummary($0) }
                result = mapped
            }
        } else if (reportType == .disputeDetail || reportType == .settlementDisputeDetail) && DisputeSummary() is T {
            result = GpApiMapping.mapDisputeSummary(json)
        } else if (reportType == .findDisputes || reportType == .findSettlementDisputes) && [DisputeSummary]() is T {
            if let disputes: [JsonDoc] = json?.getValue(key: "disputes") {
                let mapped = disputes.map { GpApiMapping.mapDisputeSummary($0) }
                result = mapped
            }
        } else if reportType == .acceptDispute || reportType == .challangeDispute {
            result = GpApiMapping.mapDisputeAction(json)
        } else if reportType == .disputeDocument {
            result = GpApiMapping.mapDocumentMetadata(json)
        }

        return result as? T
    }
}
