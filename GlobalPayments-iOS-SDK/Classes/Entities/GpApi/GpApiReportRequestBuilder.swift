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

            params["risk_assessment_mode"] = builder.searchCriteriaBuilder.riskAssessmentMode?.rawValue
            params["risk_assessment_result"] = builder.searchCriteriaBuilder.riskAssessmentResult?.rawValue
            params["risk_assessment_reason_code"] = builder.searchCriteriaBuilder.riskAssessmentReasonCode?.rawValue

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
            params["order"] = builder.order?.mapped(for: .gpApi)
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
            params["deposit_id"] = builder.searchCriteriaBuilder.depositReference
            params["from_deposit_time_created"] = builder.searchCriteriaBuilder.startDepositDate?.format("yyyy-MM-dd")
            params["to_deposit_time_created"] = builder.searchCriteriaBuilder.endDepositDate?.format("yyyy-MM-dd")
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
        case .storedPaymentMethodDetail:
            let paymentMethodId = builder.searchCriteriaBuilder.storedPaymentMethodId ?? .empty
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.paymentMethodsWith(paymentMethodId: paymentMethodId),
                method: .get
            )
        case .findStoredPaymentMethodsPaged:

            if let creditCard = builder.searchCriteriaBuilder.paymentMethod as? CreditCardData {
                let card = JsonDoc()
                card.set(for: "number", value: creditCard.number)
                card.set(for: "expiry_month", value: String(creditCard.expMonth))
                card.set(for: "expiry_year", value: String(creditCard.expYear).suffix(2).description)

                let payload = JsonDoc()
                payload.set(for: "reference", value: builder.searchCriteriaBuilder.referenceNumber)
                payload.set(for: "card", doc: card)

                return GpApiRequest(
                    endpoint: GpApiRequest.Endpoints.paymentMethodsSearch(),
                    method: .post,
                    requestBody: payload.toString()
                )
            } else {
                var params = [String: String]()
                addPageParams(&params, builder)
                addPaymentsParams(&params, builder)
                return GpApiRequest(
                    endpoint: GpApiRequest.Endpoints.paymentMethods(),
                    method: .get,
                    queryParams: sanitize(params: params)
                )
            }
        case .actionDetail:
            let actionId = builder.searchCriteriaBuilder.actionId ?? .empty
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.action(id: actionId),
                method: .get
            )
        case .findActionsPaged:
            var params = [String: String]()
            addPageParams(&params, builder)
            addActionsParams(&params, builder)
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.actions(),
                method: .get,
                queryParams: sanitize(params: params)
            )
        case .documentDisputeDetail:
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
        params["order"] = builder.order?.mapped(for: .gpApi)
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
        params["order"] = builder.order?.mapped(for: .gpApi)
        params["arn"] = builder.searchCriteriaBuilder.aquirerReferenceNumber
        params["brand"] = builder.searchCriteriaBuilder.cardBrand
        params["stage"] = builder.searchCriteriaBuilder.disputeStage?.mapped(for: .gpApi)
        params["from_stage_time_created"] = builder.searchCriteriaBuilder.startStageDate?.format("yyyy-MM-dd")
        params["to_stage_time_created"] = builder.searchCriteriaBuilder.endStageDate?.format("yyyy-MM-dd")
        params["system.mid"] = builder.searchCriteriaBuilder.merchantId
        params["system.hierarchy"] = builder.searchCriteriaBuilder.systemHierarchy
    }

    private func addPaymentsParams(_ params: inout [String: String], _ builder: TransactionReportBuilder<T>) {
        params["order_by"] = builder.storedPaymentMethodOrderBy?.mapped(for: .gpApi)
        params["order"] = builder.order?.mapped(for: .gpApi)
        params["id"] = builder.searchCriteriaBuilder.storedPaymentMethodId
        params["number_last4"] = builder.searchCriteriaBuilder.cardNumberLastFour
        params["reference"] = builder.searchCriteriaBuilder.referenceNumber
        params["status"] = builder.searchCriteriaBuilder.storedPaymentMethodStatus?.mapped(for: .gpApi)
        params["from_time_created"] = builder.searchCriteriaBuilder.startDate?.format("yyyy-MM-dd")
        params["to_time_created"] = builder.searchCriteriaBuilder.endDate?.format("yyyy-MM-dd")
        params["from_time_last_updated"] = builder.searchCriteriaBuilder.startLastUpdatedDate?.format("yyyy-MM-dd")
        params["to_time_last_updated"] = builder.searchCriteriaBuilder.endLastUpdatedDate?.format("yyyy-MM-dd")
    }

    private func addActionsParams(_ params: inout [String: String], _ builder: TransactionReportBuilder<T>) {
        params["order_by"] = builder.actionOrderBy?.mapped(for: .gpApi)
        params["order"] = builder.order?.mapped(for: .gpApi)
        params["id"] = builder.searchCriteriaBuilder.actionId
        params["type"] = builder.searchCriteriaBuilder.actionType
        params["resource"] = builder.searchCriteriaBuilder.resource
        params["resource_status"] = builder.searchCriteriaBuilder.resourceStatus
        params["resource_id"] = builder.searchCriteriaBuilder.resourceId
        params["from_time_created"] = builder.searchCriteriaBuilder.startDate?.format("yyyy-MM-dd")
        params["to_time_created"] = builder.searchCriteriaBuilder.endDate?.format("yyyy-MM-dd")
        params["merchant_name"] = builder.searchCriteriaBuilder.merchantName
        params["account_name"] = builder.searchCriteriaBuilder.accountName
        params["app_name"] = builder.searchCriteriaBuilder.appName
        params["version"] = builder.searchCriteriaBuilder.version
        params["response_code"] = builder.searchCriteriaBuilder.responseCode
        params["http_response_code"] = builder.searchCriteriaBuilder.httpResponseCode
    }

    private func sanitize(params: [String: String]) -> [String: String] {
        params.filter { !$0.value.isEmpty }
    }
}
