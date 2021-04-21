import Foundation

struct GpApiReportRequestBuilder<T>: GpApiRequestData {

    func generateRequest(for builder: TransactionReportBuilder<T>, config: GpApiConfig?) -> GpApiRequest? {
        switch builder.reportType {
        case .transactionDetail:
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactionsWith(transactionId: builder.transactionId ?? .empty),
                method: .get
            )
        case .findTransactionsPaged:
            var params = [String: String]()
            addPageParams(&params, builder)
            addTransactionParams(&params, builder)
            params["id"] = builder.transactionId
            params["type"] = builder.searchCriteriaBuilder.paymentType?.mapped(for: .gpApi)
            params["channel"] = builder.searchCriteriaBuilder.channel?.mapped(for: .gpApi)
            params["amount"] = builder.searchCriteriaBuilder.amount?.toNumericCurrencyString()
            params["currency"] = builder.searchCriteriaBuilder.currency
            params["token_first6"] = builder.searchCriteriaBuilder.tokenFirstSix
            params["token_last4"] = builder.searchCriteriaBuilder.tokenLastFour
            params["account_name"] = builder.searchCriteriaBuilder.accountName
            params["country"] = builder.searchCriteriaBuilder.country
            params["batch_id"] = builder.searchCriteriaBuilder.batchId
            params["entry_mode"] = builder.searchCriteriaBuilder.paymentEntryMode?.mapped(for: .gpApi)
            params["name"] = builder.searchCriteriaBuilder.name
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactions(),
                method: .get,
                queryParams: sanitize(params: params)
            )
        case .findSettlementTransactionsPaged:
            var params = [String: String]()
            addPageParams(&params, builder)
            addTransactionParams(&params, builder)
            params["deposit_status"] = builder.searchCriteriaBuilder.depositStatus?.mapped(for: .gpApi)
            params["account_name"] = config?.accessTokenInfo?.dataAccountName
            params["arn"] = builder.searchCriteriaBuilder.aquirerReferenceNumber
            params["deposit_id"] = builder.searchCriteriaBuilder.depositReference
            params["from_deposit_time_created"] = builder.searchCriteriaBuilder.startDepositDate?.format("yyyy-MM-dd")
            params["to_deposit_time_created"] = builder.searchCriteriaBuilder.endDepositDate?.format("yyyy-MM-dd")
            params["from_batch_time_created"] = builder.searchCriteriaBuilder.startBatchDate?.format("yyyy-MM-dd")
            params["to_batch_time_created"] = builder.searchCriteriaBuilder.endBatchDate?.format("yyyy-MM-dd")
            params["system.mid"] = builder.searchCriteriaBuilder.merchantId
            params["system.hierarchy"] = builder.searchCriteriaBuilder.systemHierarchy
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.settlementTransactions(),
                method: .get,
                queryParams: sanitize(params: params)
            )
        case .findDepositsPaged:
            var params = [String: String]()
            addPageParams(&params, builder)
            params["order_by"] = builder.depositOrderBy?.mapped(for: .gpApi)
            params["order"] = builder.depositOrder?.mapped(for: .gpApi)
            params["account_name"] = config?.accessTokenInfo?.dataAccountName
            params["from_time_created"] = builder.startDate?.format("yyyy-MM-dd")
            params["to_time_created"] = builder.endDate?.format("yyyy-MM-dd")
            params["id"] = builder.searchCriteriaBuilder.depositReference
            params["status"] = builder.depositStatus?.mapped(for: .gpApi)
            params["amount"] = builder.searchCriteriaBuilder.amount?.toNumericCurrencyString()
            params["masked_account_number_last4"] = builder.searchCriteriaBuilder.accountNumberLastFour
            params["system.mid"] = builder.searchCriteriaBuilder.merchantId
            params["system.hierarchy"] = builder.searchCriteriaBuilder.systemHierarchy
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.deposits(),
                method: .get,
                queryParams: sanitize(params: params)
            )
        case .depositDetail:
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.deposit(id: builder.searchCriteriaBuilder.depositReference ?? .empty),
                method: .get
            )
        case .findDisputesPaged:
            var params = [String: String]()
            addPageParams(&params, builder)
            addDisputesParams(&params, builder)
            params["status"] = builder.searchCriteriaBuilder.disputeStatus?.mapped(for: .gpApi)
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.disputes(),
                method: .get,
                queryParams: sanitize(params: params)
            )
        case .findSettlementDisputesPaged:
            var params = [String: String]()
            addPageParams(&params, builder)
            addDisputesParams(&params, builder)
            params["STATUS"] = builder.searchCriteriaBuilder.disputeStatus?.mapped(for: .gpApi)
            params["account_name"] = config?.accessTokenInfo?.dataAccountName
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.settlementDisputes(),
                method: .get,
                queryParams: sanitize(params: params)
            )
        case .disputeDetail:
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.dispute(id: builder.searchCriteriaBuilder.disputeReference ?? .empty),
                method: .get
            )
        case .settlementDisputeDetail:
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.settlementDispute(id: builder.searchCriteriaBuilder.settlementDisputeId ?? .empty),
                method: .get
            )
        case .acceptDispute:
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.acceptDispute(id: builder.searchCriteriaBuilder.disputeReference ?? .empty),
                method: .post
            )
        case .challangeDispute:
            let data = try? ["documents": builder.disputeDocuments].asString()
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.challengeDispute(id: builder.searchCriteriaBuilder.disputeReference ?? .empty),
                method: .post,
                requestBody: data
            )
        case .disputeDocument:
            let disputeId = builder.searchCriteriaBuilder.disputeReference ?? .empty
            let documentId = builder.searchCriteriaBuilder.disputeDocumentReference ?? .empty
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.document(id: documentId, disputeId: disputeId),
                method: .get
            )
        default:
            return nil
        }
    }

    private func addPageParams(_ params: inout [String: String], _ builder: TransactionReportBuilder<T>) {
        if let page = builder.page {
            params["page"] = "\(page)"
        }
        if let pageSize = builder.pageSize {
            params["page_size"] = "\(pageSize)"
        }
    }

    private func addTransactionParams(_ params: inout [String: String], _ builder: TransactionReportBuilder<T>) {
        params["order_by"] = builder.transactionOrderBy?.mapped(for: .gpApi)
        params["order"] = builder.transactionOrder?.mapped(for: .gpApi)
        params["number_first6"] = builder.searchCriteriaBuilder.cardNumberFirstSix
        params["number_last4"] = builder.searchCriteriaBuilder.cardNumberLastFour
        params["brand"] = builder.searchCriteriaBuilder.cardBrand
        params["brand_reference"] = builder.searchCriteriaBuilder.brandReference
        params["authcode"] = builder.searchCriteriaBuilder.authCode
        params["reference"] = builder.searchCriteriaBuilder.referenceNumber
        params["status"] = builder.searchCriteriaBuilder.transactionStatus?.mapped(for: .gpApi)
        params["from_time_created"] = builder.startDate?.format("yyyy-MM-dd")
        params["to_time_created"] = builder.endDate?.format("yyyy-MM-dd")
    }

    private func addDisputesParams(_ params: inout [String: String], _ builder: TransactionReportBuilder<T>) {
        params["order_by"] = builder.disputeOrderBy?.mapped(for: .gpApi)
        params["order"] = builder.disputeOrder?.mapped(for: .gpApi)
        params["arn"] = builder.searchCriteriaBuilder.aquirerReferenceNumber
        params["brand"] = builder.searchCriteriaBuilder.cardBrand
        params["stage"] = builder.searchCriteriaBuilder.disputeStage?.mapped(for: .gpApi)
        params["from_stage_time_created"] = builder.searchCriteriaBuilder.startStageDate?.format("yyyy-MM-dd")
        params["to_stage_time_created"] = builder.searchCriteriaBuilder.endStageDate?.format("yyyy-MM-dd")
        params["system.mid"] = builder.searchCriteriaBuilder.merchantId
        params["system.hierarchy"] = builder.searchCriteriaBuilder.systemHierarchy
    }

    private func sanitize(params: [String: String]) -> [String: String] {
        params.filter { !$0.value.isEmpty }
    }
}
