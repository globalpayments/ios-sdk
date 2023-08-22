import Foundation

public struct GpApiMapping {
    
    static let DC_RESPONSE = "RATE_LOOKUP"
    
    public static func mapTransaction(_ doc: JsonDoc?) -> Transaction {
        
        let transaction = Transaction()
        transaction.transactionId = doc?.getValue(key: "id")
        if let amount: String = doc?.getValue(key: "amount") {
            transaction.balanceAmount = NSDecimalNumber(string: amount).amount
        }
        transaction.timestamp = doc?.getValue(key: "time_created")
        transaction.responseMessage = doc?.getValue(key: "status")
        transaction.referenceNumber = doc?.getValue(key: "reference")
        transaction.clientTransactionId = doc?.getValue(key: "reference")
        let batchSummary = BatchSummary()
        batchSummary.batchReference = doc?.getValue(keys: "batch_id", "id")
        batchSummary.status = doc?.getValue(key: "status")
        batchSummary.transactionCount = doc?.getValue(key: "transaction_count")
        if let amount: String = doc?.getValue(key: "amount") {
            batchSummary.totalAmount = NSDecimalNumber(string: amount).amount
            
            if transaction.responseMessage == TransactionStatus.preauthorized.rawValue {
                transaction.authorizedAmount = NSDecimalNumber(string: amount).amount
            }
        }
        transaction.batchSummary = batchSummary
        transaction.responseCode = doc?.get(valueFor: "action")?.getValue(key: "result_code")
        if let token: String = doc?.getValue(key: "id"), token.starts(with: "PMT_") {
            transaction.token = token
        }
        
        if let type: String = doc?.get(valueFor: "action")?.getValue(key: "type"), let actionType = ActionType(value: type) {
            switch actionType {
            case .linkCreate, .linkEdit:
                transaction.payLinkResponse = mapPayLinkResponse(doc)
                if let transactions: JsonDoc = doc?.getValue(key: "transactions"), let amount: String = transactions.getValue(key: "amount") {
                    transaction.balanceAmount = NSDecimalNumber(string: amount).amount
                }
                break
            }
        }
        
        if let paymentMethod: JsonDoc = doc?.get(valueFor: "payment_method") {
            
            if let fingerPrint: String = paymentMethod.getValue(key: "fingerprint") {
                transaction.fingerPrint = fingerPrint
            }
            
            if let fingerPrintIndicator: String = paymentMethod.getValue(key: "fingerprint_presence_indicator") {
                transaction.fingerPrintIndicator = fingerPrintIndicator
            }
            
            if paymentMethod.has(key: "bnpl") {
                transaction.paymentMethodType = .BPNL
                transaction.bnplResponse = mapBNPLResponse(paymentMethod)
                return transaction
            }
            
            transaction.authorizationCode = paymentMethod.getValue(key: "result")
            if let token: String = paymentMethod.getValue(key: "id") {
                transaction.token = token
            }
            
            if let card: JsonDoc = paymentMethod.get(valueFor: "card") {
                transaction.cardLast4 = card.getValue(key: "masked_number_last4")
                transaction.cardType = card.getValue(key: "brand")
                transaction.cardBrandTransactionId = card.getValue(key: "brand_reference")
                transaction.cvnResponseMessage = card.getValue(key: "cvv_result")
                transaction.avsResponseCode = card.getValue(key: "avs_postal_code_result") ?? .empty
                transaction.avsAddressResponse = card.getValue(key: "avs_address_result") ?? .empty
                transaction.avsResponseMessage = card.getValue(key: "avs_action") ?? .empty
                
                if let provider: JsonDoc = card.get(valueFor: "provider") {
                    transaction.cardIssuerResponse = mapCardIssuerResponse(provider)
                }
            }
            
            transaction.paymentMethodType = paymentMethod.has(key: "bank_transfer") ? .ach : transaction.paymentMethodType
            
            if paymentMethod.has(key: "apm") {
                transaction.alternativePaymentResponse = AlternativePaymentResponse.mapToObject(paymentMethod)
            }
            
            if let apm = paymentMethod.get(valueFor: "apm"), let provider: String = apm.getValue(key: "provider"), provider == PaymentProvider.OPEN_BANKING.rawValue  {
                transaction.bankPaymentResponse = BankPaymentResponse.mapToObject(paymentMethod)
            }
            
            if paymentMethod.has(key: "shipping_address") || paymentMethod.has(key: "payer") {
                let payerDetails = PayerDetails()
                let payerData: JsonDoc? = paymentMethod.getValue(key: "payer")
                payerDetails.email = payerData?.getValue(key: "email")
                if let billingAddress: JsonDoc = payerData?.get(valueFor: "billing_address") {
                    payerDetails.firstName = billingAddress.getValue(key: "first_name")
                    payerDetails.lastName = billingAddress.getValue(key: "last_name")
                    let billing = mapMerchantAddress(billingAddress)
                    billing.type = .billing
                    payerDetails.billingAddress = billing
                }
                
                let shipping = mapMerchantAddress(paymentMethod.get(valueFor: "shipping_address"))
                shipping.type = .shipping
                
                payerDetails.shippingAddress = shipping
                transaction.payerDetails = payerDetails
            }
        }
        
        if let riskAssessments: [JsonDoc] = doc?.getValue(key: "risk_assessment") {
            transaction.fraudResponse = FraudResponse.init(docs: riskAssessments)
        }
        
        if let usageMode: String = doc?.getValue(key: "usage_mode") {
            transaction.methodUsageMode = PaymentMethodUsageMode.init(value: usageMode)
        }
        
        if let card: JsonDoc = doc?.get(valueFor: "card") {
            let cardDetails = Card()
            cardDetails.cardExpMonth = Int(card.getValue(key: "expiry_month") ?? .empty)
            cardDetails.cardExpYear = Int(card.getValue(key: "expiry_year") ?? .empty)
            cardDetails.cardNumber = card.getValue(key: "number")
            cardDetails.brand = card.getValue(key: "brand")
            cardDetails.maskedNumberLast4 = card.getValue(key: "masked_number_last4")
            transaction.cardDetails = cardDetails
        }
        
        transaction.dccRateData = mapDccInfo(doc)
        
        return transaction
    }
    
    public static func mapTransactionSummary(_ doc: JsonDoc?) -> TransactionSummary {
        let paymentMethod: JsonDoc? = doc?.get(valueFor: "payment_method")
        let card: JsonDoc? = paymentMethod?.get(valueFor: "card")
        
        let summary = TransactionSummary()
        summary.transactionId = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.transactionDate = timeCreated?.format() ?? timeCreated?.format("yyyy-MM-dd'T'HH:mm:ss")
        summary.transactionStatus = TransactionStatus(value: doc?.getValue(key: "status"))
        summary.transactionType = doc?.getValue(key: "type")
        summary.channel = doc?.getValue(key: "channel")
        summary.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount
        summary.currency = doc?.getValue(key: "currency")
        summary.referenceNumber = doc?.getValue(key: "reference")
        summary.clientTransactionId = doc?.getValue(key: "reference")
        let timeCreatedReference: String? = doc?.getValue(key: "time_created_reference")
        summary.transactionLocalDate = timeCreatedReference?.format()
        summary.batchSequenceNumber = doc?.getValue(key: "batch_id")
        let batchTimeCreated: String? = doc?.getValue(key: "batch_time_created")
        summary.batchCloseDate = batchTimeCreated?.format()
        summary.country = doc?.getValue(key: "country")
        summary.originalTransactionId = doc?.getValue(key: "parent_resource_id")
        
        summary.gatewayResponseMessage = paymentMethod?.getValue(key: "message")
        summary.entryMode = paymentMethod?.getValue(key: "entry_mode")
        summary.cardHolderName = paymentMethod?.getValue(key: "name")
        
        summary.cardType = card?.getValue(key: "brand")
        summary.authCode = card?.getValue(key: "authcode")
        summary.brandReference = card?.getValue(key: "brand_reference")
        summary.aquirerReferenceNumber = card?.getValue(key: "arn")
        summary.maskedCardNumber = card?.getValue(key: "masked_number_first6last4")
        
        summary.depositReference = doc?.getValue(key: "deposit_id")
        let depositTimeCreated: String? = doc?.getValue(key: "deposit_time_created")
        summary.depositDate = depositTimeCreated?.format("YYYY-MM-dd")
        summary.depositStatus = DepositStatus(value: doc?.getValue(key: "deposit_status"))
        
        summary.merchantId = doc?.get(valueFor: "system")?.getValue(key: "mid")
        summary.merchantHierarchy = doc?.get(valueFor: "system")?.getValue(key: "hierarchy")
        summary.merchantName = doc?.get(valueFor: "system")?.getValue(key: "name")
        summary.merchantDbaName = doc?.get(valueFor: "system")?.getValue(key: "dba")
        
        if let paymentMethod = paymentMethod, paymentMethod.has(key: "apm") {
            summary.alternativePaymentResponse = AlternativePaymentResponse.mapToObject(paymentMethod)
        }
        
        if let paymentMethod = paymentMethod, let apm = paymentMethod.get(valueFor: "apm"), let provider: String = apm.getValue(key: "provider"), provider == PaymentProvider.OPEN_BANKING.rawValue  {
            summary.bankPaymentResponse = BankPaymentResponse.mapToObject(paymentMethod)
            summary.paymentType = PaymentMethodName.bankPayment.mapped(for: .gpApi)
        }
        
        if let paymentMethod = paymentMethod, paymentMethod.has(key: "bnpl") {
            let bnpl = paymentMethod.get(valueFor: "bnpl")
            let bnplResponse = BNPLResponse()
            bnplResponse.providerName = bnpl?.getValue(key: "provider")
            summary.bnplResponse = bnplResponse
            summary.paymentType = PaymentMethodName.bnpl.mapped(for: .gpApi)
        }
        
        return summary
    }
    
    public static func mapCardIssuerResponse(_ doc: JsonDoc) -> CardIssuerResponse {
        let cardIssuer = CardIssuerResponse()
        cardIssuer.result = doc.getValue(key: "result")
        cardIssuer.avsResult = doc.getValue(key: "avs_result")
        cardIssuer.cvvResult = doc.getValue(key: "cvv_result")
        cardIssuer.avsAddressResult = doc.getValue(key: "avs_address_result")
        cardIssuer.avsPostalCodeResult = doc.getValue(key: "avs_postal_code_result")
        return cardIssuer
    }
    
    public static func mapDepositSummary(_ doc: JsonDoc?) -> DepositSummary {
        let summary = DepositSummary()
        summary.depositId = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.depositDate = timeCreated?.format("yyyy-MM-dd")
        summary.status = doc?.getValue(key: "status")
        summary.type = doc?.getValue(key: "funding_type")
        summary.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount
        summary.currency = doc?.getValue(key: "currency")
        
        summary.merchantNumber = doc?.get(valueFor: "system")?.getValue(key: "mid")
        summary.merchantHierarchy = doc?.get(valueFor: "system")?.getValue(key: "hierarchy")
        summary.merchantName = doc?.get(valueFor: "system")?.getValue(key: "name")
        summary.merchantDbaName = doc?.get(valueFor: "system")?.getValue(key: "dba")
        
        summary.salesTotalCount = doc?.get(valueFor: "sales")?.getValue(key: "count")
        summary.salesTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "sales")?.getValue(key: "amount")).amount
        
        summary.refundsTotalCount = doc?.get(valueFor: "refunds")?.getValue(key: "count")
        summary.refundsTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "refunds")?.getValue(key: "amount")).amount
        
        summary.chargebackTotalCount = doc?.get(valueFor: "disputes")?.get(valueFor: "chargebacks")?.getValue(key: "count")
        summary.chargebackTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "disputes")?.get(valueFor: "chargebacks")?.getValue(key: "amount")).amount
        
        summary.adjustmentTotalCount = doc?.get(valueFor: "disputes")?.get(valueFor: "reversals")?.getValue(key: "count")
        summary.adjustmentTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "disputes")?.get(valueFor: "reversals")?.getValue(key: "amount")).amount
        
        summary.feesTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "fees")?.getValue(key: "amount")).amount
        
        summary.discountsTotalCount = doc?.get(valueFor: "discounts")?.getValue(key: "count")
        summary.discountsTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "discounts")?.getValue(key: "amount")).amount
        
        summary.taxTotalCount = doc?.get(valueFor: "discounts")?.getValue(key: "count")
        summary.taxTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "tax")?.getValue(key: "amount")).amount
        
        return summary
    }
    
    public static func mapDisputeSummary(_ doc: JsonDoc?) -> DisputeSummary {
        let summary = DisputeSummary()
        summary.caseId = doc?.getValue(key: "id")
        summary.caseStatus = doc?.getValue(key: "status")
        let timeCreated: String? = doc?.getValue(keys: "time_created", "stage_time_created")
        summary.caseIdTime = timeCreated?.format()
        summary.caseStage = DisputeStage(value: doc?.getValue(key: "stage"))
        summary.caseAmount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount
        summary.caseCurrency = doc?.getValue(key: "currency")
        
        summary.caseMerchantId = doc?.get(valueFor: "system")?.getValue(key: "mid")
        summary.caseTerminalId = doc?.get(valueFor: "system")?.getValue(key: "tid")
        summary.merchantHierarchy = doc?.get(valueFor: "system")?.getValue(key: "hierarchy")
        summary.merchantName = doc?.get(valueFor: "system")?.getValue(key: "name")
        summary.merchantDbaName = doc?.get(valueFor: "system")?.getValue(key: "dba")
        
        summary.reasonCode = doc?.getValue(key: "reason_code")
        summary.reason = doc?.getValue(key: "reason_description")
        
        let timeToRespondBy: String? = doc?.getValue(key: "time_to_respond_by")
        summary.respondByDate = timeToRespondBy?.format()
        
        summary.result = doc?.getValue(key: "result")
        
        summary.lastAdjustmentFunding = doc?.getValue(key: "last_adjustment_funding")
        summary.lastAdjustmentAmount = NSDecimalNumber(string: doc?.getValue(key: "last_adjustment_amount")).amount
        summary.lastAdjustmentCurrency = doc?.getValue(key: "last_adjustment_currency")
        let lastAdjustmentTimeCreated: String? = doc?.getValue(key: "last_adjustment_time_created")
        summary.lastAdjustmentTimeCreated = lastAdjustmentTimeCreated?.format()
        
        summary.type = doc?.getValue(key: "funding_type")
        
        summary.depositReference = doc?.getValue(key: "deposit_id")
        let depositTimeCreated: String? = doc?.getValue(key: "deposit_time_created")
        summary.depositDate = depositTimeCreated?.format("YYYY-MM-dd")
        
        if let paymentMethod: JsonDoc = doc?.get(valueFor: "payment_method"),
           let card = paymentMethod.get(valueFor: "card") {
            summary.transactionARN = card.getValue(key: "arn")
            summary.transactionCardType = card.getValue(key: "brand")
            summary.transactionMaskedCardNumber = card.getValue(key: "number")
        } else if let transaction: JsonDoc = doc?.get(valueFor: "transaction") {
            let timeCreated: String? = transaction.getValue(key: "time_created")
            summary.caseIdTime = timeCreated?.format()
            summary.transactionType = transaction.getValue(key: "type")
            summary.transactionAmount = NSDecimalNumber(string: transaction.getValue(key: "amount")).amount
            summary.transactionCurrency = transaction.getValue(key: "currency")
            summary.transactionReferenceNumber = transaction.getValue(key: "reference")
            let transactionTime: String? = transaction.getValue(key: "time_created")
            summary.transactionTime = transactionTime?.format()
            if let paymentMethod = transaction.get(valueFor: "payment_method"),
               let card = paymentMethod.get(valueFor: "card") {
                summary.transactionARN = card.getValue(key: "arn")
                summary.transactionCardType = card.getValue(key: "brand")
                summary.transactionMaskedCardNumber = card.getValue(key: "masked_number_first6last4")
                summary.transactionAuthCode = card.getValue(key: "authcode")
            }
        }
        
        if let documents: [JsonDoc] = doc?.getValue(key: "documents"), !documents.isEmpty {
            summary.documents = documents.compactMap {
                guard let id: String = $0.getValue(key: "id"),
                      let type = DocumentType(value: $0.getValue(key: "type")) else { return nil }
                return DisputeDocument(id: id, type: type)
            }
        }
        
        return summary
    }
    
    public static func mapStoredPaymentMethodSummary(_ doc: JsonDoc?) -> StoredPaymentMethodSummary {
        let summary = StoredPaymentMethodSummary()
        summary.id = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.timeCreated = timeCreated?.format()
        summary.status = doc?.getValue(key: "status")
        summary.reference = doc?.getValue(key: "reference")
        summary.name = doc?.getValue(key: "name")
        if let card: JsonDoc = doc?.get(valueFor: "card") {
            summary.cardLast4 = card.getValue(key: "number_last4")
            summary.cardType = card.getValue(key: "brand")
            summary.cardExpMonth = card.getValue(key: "expiry_month")
            summary.cardExpYear = card.getValue(key: "expiry_year")
        }
        
        return summary
    }
    
    public static func mapActionSummary(_ doc: JsonDoc?) -> ActionSummary {
        let summary = ActionSummary()
        summary.id = doc?.getValue(key: "id")
        summary.type = doc?.getValue(key: "type")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.timeCreated = timeCreated?.format()
        summary.resource = doc?.getValue(key: "resource")
        summary.version = doc?.getValue(key: "version")
        summary.resourceId = doc?.getValue(key: "resource_id")
        summary.resourceStatus = doc?.getValue(key: "resource_status")
        summary.httpResponseCode = doc?.getValue(key: "http_response_code")
        summary.responseCode = doc?.getValue(key: "response_code")
        summary.appId = doc?.getValue(key: "app_id")
        summary.appName = doc?.getValue(key: "app_name")
        summary.accountId = doc?.getValue(key: "account_id")
        summary.accountName = doc?.getValue(key: "account_name")
        summary.merchantName = doc?.getValue(key: "merchant_name")
        
        return summary
    }
    
    public static func mapDisputeAction(_ doc: JsonDoc?) -> DisputeAction {
        let action = DisputeAction()
        action.reference = doc?.getValue(key: "id")
        action.status = DisputeStatus(value: doc?.getValue(key: "status"))
        action.stage = DisputeStage(value: doc?.getValue(key: "stage"))
        action.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount
        action.currency = doc?.getValue(key: "currency")
        action.reasonCode = doc?.getValue(key: "reason_code")
        action.reasonDescription = doc?.getValue(key: "reason_description")
        action.result = DisputeResult(value: doc?.getValue(key: "result"))
        if let documents: [JsonDoc?] = doc?.getValue(key: "documents") {
            action.documents = documents.compactMap { $0?.getValue(key: "id") }
        }
        
        return action
    }
    
    public static func mapDocumentMetadata(_ doc: JsonDoc?) -> DocumentMetadata? {
        guard let id: String = doc?.getValue(key: "id"),
              let b64Content: String = doc?.getValue(key: "b64_content"),
              let convertedData = Data(base64Encoded: b64Content) else {
            return nil
        }
        
        return DocumentMetadata(id: id, b64Content: convertedData)
    }
    
    public static func mapDisputeDocument(_ doc: JsonDoc?) -> DisputeDocument? {
        guard let id: String = doc?.getValue(key: "id"),
              let b64Content: String = doc?.getValue(key: "b64_content"),
              let convertedData = Data(base64Encoded: b64Content) else {
            return nil
        }
        
        return DisputeDocument(id: id, content: convertedData)
    }
    
    public static func mapThreeDSecure(_ doc: JsonDoc?) -> Transaction {
        
        let parseVersion: (String?) -> Secure3dVersion = { version in
            guard let version = version else { return .any }
            if version.starts(with: "1.") {
                return .one
            } else if version.starts(with: "2.") {
                return .two
            }
            return .any
        }
        
        let secure = ThreeDSecure()
        secure.currency = doc?.getValue(key: "currency")
        if let amount: String = doc?.getValue(key: "amount") {
            secure.amount = NSDecimalNumber(string: amount).amount
        }
        secure.serverTransactionId = doc?.getValue(key: "id") ?? doc?.get(valueFor: "three_ds")?.getValue(key: "server_trans_ref")
        secure.messageVersion = doc?.get(valueFor: "three_ds")?.getValue(key: "message_version")
        secure.version = parseVersion(doc?.get(valueFor: "three_ds")?.getValue(key: "message_version"))
        secure.directoryServerStartVersion = doc?.get(valueFor: "three_ds")?.getValue(key: "ds_protocol_version_start")
        secure.directoryServerEndVersion = doc?.get(valueFor: "three_ds")?.getValue(key: "ds_protocol_version_end")
        secure.acsStartVersion = doc?.get(valueFor: "three_ds")?.getValue(key: "acs_protocol_version_start")
        secure.acsEndVersion = doc?.get(valueFor: "three_ds")?.getValue(key: "acs_protocol_version_end")
        secure.acsReferenceNumber = doc?.get(valueFor: "three_ds")?.getValue(key: "acs_reference_number")
        secure.serverTransferReference = doc?.get(valueFor: "three_ds")?.getValue(key: "server_trans_ref")
        secure.enrolled = doc?.get(valueFor: "three_ds")?.getValue(key: "enrolled_status")
        if let eci: String = doc?.get(valueFor: "three_ds")?.getValue(key: "eci"), let eciValue = Int(eci) {
            secure.eci = eciValue
        }
        secure.challengeMandated = doc?.get(valueFor: "three_ds")?.getValue(key: "challenge_status") == "MANDATED"
        secure.payerAuthenticationRequest = doc?.get(valueFor: "three_ds")?.get(valueFor: "method_data")?.getValue(key: "encoded_method_data")
        secure.issuerAcsUrl = doc?.get(valueFor: "three_ds")?.getValue(key: "method_url")
        secure.challengeValue = doc?.get(valueFor: "three_ds")?.getValue(keys: "challenge_value")
        secure.authenticationValue = doc?.get(valueFor: "three_ds")?.getValue(key: "authentication_value")
        secure.directoryServerTransactionId = doc?.get(valueFor: "three_ds")?.getValue(key: "ds_trans_ref")
        secure.acsTransactionId = doc?.get(valueFor: "three_ds")?.getValue(key: "acs_trans_ref")
        secure.status = doc?.getValue(key: "status")
        secure.statusReason = doc?.get(valueFor: "three_ds")?.getValue(key: "status_reason")
        secure.messageCategory = doc?.get(valueFor: "three_ds")?.getValue(key: "message_category")
        secure.messageType = doc?.get(valueFor: "three_ds")?.getValue(key: "message_type")
        secure.sessionDataFieldName = doc?.get(valueFor: "three_ds")?.getValue(key: "session_data_field_name")
        secure.challengeReturnUrl = doc?.get(valueFor: "notifications")?.getValue(key: "challenge_return_url")
        secure.authenticationSource = doc?.get(valueFor: "three_ds")?.getValue(key: "authentication_source")
        secure.liabilityShift = doc?.get(valueFor: "three_ds")?.getValue(key: "liability_shift")
        secure.authenticationType = doc?.get(valueFor: "three_ds")?.getValue(key: "authentication_request_type")
        secure.decoupledResponseIndicator = doc?.get(valueFor: "three_ds")?.getValue(key: "acs_decoupled_response_indicator")
        secure.whiteListStatus = doc?.get(valueFor: "three_ds")?.getValue(key: "whitelist_status")
        if let acsChallengeRequestUrl: String = doc?.get(valueFor: "three_ds")?.getValue(key: "acs_challenge_request_url") {
            if secure.challengeMandated == true {
                secure.issuerAcsUrl = acsChallengeRequestUrl
                secure.payerAuthenticationRequest = doc?.get(valueFor: "three_ds")?.getValue(key: "challenge_value")
            }
        }
        
        // Mobile data
        if let source: String = doc?.getValue(key: "source"), source == "MOBILE_SDK", let mobileData: JsonDoc = doc?.get(valueFor: "three_ds")?.get(valueFor: "mobile_data") {
            secure.payerAuthenticationRequest = mobileData.getValue(key: "acs_signed_content")
            if let acsRenderingType = mobileData.get(valueFor: "acs_rendering_type") {
                secure.acsInterface = acsRenderingType.getValue(key: "acs_interface")
                secure.acsUiTemplate = acsRenderingType.getValue(key: "acs_ui_template")
            }
        }
        
        let transaction = Transaction()
        transaction.threeDSecure = secure
        return transaction
    }
    
    public static func mapDccInfo(_ responseData: JsonDoc?) -> DccRateData? {
        var response: JsonDoc? = responseData
        
        if let responseData = response, responseData.get(valueFor: "action")?.getValue(key: "type") != self.DC_RESPONSE, !responseData.has(key: "currency_conversion") {
            return nil
        }
        
        if let currencyConversion = response?.get(valueFor: "currency_conversion") {
            response = currencyConversion
        }
        
        guard let dccRateDataResponse = response else { return nil }
        
        let dccRateData = DccRateData()
        
        dccRateData.cardHolderCurrency = dccRateDataResponse.getValue(key: "payer_currency")
        
        if let amount: String = dccRateDataResponse.getValue(key: "payer_amount") {
            dccRateData.cardHolderAmount = NSDecimalNumber(string: amount).amount
        }
        if let rate: String = dccRateDataResponse.getValue(key: "exchange_rate") {
            dccRateData.cardHolderRate = NSDecimalNumber(string: rate)
        }
        if let amount: String = dccRateDataResponse.getValue(key: "amount") {
            dccRateData.merchantAmount = NSDecimalNumber(string: amount).amount
        }
        
        dccRateData.merchantCurrency = dccRateDataResponse.getValue(key: "currency")
        dccRateData.marginRatePercentage = dccRateDataResponse.getValue(key: "margin_rate_percentage")
        dccRateData.exchangeRateSourceName = dccRateDataResponse.getValue(key: "exchange_rate_source")
        dccRateData.commissionPercentage = dccRateDataResponse.getValue(key: "commission_percentage")
        
        let timeCreated: String? = dccRateDataResponse.getValue(key: "exchange_rate_time_created")
        dccRateData.exchangeRateSourceTimestamp = timeCreated?.format() ?? timeCreated?.format("yyyy-MM-dd'T'HH:mm:ss")
        dccRateData.dccId = dccRateDataResponse.getValue(key: "id")
        
        return dccRateData
    }
    
    public static func mapReportResponse<T>(_ rawResponse: String, _ reportType: ReportType) -> T? {
        var result: Any?
        let json = JsonDoc.parse(rawResponse)
        
        if reportType == .transactionDetail && TransactionSummary() is T {
            result = GpApiMapping.mapTransactionSummary(json)
        } else if (reportType == .findTransactionsPaged || reportType == .findSettlementTransactionsPaged)
                    && PagedResult<TransactionSummary>(totalRecordCount: nil, pageSize: 0, page: 0, order: nil, orderBy: nil) is T {
            var pagedResult: PagedResult<TransactionSummary>? = getPagedResult(json)
            if let transactions: [JsonDoc] = json?.getValue(key: "transactions") {
                let mapped = transactions.map { GpApiMapping.mapTransactionSummary($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        } else if reportType == .depositDetail && DepositSummary() is T {
            result = GpApiMapping.mapDepositSummary(json)
        } else if reportType == .findDepositsPaged && PagedResult<DepositSummary>(totalRecordCount: nil, pageSize: 0, page: 0, order: nil, orderBy: nil) is T {
            var pagedResult: PagedResult<DepositSummary>? = getPagedResult(json)
            if let deposits: [JsonDoc] = json?.getValue(key: "deposits") {
                let mapped = deposits.map { GpApiMapping.mapDepositSummary($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        } else if reportType == .storedPaymentMethodDetail && StoredPaymentMethodSummary() is T {
            result = GpApiMapping.mapStoredPaymentMethodSummary(json)
        } else if reportType == .findStoredPaymentMethodsPaged && PagedResult<StoredPaymentMethodSummary>(totalRecordCount: nil, pageSize: 0, page: 0, order: nil, orderBy: nil) is T {
            var pagedResult: PagedResult<StoredPaymentMethodSummary>? = getPagedResult(json)
            if let deposits: [JsonDoc] = json?.getValue(key: "payment_methods") {
                let mapped = deposits.map { GpApiMapping.mapStoredPaymentMethodSummary($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        } else if (reportType == .disputeDetail || reportType == .settlementDisputeDetail) && DisputeSummary() is T {
            result = GpApiMapping.mapDisputeSummary(json)
        } else if (reportType == .findDisputesPaged || reportType == .findSettlementDisputesPaged)
                    && PagedResult<DisputeSummary>(totalRecordCount: nil, pageSize: 0, page: 0, order: nil, orderBy: nil) is T {
            var pagedResult: PagedResult<DisputeSummary>? = getPagedResult(json)
            if let disputes: [JsonDoc] = json?.getValue(key: "disputes") {
                let mapped = disputes.map { GpApiMapping.mapDisputeSummary($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        } else if reportType == .actionDetail && ActionSummary() is T {
            result = GpApiMapping.mapActionSummary(json)
        } else if reportType == .findActionsPaged
                    && PagedResult<ActionSummary>(totalRecordCount: nil, pageSize: 0, page: 0, order: nil, orderBy: nil) is T {
            var pagedResult: PagedResult<ActionSummary>? = getPagedResult(json)
            if let actions: [JsonDoc] = json?.getValue(key: "actions") {
                let mapped = actions.map { GpApiMapping.mapActionSummary($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        } else if reportType == .acceptDispute || reportType == .challangeDispute {
            result = GpApiMapping.mapDisputeAction(json)
        } else if reportType == .disputeDocument {
            result = GpApiMapping.mapDocumentMetadata(json)
        } else if reportType == .documentDisputeDetail {
            result = GpApiMapping.mapDisputeDocument(json)
        } else if reportType == .findPayLinkPaged {
            var pagedResult: PagedResult<PayLinkSummary>? = getPagedResult(json)
            if let links: [JsonDoc] = json?.getValue(key: "links") {
                let mapped = links.map { PayLinkSummary.mapFromJson($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        } else if reportType == .payLinkDetail {
            result = PayLinkSummary.mapFromJson(json)
        }
        return result as? T
    }
    
    public static func mapUserReportResponse<T>(_ rawResponse: String, _ reportType: ReportType) -> T? {
        var result: Any?
        let json = JsonDoc.parse(rawResponse)
        if reportType == .findMerchantsPaged {
            var pagedResult: PagedResult<MerchantSummary>? = getPagedResult(json)
            if let merchants: [JsonDoc] = json?.getValue(key: "merchants") {
                let mapped = merchants.map { GpApiMapping.mapMerchantSummary($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        }
        
        return result as? T
    }
    
    public static func mapMerchantSummary(_ doc: JsonDoc?) -> MerchantSummary {
        let merchantSummary = MerchantSummary()
        merchantSummary.id = doc?.getValue(key: "id")
        merchantSummary.name = doc?.getValue(key: "name")
        if let status: String = doc?.getValue(key: "status") {
            merchantSummary.status = UserStatus(rawValue: status)
        }
        return merchantSummary
    }
    
    public static func mapMerchantResponse<T>(_ rawResponse: String) -> T? {
        var result: Any?
        let json = JsonDoc.parse(rawResponse)
        result = GpApiMapping.mapUser(json)
        return result as? T
    }
    
    public static func mapUser(_ doc: JsonDoc?) -> User {
        let user = User()
        let userReference = UserReference()
        userReference.userId = doc?.getValue(key: "id")
        userReference.userStatus = UserStatus(value: doc?.getValue(key: "status"))
        userReference.userType = UserType(value: doc?.getValue(key: "type"))
        user.userReference = userReference
        user.responseCode = doc?.get(valueFor: "action")?.getValue(key: "result_code")
        user.name = doc?.getValue(key: "name")
        user.statusDescription = doc?.getValue(key: "status_description")
        
        if let createdTime: String = doc?.getValue(key: "time_created") {
            user.timeCreated = createdTime
        }
        return user
    }
    
    private static func getPagedResult<T>(_ doc: JsonDoc?) -> PagedResult<T>? {
        guard let doc = doc else { return nil }
        
        return PagedResult(
            totalRecordCount: doc.getValue(keys: "total_record_count", "total_count"),
            pageSize: doc.get(valueFor: "paging")?.getValue(key: "page_size") ?? .zero,
            page: doc.get(valueFor: "paging")?.getValue(key: "page") ?? .zero,
            order: doc.get(valueFor: "paging")?.getValue(key: "order"),
            orderBy: doc.get(valueFor: "paging")?.getValue(key: "order_by")
        )
    }
    
    private static func mapPayLinkResponse(_ doc: JsonDoc?) -> PayLinkResponse {
        let payLinkResponse = PayLinkResponse()
        payLinkResponse.id = doc?.getValue(key: "id")
        payLinkResponse.accountName = doc?.getValue(key: "account_name")
        payLinkResponse.url = doc?.getValue(key: "url")
        payLinkResponse.status = PayLinkStatus(value: doc?.getValue(key: "status"))
        payLinkResponse.type = PayLinkType(value: doc?.getValue(key: "type"))
        payLinkResponse.usageMode = PaymentMethodUsageMode(value: doc?.getValue(key: "usage_mode"))
        
        if let usageLimit: String = doc?.getValue(key: "usage_limit") {
            payLinkResponse.usageLimit = Int(usageLimit)
        }
        payLinkResponse.reference = doc?.getValue(key: "reference")
        payLinkResponse.name = doc?.getValue(key: "name")
        payLinkResponse.descriptionPayLink = doc?.getValue(key: "description")
        payLinkResponse.viewedCount = doc?.getValue(key: "viewed_count")
        payLinkResponse.expirationDate = doc?.getValue(key: "expiration_date")
        let shippable: String = doc?.getValue(key: "shippable") ?? "NO"
        payLinkResponse.isShippable = shippable.uppercased() == "YES"
        payLinkResponse.allowedPaymentMethods = getAllowedPaymentMethods(doc)
        return payLinkResponse
    }
    
    private static func getAllowedPaymentMethods(_ doc: JsonDoc?) -> [PaymentMethodName]? {
        var list: [PaymentMethodName]?
        
        if let transactions: JsonDoc = doc?.getValue(key: "transactions"), let listPaymentMethods: [String] = transactions.getValue(key: "allowed_payment_methods") {
            
            list = listPaymentMethods.map{ PaymentMethodName(value: $0) ?? .card }
        }
        return list
    }
    
    private static func mapMerchantAddress(_ address: JsonDoc?) -> Address {
        let addressData = Address()
        addressData.streetAddress1 = address?.getValue(key: "line_1")
        addressData.streetAddress2 = address?.getValue(key: "line_2")
        addressData.streetAddress3 = address?.getValue(key: "line_3")
        addressData.city = address?.getValue(key: "city")
        addressData.state = address?.getValue(key: "state")
        addressData.postalCode = address?.getValue(key: "postal_code")
        addressData.country = address?.getValue(key: "country")
        return addressData
    }
    
    private static func mapBNPLResponse(_ paymentMethod: JsonDoc) -> BNPLResponse {
        let bnplResponse =  BNPLResponse()
        bnplResponse.redirectUrl = paymentMethod.getValue(key: "redirect_url")
        bnplResponse.providerName = paymentMethod.get(valueFor: "bnpl")?.getValue(key: "provider")
        return bnplResponse
    }
}
