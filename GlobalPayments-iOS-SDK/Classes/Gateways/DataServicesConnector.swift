import Foundation

class DataServicesConnector: RestGateway, ReportingService {

    var clientId: String? {
        didSet(newValue) {
            headers["x-ibm-client-id"] = newValue
        }
    }

    var clientSecret: String? {
        didSet(newValue) {
            headers["x-ibm-client-secret"] = newValue
        }
    }

    var userId: String?

    override init() {
        super.init()
        headers["accept"] = "application/json"
        headers["reporting_type"] = ""
        timeout = 30
    }

    // MARK: - ReportingService

    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?, Error?) -> Void)?) {
        let request = JsonDoc()
        let requestId = "10004"
        let reportType = mapReportType(builder.reportType)
        if let transactionBuilder = builder as? TransactionReportBuilder<T> {
            request.set(for: "requestId", value: requestId)
            request.set(for: "transactionId", value: transactionBuilder.transactionId)
            request.set(for: "userId", value: userId)
            request.set(for: "reportType", value: reportType)
            request.set(for: "startDepositDate", value: transactionBuilder.searchCriteriaBuilder.startDepositDate?.format("dd/MM/yyyy"))
            request.set(for: "endDepositDate", value: transactionBuilder.searchCriteriaBuilder.endDepositDate?.format("dd/MM/yyyy"))
            request.set(for: "mId", value: transactionBuilder.searchCriteriaBuilder.merchantId)
            request.set(for: "hierarchy", value: transactionBuilder.searchCriteriaBuilder.hierarchy)
            request.set(for: "timezone", value: transactionBuilder.searchCriteriaBuilder.timezone)
            request.set(for: "depositReference", value: transactionBuilder.searchCriteriaBuilder.depositReference)
            request.set(for: "orderId", value: transactionBuilder.searchCriteriaBuilder.orderId)
            request.set(for: "cardNumber", value: "\(transactionBuilder.searchCriteriaBuilder.cardNumberFirstSix ?? .empty)\(transactionBuilder.searchCriteriaBuilder.cardNumberLastFour ?? .empty)")
            request.set(for: "startTransactionLocalTime", value: transactionBuilder.searchCriteriaBuilder.localTransactionStartTime?.format("dd/MM/yyyy hh:mm:ss"))
            request.set(for: "endTransactionLocalTime", value: transactionBuilder.searchCriteriaBuilder.localTransactionEndTime?.format("dd/MM/yyyy hh:mm:ss"))
            request.set(for: "paymentAmoun t", value: transactionBuilder.searchCriteriaBuilder.amount?.toNumericCurrencyString())
            request.set(for: "bankAccountNumber", value: transactionBuilder.searchCriteriaBuilder.bankAccountNumber)
            request.set(for: "caseNumber", value: transactionBuilder.searchCriteriaBuilder.caseNumber)
            request.set(for: "caseId", value: transactionBuilder.searchCriteriaBuilder.caseId)
        }
        headers["reporting_type"] = reportType

        doTransaction(method: .post,
                      endpoint: reportType + "/",
                      data: request.toString()) { [weak self] response, error in
                        if let error = error {
                            completion?(nil, error)
                            return
                        }
                        completion?(self?.mapResponse(
                            response: response,
                            reportType: builder.reportType
                            ), nil
                        )
        }
    }

    private func mapResponse<T>(response: String?,
                                reportType: ReportType) -> T? {
        guard let response = response,
            let doc = JsonDoc.parse(response) else { return nil }

        if doc.has(key: "error") {
            let error = doc.get(valueFor: "error")
            let errorType: String? = error?.getValue(key: "errorType")
            let errorCode: String? = error?.getValue(key: "errorCode")
            let errorMessage: String? = error?.getValue(key: "errorMessage")
            // If it's 1205, then it's no data... which is not an error
            if errorCode != "1205" {
                return GatewayException.generic(
                    responseCode: Int(errorCode ?? .empty) ?? .zero,
                    responseMessage: "\(errorMessage ?? .empty) \(errorType ?? .empty)") as? T
            }
        }

        var rValue: T?
        if reportType.contains(.findTransactions) {
            if rValue is [TransactionSummary]? {
                var list = [TransactionSummary]()
                if doc.has(key: "merchantTransactionDetails"),
                    let details = doc.getEnumerator(key: "merchantTransactionDetails") {
                    for transaction in details {
                        list.append(hydrateTransactionSummary(transaction))
                    }
                }
                rValue = list as? T
            }
        } else if reportType.contains(.findDeposits) {
            if rValue is [DepositSummary]? {
                var list = [DepositSummary]()
                if doc.has(key: "merchantDepositDetails"),
                    let details = doc.getEnumerator(key: "merchantDepositDetails") {
                    for deposit in details {
                        list.append(hydrateDepositSummary(deposit))
                    }
                }
                rValue = list as? T
            }
        } else if reportType.contains(.findDisputes) {
            if rValue is [DisputeSummary]? {
                var list = [DisputeSummary]()
                if doc.has(key: "merchantDisputeDetails"),
                    let details = doc.getEnumerator(key: "merchantDisputeDetails") {
                    for dispute in details {
                        list.append(hydrateDisputeSummary(dispute))
                    }
                }
                rValue = list as? T
            }
        }

        return rValue
    }

    override func handleResponse(response: GatewayResponse?,
                                 error: Error?,
                                 completion: @escaping (String?, Error?) -> Void) {
        guard let response = response else {
            completion(nil, error)
            return
        }
        if response.statusCode != 200 {
            let message = JsonDoc.parseSingleValue(response.rawResponse, "moreInformation") as? JsonDoc
            completion(nil, GatewayException.generic(
                responseCode: response.statusCode,
                responseMessage: message?.toString() ?? .empty
                )
            )
            return
        }
        completion(response.rawResponse, nil)
    }

    private func mapReportType(_ type: ReportType) -> String {
        switch type {
        case .findTransactions: return "transaction"
        case .findDeposits: return "deposit"
        case .findDisputes: return "dispute"
        default: return .empty
        }
    }

    private func formatDate(_ date: String?) -> Date? {
        guard let stringDate = date else { return nil }
        var pattern = "yyyy-MM-dd"
        if stringDate.contains(" ") {
            pattern += " hh:mm:ss"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern

        return dateFormatter.date(from: stringDate)
    }

    private func hydrateTransactionSummary(_ root: JsonDoc) -> TransactionSummary {
        let summary = TransactionSummary()
        summary.merchantHierarchy = root.getValue(key: "merchantHierarchy")
        summary.merchantName = root.getValue(key: "merchantName")
        summary.merchantDbaName = root.getValue(key: "merchantDbaName")
        summary.merchantNumber = root.getValue(key: "merchantNumber")
        summary.merchantCategory = root.getValue(key: "merchantCategory")
        summary.depositDate = formatDate(root.getValue(key: "transactionDepositDate"))
        summary.depositReference = root.getValue(key: "transactionDepositReference")
        summary.depositType = root.getValue(key: "transactionDepositType")
        summary.serviceName = root.getValue(key: "transactionType")
        summary.orderId = root.getValue(key: "transactionOrderId")
        summary.transactionLocalDate = formatDate(root.getValue(key: "transactionLocalTime"))
        summary.transactionDate = formatDate(root.getValue(key: "transactionTime"))
        let amount: NSDecimalNumber? = root.getValue(key: "transactionAmount")
        summary.amount = amount?.amount
        summary.currency = root.getValue(key: "transactionCurrency")
        let depositAmount: NSDecimalNumber? = root.getValue(key: "transactionMerchantAmount")
        summary.depositAmount = depositAmount?.amount
        summary.depositCurrency = root.getValue(key: "transactionMerchantCurrency")
        summary.merchantId = root.getValue(key: "transactionMid")
        summary.terminalId = root.getValue(key: "transactionTid")
        summary.batchSequenceNumber = root.getValue(key: "transactionBatchReference")
        summary.entryMode = root.getValue(key: "transactionEntryMode")
        summary.aquirerReferenceNumber = root.getValue(key: "transactionArn")
        summary.referenceNumber = root.getValue(key: "transactionReferenceNumber")
        summary.cardType = root.getValue(key: "transactionCardType")
        summary.maskedCardNumber = root.getValue(key: "transactionCardNo")
        summary.authCode = root.getValue(key: "transactionAuthcode")
        summary.schemeReferenceData = root.getValue(key: "transactionSrd")
        let adjustmentAmount: NSDecimalNumber? = root.getValue(key: "transactionAdjustAmount")
        summary.adjustmentAmount = adjustmentAmount?.amount
        summary.adjustmentCurrency = root.getValue(key: "transactionAdjustCurrency")
        summary.adjustmentReason = root.getValue(key: "transactionAdjustReason")
        return summary
    }

    private func hydrateDepositSummary(_ root: JsonDoc) -> DepositSummary {
        let summary = DepositSummary()
        summary.merchantHierarchy = root.getValue(key: "merchantHierarchy")
        summary.merchantName = root.getValue(key: "merchantName")
        summary.merchantDbaName = root.getValue(key: "merchantDba")
        summary.merchantNumber = root.getValue(key: "merchantNumber")
        summary.merchantCategory = root.getValue(key: "merchantCategory")
        summary.depositDate = formatDate(root.getValue(key: "depositDate"))
        summary.reference = root.getValue(key: "depositReference")
        let amount: NSDecimalNumber? = root.getValue(key: "depositPaymentAmount")
        summary.amount = amount?.amount
        summary.currency = root.getValue(key: "depositPaymentCurrency")
        summary.type = root.getValue(key: "depositType")
        summary.routingNumber = root.getValue(key: "depositRoutingNumber")
        summary.accountNumber = root.getValue(key: "depositAccountNumber")
        summary.mode = root.getValue(key: "depositMode")
        summary.summaryModel = root.getValue(key: "depositSummaryModel")
        summary.salesTotalCount = root.getValue(key: "salesTotalNo")
        let salesTotalAmount: NSDecimalNumber? = root.getValue(key: "salesTotalAmount")
        summary.salesTotalAmount = salesTotalAmount?.amount
        summary.salesTotalCurrency = root.getValue(key: "salesTotalCurrency")
        summary.refundsTotalCount = root.getValue(key: "refundsTotalNo")
        let refundsTotalAmount: NSDecimalNumber? = root.getValue(key: "refundsTotalAmount")
        summary.refundsTotalAmount = refundsTotalAmount?.amount
        summary.refundsTotalCurrency = root.getValue(key: "refundsTotalCurrency")
        summary.chargebackTotalCount = root.getValue(key: "disputeCbTotalNo")
        let chargebackTotalAmount: NSDecimalNumber? = root.getValue(key: "disputeCbTotalAmount")
        summary.chargebackTotalAmount = chargebackTotalAmount?.amount
        summary.chargebackTotalCurrency = root.getValue(key: "disputeCbTotalCurrency")
        summary.representmentTotalCount = root.getValue(key: "disputeRepresentmentTotalNo")
        let representmentTotalAmount: NSDecimalNumber? = root.getValue(key: "disputeRepresentmentTotalAmount")
        summary.representmentTotalAmount = representmentTotalAmount?.amount
        summary.representmentTotalCurrency = root.getValue(key: "disputeRepresentmentTotalCurrency")
        let feesTotalAmount: NSDecimalNumber? = root.getValue(key: "feesTotalAmount")
        summary.feesTotalAmount = feesTotalAmount?.amount
        summary.feesTotalCurrency = root.getValue(key: "feesTotalCurrency")
        summary.adjustmentTotalCount = root.getValue(key: "adjustmentTotalNumber")
        let adjustmentTotalAmount: NSDecimalNumber? = root.getValue(key: "adjustmentTotalAmount")
        summary.adjustmentTotalAmount = adjustmentTotalAmount?.amount
        summary.adjustmentTotalCurrency = root.getValue(key: "adjustmentTotalCurrency")
        return summary
    }

    private func hydrateDisputeSummary(_ root: JsonDoc) -> DisputeSummary {
        let summary = DisputeSummary()
        summary.merchantHierarchy = root.getValue(key: "merchantHierarchy")
        summary.merchantName = root.getValue(key: "merchantName")
        summary.merchantDbaName = root.getValue(key: "merchantDba")
        summary.merchantNumber = root.getValue(key: "merchantNumber")
        summary.merchantCategory = root.getValue(key: "merchantCategory")
        summary.depositDate = root.getValue(key: "disputeDepositDate")
        summary.depositReference = root.getValue(key: "disputeDepositReference")
        summary.depositType = root.getValue(key: "disputeDepositType")
        summary.type = root.getValue(key: "disputeType")
        let caseAmount: NSDecimalNumber? = root.getValue(key: "disputeCaseAmount")
        summary.caseAmount = caseAmount?.amount
        summary.caseCurrency = root.getValue(key: "disputeCaseCurrency")
        summary.caseStatus = root.getValue(key: "disputeCaseStatus")
        summary.caseDescription = root.getValue(key: "disputeCaseDescription")
        summary.transactionOrderId = root.getValue(key: "disputeTransactionOrderId")
        summary.transactionLocalTime = root.getValue(key: "disputeTransactionLocalTime")
        summary.transactionTime = root.getValue(key: "disputeTransactionTime")
        summary.transactionType = root.getValue(key: "disputeTransactionType")
        let transactionAmount: NSDecimalNumber? = root.getValue(key: "disputeTransactionAmount")
        summary.transactionAmount = transactionAmount?.amount
        summary.transactionCurrency = root.getValue(key: "disputeTransactionCurrency")
        summary.caseNumber = root.getValue(key: "disputeCaseNo")
        summary.caseTime = formatDate(root.getValue(key: "disputeCaseTime"))
        summary.caseId = root.getValue(key: "disputeCaseId")
        summary.caseIdTime = formatDate(root.getValue(key: "disputeCaseIdTime"))
        summary.caseMerchantId = root.getValue(key: "disputeCaseMid")
        summary.caseTerminalId = root.getValue(key: "disputeCaseTid")
        summary.transactionARN = root.getValue(key: "disputeTransactionARN")
        summary.transactionReferenceNumber = root.getValue(key: "disputeTransactionReferenceNumber")
        summary.transactionSRD = root.getValue(key: "disputeTransactionSRD")
        summary.transactionAuthCode = root.getValue(key: "disputeTransactionAuthcode")
        summary.transactionCardType = root.getValue(key: "disputeTransactionCardType")
        summary.transactionMaskedCardNumber = root.getValue(key: "disputeTransactionCardNo")
        summary.reason = root.getValue(key: "disputeReason")
        summary.issuerComment = root.getValue(key: "disputeIssuerComment")
        summary.issuerCaseNumber = root.getValue(key: "disputeIssuerCaseNo")
        let disputeAmount: NSDecimalNumber? = root.getValue(key: "disputeAmount")
        summary.disputeAmount = disputeAmount?.amount
        summary.disputeCurrency = root.getValue(key: "disputeCurrency")
        let disputeCustomerAmount: NSDecimalNumber? = root.getValue(key: "disputeCustomerAmount")
        summary.disputeCustomerAmount = disputeCustomerAmount?.amount
        summary.disputeCustomerCurrency = root.getValue(key: "disputeCustomerCurrency")
        summary.respondByDate = formatDate(root.getValue(key: "disputeRespondByDate"))
        summary.caseOriginalReference = root.getValue(key: "disputeCaseOriginalReference")
        return summary
    }
}
