import Foundation

public struct GpApiMapping {
    
    static let DC_RESPONSE = "RATE_LOOKUP"
    
    public static func mapTransaction(_ doc: JsonDoc?) -> Transaction {
        
        let transaction = Transaction()
        transaction.transactionId = doc?.getValue(key: "id")
        let transactionCurrency: String? = doc?.getValue(key: "currency")
        if let amount: String = doc?.getValue(key: "amount") {
            transaction.balanceAmount = NSDecimalNumber(string: amount).amount(for: transactionCurrency)
        }
        if let gratuityAmount: String = doc?.getValue(key: "gratuity_amount") {
            transaction.gratuityAmount = NSDecimalNumber(string: gratuityAmount).amount(for: transactionCurrency)
        }
        // Store currency on the TransactionReference so that management calls
        // (Capture, Reverse, Refund) can resolve the correct exponent even when
        // the merchant does not call .withCurrency() on the ManagementBuilder.
        if let currency = transactionCurrency {
            let ref = transaction.transactionReference ?? TransactionReference()
            ref.currency = currency
            transaction.transactionReference = ref
        }
        transaction.responseMessage = doc?.getValue(key: "status")
        transaction.referenceNumber = doc?.getValue(key: "reference")
        transaction.clientTransactionId = doc?.getValue(key: "reference")
        transaction.authorizationMode = doc?.getValue(key: "authorization_mode")
        transaction.authorizationModeResult = doc?.getValue(key: "authorization_mode_result")
        transaction.disputeStatus = doc?.getValue(key: "dispute_status")
        transaction.documentName = doc?.getValue(key: "document_name")
        transaction.reasonCode = doc?.getValue(key: "reason_code")
        // challenge_dispute_response: documents[]{status, name}
        if let documentDocs: [JsonDoc] = doc?.getValue(key: "documents"),
           let firstDoc = documentDocs.first {
            transaction.documentStatus = firstDoc.getValue(key: "status")
            if let docName: String = firstDoc.getValue(key: "name") {
                transaction.documentName = docName
            }
        }
        transaction.timestamp = doc?.getValue(key: "time_created")
        transaction.saleType = doc?.getValue(key: "type")
        transaction.channel = doc?.getValue(key: "channel")
        transaction.captureMode = doc?.getValue(key: "capture_mode")
        transaction.country = doc?.getValue(key: "country")
        transaction.merchantId = doc?.getValue(key: "merchant_id")
        transaction.merchantName = doc?.getValue(key: "merchant_name")
        transaction.accountId = doc?.getValue(key: "account_id")
        transaction.accountName = doc?.getValue(key: "account_name")
        transaction.merchantBenefitsReference = doc?.getValue(key: "merchant_benefits_reference")
        transaction.userReference = doc?.getValue(key: "user_reference")
        let batchSummary = BatchSummary()
        batchSummary.resourceId = doc?.getValue(key: "id")
        batchSummary.batchReference = doc?.getValue(keys: "batch_id", "id")
        batchSummary.status = doc?.getValue(key: "status")
        batchSummary.responseCode = doc?.get(valueFor: "action")?.getValue(key: "result_code")
        batchSummary.transactionCount = doc?.getValue(keys: "transaction_count", "count")
        batchSummary.closeTransactionId = doc?.getValue(keys: "close_transaction_id", "closing_transaction_id")
        batchSummary.openTransactionId = doc?.getValue(keys: "open_transaction_id", "opening_transaction_id")
        batchSummary.sequenceNumber = doc?.getValue(keys: "sequence_number", "batch_sequence_number")
        batchSummary.transactionToken = doc?.getValue(keys: "transaction_token", "token")
        batchSummary.merchantName = doc?.getValue(keys: "merchant_name", "name")
        batchSummary.siteId = doc?.getValue(key: "site_id")
        batchSummary.deviceId = doc?.getValue(key: "device_id")
        batchSummary.sicCode = doc?.getValue(key: "sic")
        batchSummary.openActionId = doc?.getValue(key: "open_action_id")
        batchSummary.closeActionId = doc?.getValue(key: "close_action_id")
        batchSummary.merchantId = doc?.getValue(key: "merchant_id")
        batchSummary.accountId = doc?.getValue(key: "account_id")
        batchSummary.accountName = doc?.getValue(key: "account_name")
        batchSummary.siteReference = doc?.getValue(key: "site_reference")
        batchSummary.deviceReference = doc?.getValue(key: "device_reference")
        batchSummary.currency = doc?.getValue(key: "currency")

        let created: String? = doc?.getValue(key: "time_created")
        let updated: String? = doc?.getValue(key: "time_last_updated")
        let closed: String? = doc?.getValue(key: "time_closed")
        batchSummary.timeCreated = parseDate(created)
        batchSummary.timeLastUpdated = parseDate(updated)
        batchSummary.timeClosed = parseDate(closed)

        if let gratuityAmount: String = doc?.getValue(key: "gratuity_amount") {
            batchSummary.gratuityAmount = NSDecimalNumber(string: gratuityAmount).amount
        }

        let openTimeValue: String? = doc?.getValue(keys: "open_time", "time_created")
        batchSummary.openTime = parseDate(openTimeValue)

        if let amount: String = doc?.getValue(keys: "amount", "total_amount") {
            batchSummary.totalAmount = NSDecimalNumber(string: amount).amount(for: transactionCurrency)
            
            if transaction.responseMessage == TransactionStatus.preauthorized.rawValue {
                transaction.authorizedAmount = NSDecimalNumber(string: amount).amount(for: transactionCurrency)
            }
        }

        if let sales: JsonDoc = doc?.get(valueFor: "sales") {
            batchSummary.saleCount = sales.getValue(key: "count")
            if let saleAmount: String = sales.getValue(key: "amount") {
                batchSummary.saleAmount = NSDecimalNumber(string: saleAmount).amount
            }
            batchSummary.sales = mapBatchAmountInfo(sales)
        }

        if let credits: JsonDoc = doc?.get(valueFor: "credits") {
            batchSummary.creditCount = credits.getValue(key: "count")
            if let creditAmount: String = credits.getValue(key: "amount") {
                batchSummary.creditAmount = NSDecimalNumber(string: creditAmount).amount
            }
        }

        if let debits: JsonDoc = doc?.get(valueFor: "debits") {
            batchSummary.debitCount = debits.getValue(key: "count")
            if let debitAmount: String = debits.getValue(key: "amount") {
                batchSummary.debitAmount = NSDecimalNumber(string: debitAmount).amount
            }
        }

        if let returns: JsonDoc = doc?.get(valueFor: "returns") {
            batchSummary.returnCount = returns.getValue(key: "count")
            if let returnAmount: String = returns.getValue(key: "amount") {
                batchSummary.returnAmount = NSDecimalNumber(string: returnAmount).amount
            }
        } else if let refunds: JsonDoc = doc?.get(valueFor: "refunds") {
            batchSummary.returnCount = refunds.getValue(key: "count")
            if let returnAmount: String = refunds.getValue(key: "amount") {
                batchSummary.returnAmount = NSDecimalNumber(string: returnAmount).amount
            }
            batchSummary.refunds = mapBatchAmountInfo(refunds)
        }

        if let fundingDebit = doc?.get(valueFor: "funding_debit") {
            batchSummary.fundingDebit = mapBatchAmountInfo(fundingDebit)
        }

        if let fundingCredit = doc?.get(valueFor: "funding_credit") {
            batchSummary.fundingCredit = mapBatchAmountInfo(fundingCredit)
        }

        if let brandBreakdown: [JsonDoc] = doc?.getValue(key: "brand_breakdown") {
            batchSummary.brandBreakdown = mapBatchBrandBreakdown(brandBreakdown)
        }

        if let hostBreakdown: JsonDoc = doc?.get(valueFor: "host_breakdown") {
            batchSummary.hostBreakdown = mapBatchHostBreakdown(hostBreakdown)
        }

        if let action: JsonDoc = doc?.get(valueFor: "action") {
            batchSummary.action = mapBatchAction(action)
        }

        batchSummary.closeCount = batchSummary.closeCount ?? doc?.getValue(key: "close_count")
        batchSummary.saleCount = batchSummary.saleCount ?? doc?.getValue(key: "sale_count")
        batchSummary.creditCount = batchSummary.creditCount ?? doc?.getValue(key: "credit_count")
        batchSummary.debitCount = batchSummary.debitCount ?? doc?.getValue(key: "debit_count")
        batchSummary.returnCount = batchSummary.returnCount ?? doc?.getValue(key: "return_count")

        if batchSummary.saleAmount == nil, let saleAmount: String = doc?.getValue(key: "sale_amount") {
            batchSummary.saleAmount = NSDecimalNumber(string: saleAmount).amount
        }

        if batchSummary.creditAmount == nil, let creditAmount: String = doc?.getValue(key: "credit_amount") {
            batchSummary.creditAmount = NSDecimalNumber(string: creditAmount).amount
        }

        if batchSummary.debitAmount == nil, let debitAmount: String = doc?.getValue(key: "debit_amount") {
            batchSummary.debitAmount = NSDecimalNumber(string: debitAmount).amount
        }

        if batchSummary.returnAmount == nil, let returnAmount: String = doc?.getValue(key: "return_amount") {
            batchSummary.returnAmount = NSDecimalNumber(string: returnAmount).amount
        }

        transaction.batchSummary = batchSummary
        transaction.responseCode = doc?.get(valueFor: "action")?.getValue(key: "result_code")
        if let id: String = doc?.getValue(key: "id") {
            if id.starts(with: "PMT_") {
                transaction.token = id
                // Root-level fingerprint fields are returned on PMT create/edit responses
                if let fingerprint: String = doc?.getValue(key: "fingerprint") {
                    transaction.fingerPrint = fingerprint
                }
                if let fingerprintIndicator: String = doc?.getValue(key: "fingerprint_presence_indicator") {
                    transaction.fingerPrintIndicator = fingerprintIndicator
                }
            } else if id.starts(with: "DEC_") {
                transaction.decryptId = id
            }
        }
        // Root-level card node: returned on PMT detokenize and cryptogram generation responses
        if let card: JsonDoc = doc?.get(valueFor: "card"), doc?.get(valueFor: "payment_method") == nil {
            transaction.cardNumber = card.getValue(key: "number")
            transaction.cardType = card.getValue(key: "brand")
            transaction.cardExpMonth = Int(card.getValue(key: "expiry_month") ?? .empty)
            transaction.cardExpYear = Int(card.getValue(key: "expiry_year") ?? .empty)
            transaction.cardCryptogram = card.getValue(key: "cryptogram")
            transaction.cardCryptogramExpiryMonth = card.getValue(key: "cryptogram_expiry_month")
            transaction.cardCryptogramExpiryYear = card.getValue(key: "cryptogram_expiry_year")
            transaction.cardEci = card.getValue(key: "eci")
        }
        
        if let type: String = doc?.get(valueFor: "action")?.getValue(key: "type"), let actionType = ActionType(value: type) {
            switch actionType {
            case .linkCreate, .linkEdit:
                transaction.payByLinkResponse = mapPayByLinkResponse(doc)
                if let transactions: JsonDoc = doc?.getValue(key: "transactions"), let amount: String = transactions.getValue(key: "amount") {
                    let linkCurrency: String? = transactions.getValue(key: "currency") ?? transactionCurrency
                    transaction.balanceAmount = NSDecimalNumber(string: amount).amount(for: linkCurrency)
                }
                break
            case .split:
                if let transfers: [JsonDoc] = doc?.getValue(key: "transfers") {
                    transaction.transfersFundsAccounts = mapTransferFundAccounts(transfers)
                }
                break
            default:
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
            
            transaction.gatewayResponseMessage = paymentMethod.getValue(key: "message")
            transaction.paymentMethodNarrative = paymentMethod.getValue(key: "narrative")
            transaction.paymentMethodQrCode = paymentMethod.getValue(key: "qr_code")
            
            if let auth: JsonDoc = paymentMethod.get(valueFor: "authentication"),
               let threeDs: JsonDoc = auth.get(valueFor: "three_ds") {
                transaction.cavvResponseCode = threeDs.getValue(key: "cavv_result")
            }
            
            if paymentMethod.has(key: "bnpl") {
                transaction.paymentMethodType = .BNPL
                transaction.bnplResponse = mapBNPLResponse(paymentMethod)
                return transaction
            }
            
            transaction.authorizationCode = paymentMethod.get(valueFor: "card")?.getValue(key: "authcode")
            
            if transaction.authorizationCode.isNilOrEmpty && paymentMethod.has(key: "digital_wallet"), let digitalWallet: JsonDoc = paymentMethod.get(valueFor: "digital_wallet") {
                
                let cardDetails = Card()
                cardDetails.brand = digitalWallet.getValue(key: "brand")
                cardDetails.maskedNumberLast4 = digitalWallet.getValue(key: "masked_number_last4")
                
                cardDetails.issuer = digitalWallet.getValue(key: "issuer")
                cardDetails.funding = digitalWallet.getValue(key: "funding")
                cardDetails.binCountry = digitalWallet.getValue(key: "country")
                cardDetails.maskedNumberFirst6Last4 = digitalWallet.getValue(key: "masked_number_first6last4")
                cardDetails.maskedNetworkTokenLast4 = digitalWallet.getValue(key: "masked_token_first6last4")
                cardDetails.paymentAccountReference = digitalWallet.getValue(key: "payment_account_reference")
                
                transaction.cardDetails = cardDetails
                transaction.threeDSecure?.eci = digitalWallet.getValue(key: "eci")
                transaction.authorizationCode = digitalWallet.getValue(key: "authcode")
                transaction.cardBrandTransactionId = digitalWallet.getValue(key: "brand_reference")
            }
            
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
                transaction.commercialLevel = card.getValue(key: "commercial_level") ?? .empty
                transaction.categoryType = card.getValue(key: "category")
                
                if let availableBalance: String = card.getValue(key: "available_balance") {
                    transaction.availableBalance = NSDecimalNumber(string: availableBalance).amount(for: transactionCurrency)
                }

                let cardDetails = transaction.cardDetails ?? Card()
                cardDetails.avsPostalCode = card.getValue(key: "avs_postal_code")
                cardDetails.issuer = card.getValue(key: "issuer")
                cardDetails.country = card.getValue(key: "country")
                cardDetails.currency = card.getValue(key: "currency")
                cardDetails.funding = card.getValue(key: "funding")
                cardDetails.maskedNumberFirst6Last4 = card.getValue(key: "masked_number_first6last4")
                cardDetails.tagResponse = card.getValue(key: "tag_response")
                cardDetails.brandTimeReference = card.getValue(key: "brand_time_reference")
                cardDetails.maskedNetworkTokenLast4 = card.getValue(key: "masked_network_token_last4")
                cardDetails.networkTokenExpiryMonth = card.getValue(key: "network_token_expiry_month")
                cardDetails.networkTokenExpiryYear = card.getValue(key: "network_token_expiry_year")
                cardDetails.paymentAccountReference = card.getValue(key: "payment_account_reference")
                transaction.cardDetails = cardDetails
                
                if let provider: JsonDoc = card.get(valueFor: "provider") {
                    transaction.cardIssuerResponse = mapCardIssuerResponse(provider)
                } else {
                    let cardIssuer = CardIssuerResponse()
                    cardIssuer.result = paymentMethod.getValue(key: "result")
                    transaction.cardIssuerResponse = cardIssuer
                }
            }
            
            if let bankTransfer: JsonDoc = paymentMethod.get(valueFor: "bank_transfer") {
                transaction.paymentMethodType = .ach
                if let maskedAccountNumber: String = bankTransfer.getValue(key: "masked_account_number_last4") {
                    transaction.cardLast4 = maskedAccountNumber
                }
            }
            
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

            // eRaty returns payer at the top level of the response doc (not inside payment_method)
            if let topLevelPayer: JsonDoc = doc?.get(valueFor: "payer") {
                let payerDetails = transaction.payerDetails ?? PayerDetails()
                payerDetails.id = topLevelPayer.getValue(key: "id")
                payerDetails.firstName = payerDetails.firstName ?? topLevelPayer.getValue(key: "first_name")
                payerDetails.lastName = payerDetails.lastName ?? topLevelPayer.getValue(key: "last_name")
                payerDetails.reference = topLevelPayer.getValue(key: "reference")
                payerDetails.email = payerDetails.email ?? topLevelPayer.getValue(key: "email")
                payerDetails.country = payerDetails.country ?? topLevelPayer.getValue(key: "country")
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
            
        if (doc?.has(key: "installment")) != nil {
            if let installmentJson: JsonDoc  = doc?.getValue(key: "installment") {
                transaction.installmentData = InstallmentData(json: installmentJson)
            }
        }
        
        transaction.dccRateData = mapDccInfo(doc)

        if let orderDoc: JsonDoc = doc?.get(valueFor: "order") {
            let orderDetails = OrderDetails()
            orderDetails.shippingAmount = NSDecimalNumber(string: orderDoc.getValue(key: "shipping_amount") ?? "").amount(for: transactionCurrency)
            orderDetails.dutyAmount = NSDecimalNumber(string: orderDoc.getValue(key: "duty_amount") ?? "").amount(for: transactionCurrency)
            if let taxDocs: [JsonDoc] = orderDoc.getValue(key: "taxes") {
                orderDetails.taxes = taxDocs.map {
                    Tax(type: $0.getValue(key: "type") ?? "",
                        amount: $0.getValue(key: "amount") ?? "",
                        percentage: $0.getValue(key: "percentage"))
                }
            }
            transaction.orderDetails = orderDetails
        }

        if let deviceDoc: JsonDoc = doc?.get(valueFor: "device") {
            transaction.hostResponseCode = deviceDoc.getValue(key: "host_response_code")
            transaction.brandSequenceNumber = deviceDoc.getValue(key: "brand_sequence_number")
        }

        return transaction
    }
    
    public static func mapTransactionSummary(_ doc: JsonDoc?) -> TransactionSummary {
        let paymentMethod: JsonDoc? = doc?.get(valueFor: "payment_method")
        let card: JsonDoc? = paymentMethod?.get(valueFor: "card")
        
        let summary = TransactionSummary()
        summary.transactionId = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.transactionDate = timeCreated?.format() ?? timeCreated?.format("yyyy-MM-dd'T'HH:mm:ss")
        let timeLastUpdated: String? = doc?.getValue(key: "time_last_updated")
        summary.timeLastUpdated = timeLastUpdated?.format() ?? timeLastUpdated?.format("yyyy-MM-dd'T'HH:mm:ss")
        summary.transactionStatus = TransactionStatus(value: doc?.getValue(key: "status"))
        summary.transactionType = doc?.getValue(key: "type")
        summary.channel = doc?.getValue(key: "channel")
        summary.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount(for: summary.currency)
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
        summary.gratuityAmount = doc?.getValue(key: "gratuity_amount")
        summary.cashBackAmount = doc?.getValue(key: "cashback_amount")
        summary.description = doc?.getValue(key: "description")
        summary.orderReference = doc?.getValue(key: "order_reference")
        summary.initiator = doc?.getValue(key: "initiator")
        summary.language = doc?.getValue(key: "language")
        summary.ipAddress = doc?.getValue(key: "ip_address")
        summary.siteTrace = doc?.getValue(key: "site_reference")
        summary.createActionId = doc?.getValue(key: "create_action_id")
        
        summary.gatewayResponseCode = paymentMethod?.getValue(key: "result")
        summary.gatewayResponseMessage = paymentMethod?.getValue(key: "message")
        summary.entryMode = paymentMethod?.getValue(key: "entry_mode")
        summary.cardHolderName = paymentMethod?.getValue(key: "name")
        summary.fingerprint = paymentMethod?.getValue(key: "fingerprint")
        summary.fingerprintIndicator = paymentMethod?.getValue(key: "fingerprint_presence_indicator")
        summary.userReference = doc?.getValue(key: "user_reference")
        
        summary.cardType = card?.getValue(key: "brand")
        summary.authCode = card?.getValue(key: "authcode")
        summary.brandReference = card?.getValue(key: "brand_reference")
        summary.aquirerReferenceNumber = card?.getValue(key: "arn")
        summary.maskedCardNumber = card?.getValue(key: "masked_number_first6last4")
        summary.cardDetails = mapCardDetails(card)
        
        summary.depositReference = doc?.getValue(key: "deposit_id")
        let depositTimeCreated: String? = doc?.getValue(key: "deposit_time_created")
        summary.depositDate = depositTimeCreated?.format("YYYY-MM-dd")
        summary.depositStatus = DepositStatus(value: doc?.getValue(key: "deposit_status"))
        
        let system: JsonDoc? = doc?.get(valueFor: "system")
        summary.merchantId = doc?.getValue(key: "merchant_id") ?? system?.getValue(key: "mid")
        summary.merchantHierarchy = system?.getValue(key: "hierarchy")
        summary.merchantName = doc?.getValue(key: "merchant_name") ?? system?.getValue(key: "name")
        summary.merchantDbaName = system?.getValue(key: "dba")
        summary.merchantDeviceIdentifier = system?.getValue(key: "tid")
        summary.accountId = doc?.getValue(key: "account_id")
        summary.accountName = doc?.getValue(key: "account_name")
        
        if let payer: JsonDoc = doc?.get(valueFor: "payer") {
            summary.customerId = payer.getValue(key: "id")
        }
        
        if let link: JsonDoc = doc?.get(valueFor: "link") {
            summary.linkId = link.getValue(key: "id")
        }
        
        if let actionDoc: JsonDoc = doc?.get(valueFor: "action") {
            summary.action = mapActionSummary(actionDoc)
        }
        
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
        
        if let paymentMethod = paymentMethod, paymentMethod.has(key: "authentication") {
            summary.threeDSecure = mapThreeDSInfo(paymentMethod.get(valueFor: "authentication"))
        }
        if (doc?.has(key: "installment")) != nil {
            if let installmentJson: JsonDoc  = doc?.getValue(key: "installment") {
                summary.installmentData = InstallmentData(json: installmentJson)
            }
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
        let depositCurrency: String? = doc?.getValue(key: "currency")
        summary.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount(for: depositCurrency)
        summary.currency = depositCurrency
        
        summary.merchantNumber = doc?.get(valueFor: "system")?.getValue(key: "mid")
        summary.merchantHierarchy = doc?.get(valueFor: "system")?.getValue(key: "hierarchy")
        summary.merchantName = doc?.get(valueFor: "system")?.getValue(key: "name")
        summary.merchantDbaName = doc?.get(valueFor: "system")?.getValue(key: "dba")
        
        summary.salesTotalCount = doc?.get(valueFor: "sales")?.getValue(key: "count")
        summary.salesTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "sales")?.getValue(key: "amount")).amount(for: depositCurrency)
        
        summary.refundsTotalCount = doc?.get(valueFor: "refunds")?.getValue(key: "count")
        summary.refundsTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "refunds")?.getValue(key: "amount")).amount(for: depositCurrency)
        
        summary.chargebackTotalCount = doc?.get(valueFor: "disputes")?.get(valueFor: "chargebacks")?.getValue(key: "count")
        summary.chargebackTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "disputes")?.get(valueFor: "chargebacks")?.getValue(key: "amount")).amount(for: depositCurrency)
        
        summary.adjustmentTotalCount = doc?.get(valueFor: "disputes")?.get(valueFor: "reversals")?.getValue(key: "count")
        summary.adjustmentTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "disputes")?.get(valueFor: "reversals")?.getValue(key: "amount")).amount(for: depositCurrency)
        
        summary.feesTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "fees")?.getValue(key: "amount")).amount(for: depositCurrency)
        
        summary.discountsTotalCount = doc?.get(valueFor: "discounts")?.getValue(key: "count")
        summary.discountsTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "discounts")?.getValue(key: "amount")).amount(for: depositCurrency)
        
        summary.taxTotalCount = doc?.get(valueFor: "discounts")?.getValue(key: "count")
        summary.taxTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "tax")?.getValue(key: "amount")).amount(for: depositCurrency)
        
        return summary
    }
    
    public static func mapDisputeSummary(_ doc: JsonDoc?) -> DisputeSummary {
        let summary = DisputeSummary()
        summary.caseId = doc?.getValue(key: "id")
        summary.caseStatus = doc?.getValue(key: "status")
        let timeCreated: String? = doc?.getValue(keys: "time_created", "stage_time_created")
        summary.caseIdTime = timeCreated?.format()
        summary.caseStage = DisputeStage(value: doc?.getValue(key: "stage"))
        let caseStageTime: String? = doc?.getValue(key: "stage_time_created")
        summary.caseStageTime = caseStageTime?.format()
        summary.caseAmount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount(for: summary.caseCurrency)
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
        summary.lastAdjustmentAmount = NSDecimalNumber(string: doc?.getValue(key: "last_adjustment_amount")).amount(for: summary.lastAdjustmentCurrency)
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
            summary.transactionAmount = NSDecimalNumber(string: transaction.getValue(key: "amount")).amount(for: summary.transactionCurrency)
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
        summary.merchantId = doc?.getValue(key: "merchant_id")
        summary.merchantName = doc?.getValue(key: "merchant_name")
        summary.accountId = doc?.getValue(key: "account_id")
        summary.accountName = doc?.getValue(key: "account_name")
        summary.reference = doc?.getValue(key: "reference")
        summary.name = doc?.getValue(key: "name")
        summary.usageMode = doc?.getValue(key: "usage_mode")
        summary.autoUpdater = doc?.getValue(key: "auto_updater")
        summary.fingerprint = doc?.getValue(key: "fingerprint")
        summary.fingerprintPresenceIndicator = doc?.getValue(key: "fingerprint_presence_indicator")
        if let payer: JsonDoc = doc?.get(valueFor: "payer") {
            summary.payerId = payer.getValue(key: "id")
        }
        if let card: JsonDoc = doc?.get(valueFor: "card") {
            // GET detail uses "number_last4"; POST create/PATCH uses "masked_number_last4"
            summary.cardLast4 = card.getValue(key: "masked_number_last4") ?? card.getValue(key: "number_last4")
            summary.cardType = card.getValue(key: "brand")
            summary.cardExpMonth = card.getValue(key: "expiry_month")
            summary.cardExpYear = card.getValue(key: "expiry_year")
            summary.cardBrandReference = card.getValue(key: "brand_reference")
            summary.networkToken = card.getValue(key: "network_token")
            summary.maskedNetworkTokenLast4 = card.getValue(key: "masked_network_token_last4")
            summary.networkTokenExpiryMonth = card.getValue(key: "network_token_expiry_month")
            summary.networkTokenExpiryYear = card.getValue(key: "network_token_expiry_year")
        }
        if let action: JsonDoc = doc?.get(valueFor: "action") {
            summary.actionId = action.getValue(key: "id")
            summary.actionType = action.getValue(key: "type")
            let actionTimeCreated: String? = action.getValue(key: "time_created")
            summary.actionTimeCreated = actionTimeCreated?.format()
            summary.actionResultCode = action.getValue(key: "result_code")
            summary.actionAppId = action.getValue(key: "app_id")
            summary.actionAppName = action.getValue(key: "app_name")
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
        summary.resultCode = doc?.getValue(key: "result_code")
        return summary
    }
    
    public static func mapAuthenticationSummary(_ doc: JsonDoc?) -> AuthenticationSummary {
        let summary = AuthenticationSummary()
        summary.id = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.timeCreated = timeCreated?.format()
        summary.status = doc?.getValue(key: "status")
        summary.merchantId = doc?.getValue(key: "merchant_id")
        summary.merchantName = doc?.getValue(key: "merchant_name")
        summary.accountId = doc?.getValue(key: "account_id")
        summary.accountName = doc?.getValue(key: "account_name")
        summary.channel = doc?.getValue(key: "channel")
        summary.currency = doc?.getValue(key: "currency")
        if let amount: String = doc?.getValue(key: "amount") {
            summary.amount = NSDecimalNumber(string: amount).amount(for: summary.currency)
        }
        summary.country = doc?.getValue(key: "country")
        summary.source = doc?.getValue(key: "source")
        summary.actionCreateId = doc?.getValue(key: "action_create_id")

        if let system = doc?.get(valueFor: "system") {
            summary.systemMid = system.getValue(key: "mid")
            summary.systemTid = system.getValue(key: "tid")
            summary.systemName = system.getValue(key: "name")
        }

        if let paymentMethod = doc?.get(valueFor: "payment_method") {
            summary.paymentMethodResult = paymentMethod.getValue(key: "result")
            summary.paymentMethodMessage = paymentMethod.getValue(key: "message")
            summary.paymentMethodEntryMode = paymentMethod.getValue(key: "entry_mode")
            summary.paymentMethodFingerprint = paymentMethod.getValue(key: "fingerprint")
            summary.paymentMethodFingerprintPresenceIndicator = paymentMethod.getValue(key: "fingerprint_presence_indicator")
            summary.paymentMethodName = paymentMethod.getValue(key: "name")

            if let card = paymentMethod.get(valueFor: "card") {
                summary.cardFunding = card.getValue(key: "funding")
                summary.cardBrand = card.getValue(key: "brand")
                summary.cardAuthCode = card.getValue(key: "authcode")
                summary.cardBrandReference = card.getValue(key: "brand_reference")
                summary.maskedCardNumber = card.getValue(key: "masked_number_first6last4")
                summary.cvvIndicator = card.getValue(key: "cvv_indicator")
                summary.cvvResult = card.getValue(key: "cvv_result")
                summary.avsAddressResult = card.getValue(key: "avs_address_result")
                summary.avsPostalCodeResult = card.getValue(key: "avs_postal_code_result")
            }

            if let threeDS = paymentMethod.get(valueFor: "three_ds") {
                summary.acsTransactionId = threeDS.getValue(key: "acs_trans_ref")
                summary.acsReferenceNumber = threeDS.getValue(key: "acs_reference_number")
                summary.directoryServerTransactionId = threeDS.getValue(key: "ds_trans_ref")
                summary.serverTransferReference = threeDS.getValue(key: "server_trans_ref")
                summary.liabilityShift = threeDS.getValue(key: "liability_shift")
                summary.authenticationValue = threeDS.getValue(key: "value")
                summary.eci = threeDS.getValue(key: "eci")
                summary.threeDSecureStatus = threeDS.getValue(key: "status")
                summary.threeDSecureStatusReason = threeDS.getValue(key: "status_reason")
                summary.messageCategory = threeDS.getValue(key: "message_category")
                summary.messageVersion = threeDS.getValue(key: "message_version")
                summary.challengeStatus = threeDS.getValue(key: "challenge_status")
            }
        }

        if let action = doc?.get(valueFor: "action") {
            summary.action = GpApiMapping.mapActionSummary(action)
        }

        return summary
    }

    public static func mapDisputeAction(_ doc: JsonDoc?) -> DisputeAction {
        let action = DisputeAction()
        action.reference = doc?.getValue(key: "id")
        action.status = DisputeStatus(value: doc?.getValue(key: "status"))
        action.stage = DisputeStage(value: doc?.getValue(key: "stage"))
        action.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount(for: action.currency)
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
        let threeDS = doc?.get(valueFor: "three_ds")
        secure.currency = doc?.getValue(key: "currency")
        if let amount: String = doc?.getValue(key: "amount") {
            secure.amount = NSDecimalNumber(string: amount).amount(for: secure.currency)
        }
        secure.serverTransactionId = doc?.getValue(key: "id") ?? threeDS?.getValue(key: "server_trans_ref")
        secure.messageVersion = threeDS?.getValue(key: "message_version")
        secure.version = parseVersion(threeDS?.getValue(key: "message_version"))
        secure.directoryServerStartVersion = threeDS?.getValue(key: "ds_protocol_version_start")
        secure.directoryServerEndVersion = threeDS?.getValue(key: "ds_protocol_version_end")
        secure.acsStartVersion = threeDS?.getValue(key: "acs_protocol_version_start")
        secure.acsEndVersion = threeDS?.getValue(key: "acs_protocol_version_end")
        secure.acsReferenceNumber = threeDS?.getValue(key: "acs_reference_number")
        secure.serverTransferReference = threeDS?.getValue(key: "server_trans_ref")
        secure.enrolled = threeDS?.getValue(key: "enrolled_status")
        if let eci: String = threeDS?.getValue(key: "eci"), let eciValue = Int(eci) {
            secure.eci = eciValue
        }
        secure.challengeMandated = threeDS?.getValue(key: "challenge_status") == "MANDATED"
        secure.payerAuthenticationRequest = threeDS?.get(valueFor: "method_data")?.getValue(key: "encoded_method_data")
        secure.issuerAcsUrl = threeDS?.getValue(key: "method_url")
        secure.challengeValue = threeDS?.getValue(keys: "challenge_value")
        secure.authenticationValue = threeDS?.getValue(key: "authentication_value")
        secure.directoryServerTransactionId = threeDS?.getValue(key: "ds_trans_ref")
        secure.acsTransactionId = threeDS?.getValue(key: "acs_trans_ref")
        secure.status = doc?.getValue(key: "status")
        secure.statusReason = threeDS?.getValue(key: "status_reason")
        secure.messageCategory = threeDS?.getValue(key: "message_category")
        secure.messageType = threeDS?.getValue(key: "message_type")
        secure.sessionDataFieldName = threeDS?.getValue(key: "session_data_field_name")
        secure.challengeReturnUrl = doc?.get(valueFor: "notifications")?.getValue(key: "challenge_return_url")
        secure.authenticationSource = threeDS?.getValue(key: "authentication_source")
        secure.liabilityShift = threeDS?.getValue(key: "liability_shift")
        secure.authenticationType = threeDS?.getValue(key: "authentication_type")
        secure.authenticationRequestType = threeDS?.getValue(key: "authentication_request_type")
        secure.decoupledResponseIndicator = threeDS?.getValue(key: "acs_decoupled_response_indicator")
        secure.whiteListStatus = threeDS?.getValue(key: "whitelist_status")
        secure.cardHolderResponseInfo = threeDS?.getValue(key: "cardholder_response_info")
        secure.redirectUrl = threeDS?.getValue(key: "redirect_url")
        if let indicators: [String] = threeDS?.getValue(key: "acs_info_indicator") {
            secure.acsInfoIndicator = indicators
        } else if let indicator: String = threeDS?.getValue(key: "acs_info_indicator") {
            secure.acsInfoIndicator = [indicator]
        }
        if let messageExtension: [String] = threeDS?.getValue(key: "message_extension") {
            secure.messageExtension = messageExtension
        }
        secure.xid = threeDS?.getValue(key: "xid")
        secure.cavv = threeDS?.getValue(keys: "cavv", "authentication_value")
        secure.paymentDataSource = doc?.getValue(key: "source")

        if let acsChallengeRequestUrl: String = threeDS?.getValue(key: "acs_challenge_request_url") {
            if secure.challengeMandated == true {
                secure.issuerAcsUrl = acsChallengeRequestUrl
                secure.payerAuthenticationRequest = threeDS?.getValue(key: "challenge_value")
            } else if secure.issuerAcsUrl == nil {
                secure.issuerAcsUrl = acsChallengeRequestUrl
            }
        }
        
        if let mobileData: JsonDoc = threeDS?.get(valueFor: "mobile_data") {
            secure.payerAuthenticationRequest = mobileData.getValue(key: "acs_signed_content") ?? secure.payerAuthenticationRequest
            secure.sdkInterface = mobileData.getValue(key: "sdk_interface")
            secure.sdkUiType = mobileData.getValue(key: "sdk_ui_type")

            if let acsRenderingType = mobileData.get(valueFor: "acs_rendering_type") {
                secure.acsInterface = acsRenderingType.getValue(key: "acs_interface")
                secure.acsUiTemplate = acsRenderingType.getValue(key: "acs_ui_template")
            } else {
                secure.acsInterface = mobileData.getValue(key: "acs_interface")
                secure.acsUiTemplate = mobileData.getValue(key: "acs_ui_template")
            }
        }
        
        let transaction = Transaction()
        transaction.transactionId = doc?.getValue(key: "id")
        transaction.responseCode = doc?.get(valueFor: "action")?.getValue(key: "result_code")
        transaction.responseMessage = doc?.getValue(key: "status")

        if let paymentMethod = doc?.get(valueFor: "payment_method"),
           let cardDoc = paymentMethod.get(valueFor: "card") {
            let cardDetails = mapCardDetails(cardDoc)
            cardDetails.cardHolderName = paymentMethod.getValue(key: "name")
            cardDetails.brandReference = cardDoc.getValue(key: "brand_reference")

            transaction.cardDetails = cardDetails
            transaction.cardType = cardDoc.getValue(key: "brand")
            transaction.cardLast4 = cardDoc.getValue(key: "masked_number_last4")
            transaction.cardBrandTransactionId = cardDoc.getValue(key: "brand_reference")
        }

        transaction.threeDSecure = secure
        return transaction
    }
    
    public static func mapDccInfo(_ responseData: JsonDoc?) -> DccRateData? {
        var response: JsonDoc? = responseData
        
        if let responseData = response,
           responseData.get(valueFor: "action")?.getValue(key: "type") != self.DC_RESPONSE,
           !responseData.has(key: "currency_conversion") {
            return nil
        }
        
        if let currencyConversion = response?.get(valueFor: "currency_conversion") {
            response = currencyConversion
        }
        
        guard let dccRateDataResponse = response else { return nil }
        
        let dccRateData = DccRateData()
        
        dccRateData.cardHolderCurrency = dccRateDataResponse.getValue(key: "payer_currency")
        
        if let amount: String = dccRateDataResponse.getValue(key: "payer_amount") {
            dccRateData.cardHolderAmount = NSDecimalNumber(string: amount).amount(for: dccRateData.cardHolderCurrency)
        }
        if let rate: String = dccRateDataResponse.getValue(key: "exchange_rate") {
            dccRateData.cardHolderRate = NSDecimalNumber(string: rate)
        }
        if let amount: String = dccRateDataResponse.getValue(key: "amount") {
            dccRateData.merchantAmount = NSDecimalNumber(string: amount).amount(for: dccRateData.merchantCurrency)
        }
        
        dccRateData.merchantCurrency = dccRateDataResponse.getValue(key: "currency")
        dccRateData.marginRatePercentage = dccRateDataResponse.getValue(key: "margin_rate_percentage")
        dccRateData.exchangeRateSourceName = dccRateDataResponse.getValue(key: "exchange_rate_source")
        dccRateData.commissionPercentage = dccRateDataResponse.getValue(key: "commission_percentage")
        dccRateData.conversionRate = dccRateDataResponse.getValue(key: "conversion_rate")
        dccRateData.exchangeSourceTime = dccRateDataResponse.getValue(key: "exchange_source_time")

        let requestTypeValue: String? = dccRateDataResponse.getValue(key: "request_type")
            ?? dccRateDataResponse.getValue(key: "type")
            ?? dccRateDataResponse.getValue(key: "transaction_type")
            ?? "SALE"
        dccRateData.dccRateType = .sale
        switch requestTypeValue?.uppercased() {
        case "SALE":
            dccRateData.dccRateType = .sale
        case "REFUND":
            dccRateData.dccRateType = .refund
        default:
            dccRateData.dccRateType = .sale
        }

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
        } else if reportType == .transactionSummaryReport
                    && PagedResult<TransactionSummaryReport>(totalRecordCount: nil, pageSize: 0, page: 0, order: nil, orderBy: nil) is T {
            var pagedResult: PagedResult<TransactionSummaryReport>? = getPagedResult(json)
            if let reports: [JsonDoc] = json?.getValue(key: "reports") {
                pagedResult?.results = reports.map { GpApiMapping.mapTransactionSummaryReport($0) }
            }
            result = pagedResult
        } else if reportType == .acceptDispute || reportType == .challangeDispute {
            result = GpApiMapping.mapDisputeAction(json)
        } else if reportType == .disputeDocument {
            result = GpApiMapping.mapDocumentMetadata(json)
        } else if reportType == .documentDisputeDetail {
            result = GpApiMapping.mapDisputeDocument(json)
        } else if reportType == .findPayByLinkPaged {
            var pagedResult: PagedResult<PayByLinkSummary>? = getPagedResult(json)
            if let links: [JsonDoc] = json?.getValue(key: "links") {
                let mapped = links.map { PayByLinkSummary.mapFromJson($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        } else if reportType == .payByLinkDetail {
            result = PayByLinkSummary.mapFromJson(json)
        } else if reportType == .authenticationDetail && AuthenticationSummary() is T {
            result = GpApiMapping.mapAuthenticationSummary(json)
        } else if reportType == .findAuthenticationsPaged
                    && PagedResult<AuthenticationSummary>(totalRecordCount: nil, pageSize: 0, page: 0, order: nil, orderBy: nil) is T {
            var pagedResult: PagedResult<AuthenticationSummary>? = getPagedResult(json)
            if let authentications: [JsonDoc] = json?.getValue(key: "authentications") {
                let mapped = authentications.map { GpApiMapping.mapAuthenticationSummary($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        }
        return result as? T
    }
    
    public static func mapUserReportResponse<T>(_ rawResponse: String, _ reportType: ReportType) -> T? {
        var result: Any?
        let json = JsonDoc.parse(rawResponse)
        
        switch reportType {
        case .findMerchantsPaged:
            var pagedResult: PagedResult<MerchantSummary>? = getPagedResult(json)
            if let merchants: [JsonDoc] = json?.getValue(key: "merchants") {
                let mapped = merchants.map { GpApiMapping.mapMerchantSummary($0) }
                pagedResult?.results = mapped
            }
            result = pagedResult
        case .findAccountsPaged:
            var pagedResult: PagedResult<AccountSummary>? = getPagedResult(json)
            if let accounts: [JsonDoc] = json?.getValue(key: "accounts") {
                let mapped: [AccountSummary] = accounts.map { AccountSummary.mapToObject($0)! }
                pagedResult?.results = mapped
            }
            result = pagedResult
        default:
            result = nil
            break
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
    
    public static func mapMerchantResponse<T>(_ rawResponse: String, modifier: TransactionModifier?) -> T? {
        var result: Any?
        let json = JsonDoc.parse(rawResponse) ?? JsonDoc()
        switch modifier {
        case .merchant:
            result = GpApiMapping.mapUser(json)
        case .account:
            result = AccountSummary.mapToObject(json)
        default:
            break
        }
        return result as? T
    }
    
    public static func mapUser(_ doc: JsonDoc?) -> User {
        let user = User()
        let userReference = UserReference()
        userReference.userId = doc?.getValue(key: "id")
        userReference.userStatus = UserStatus(value: doc?.getValue(key: "status"))
        userReference.userType = UserType(value: doc?.getValue(key: "type"))
        user.name = doc?.getValue(key: "name")
        
        if let actionType: String = doc?.get(valueFor: "action")?.getValue(key: "type"), let type = ActionType(value: actionType) {
            switch type {
            case .funds:
                userReference.userId = doc?.getValue(key: "merchant_id")
                user.name = doc?.getValue(key: "merchant_name")
                
                let funds = FundsAccountDetails()
                funds.id = doc?.getValue(key: "id")
                funds.timeCreated = doc?.getValue(key: "time_created")
                funds.timeLastUpdated = doc?.getValue(key: "time_last_updated")
                funds.paymentMethodType = doc?.getValue(key: "type")
                funds.paymentMethodName = doc?.getValue(key: "payment_method")
                funds.status = doc?.getValue(key: "status")
                if let amount: String = doc?.getValue(key: "amount") {
                    funds.amount = NSDecimalNumber(string: amount).amount(for: funds.currency)
                }
                funds.currency = doc?.getValue(key: "currency")
                let userAccount = UserAccount()
                userAccount.id = doc?.getValue(key: "account_id")
                userAccount.name = doc?.getValue(key: "account_name")
                funds.account = userAccount
                user.fundsAccountDetails = funds
                break
            default:
                break
            }
        }
        
        user.userReference = userReference
        user.responseCode = doc?.get(valueFor: "action")?.getValue(key: "result_code")
        user.statusDescription = doc?.getValue(key: "status_description")
        
        if let createdTime: String = doc?.getValue(key: "time_created") {
            user.timeCreated = createdTime
        }
        return user
    }
    public static func mapFileProcessingResponse<T>(_ rawResponse: String) -> T? {
        let json = JsonDoc.parse(rawResponse) ?? JsonDoc()
        return FileProcessor.mapToObject(json)
    }
    
    public static func mapRecurringEntity<T>(_ rawResponse: String) -> T? {
        let json = JsonDoc.parse(rawResponse) ?? JsonDoc()
        return Customer.mapToObject(json)
    }
    
    private static func getPagedResult<T>(_ doc: JsonDoc?) -> PagedResult<T>? {
        guard let doc = doc else { return nil }
        
        var pagedResult = PagedResult<T>(
            totalRecordCount: doc.getValue(keys: "total_record_count", "total_count"),
            pageSize: doc.get(valueFor: "paging")?.getValue(key: "page_size") ?? .zero,
            page: doc.get(valueFor: "paging")?.getValue(key: "page") ?? .zero,
            order: doc.get(valueFor: "paging")?.getValue(key: "order"),
            orderBy: doc.get(valueFor: "paging")?.getValue(key: "order_by")
        )
        pagedResult.currentPageSize = doc.getValue(key: "current_page_size")
        pagedResult.merchantId = doc.getValue(key: "merchant_id")
        pagedResult.merchantName = doc.getValue(key: "merchant_name")
        pagedResult.accountId = doc.getValue(key: "account_id")
        pagedResult.accountName = doc.getValue(key: "account_name")
        pagedResult.filterFromTimeCreated = doc.get(valueFor: "filter")?.getValue(key: "from_time_created")
        pagedResult.filterToTimeCreated = doc.get(valueFor: "filter")?.getValue(key: "to_time_created")
        return pagedResult
    }
    
    private static func mapPayByLinkResponse(_ doc: JsonDoc?) -> PayByLinkResponse {
        let payByLinkResponse = PayByLinkResponse()
        payByLinkResponse.id = doc?.getValue(key: "id")
        payByLinkResponse.accountName = doc?.getValue(key: "account_name")
        payByLinkResponse.url = doc?.getValue(key: "url")
        payByLinkResponse.redirectUrl = doc?.getValue(key: "redirect_url")
        payByLinkResponse.status = PayByLinkStatus(value: doc?.getValue(key: "status"))
        payByLinkResponse.type = PayByLinkType(value: doc?.getValue(key: "type"))
        payByLinkResponse.usageMode = PaymentMethodUsageMode(value: doc?.getValue(key: "usage_mode"))
        
        if let usageLimit: String = doc?.getValue(key: "usage_limit") {
            payByLinkResponse.usageLimit = Int(usageLimit)
        }
        payByLinkResponse.reference = doc?.getValue(key: "reference")
        payByLinkResponse.name = doc?.getValue(key: "name")
        payByLinkResponse.descriptionPayByLink = doc?.getValue(key: "description")
        payByLinkResponse.viewedCount = doc?.getValue(key: "viewed_count")
        payByLinkResponse.expirationDate = doc?.getValue(key: "expiration_date")
        let shippable: String = doc?.getValue(key: "shippable") ?? "NO"
        payByLinkResponse.isShippable = shippable.uppercased() == "YES"
        payByLinkResponse.allowedPaymentMethods = getAllowedPaymentMethods(doc)
        
        let order = doc?.get(valueFor: "order")
        payByLinkResponse.payByLinkOrder = GpApiMapping.payByLinkOrder(order)
        
        let actionSummury = doc?.get(valueFor: "action")
        payByLinkResponse.actionSummary = GpApiMapping.mapActionSummary(actionSummury)
        
        return payByLinkResponse
    }
    
    private static func mapTransferFundAccounts(_ docs: [JsonDoc]) -> [FundsAccountDetails] {
        return docs.map { FundsAccountDetails.mapToObject($0) ?? FundsAccountDetails() }
    }
    
    private static func getAllowedPaymentMethods(_ doc: JsonDoc?) -> [PaymentMethodName]? {
        var list: [PaymentMethodName]?
        
        if let transactions: JsonDoc = doc?.getValue(key: "transactions"), let listPaymentMethods: [String] = transactions.getValue(key: "allowed_payment_methods") {
            
            list = listPaymentMethods.map{ PaymentMethodName(value: $0) ?? .card }
        }
        return list
    }

    private static func parseDate(_ value: String?) -> Date? {
        guard let value = value else {
            return nil
        }

        return value.format()
            ?? value.format("yyyy-MM-dd'T'HH:mm:ssZ")
            ?? value.format("yyyy-MM-dd'T'HH:mm:ss")
            ?? value.format("yyyy-MM-dd")
    }

    private static func mapTransactionSummaryReport(_ doc: JsonDoc?) -> TransactionSummaryReport {
        let report = TransactionSummaryReport()
        report.type = doc?.getValue(key: "type")

        if let summary = doc?.get(valueFor: "summary") {
            report.sales = mapReportAmountInfo(summary.get(valueFor: "sales"))
            report.refunds = mapReportAmountInfo(summary.get(valueFor: "refunds"))
        }

        if let breakdown: [JsonDoc] = doc?.getValue(key: "payment_method_breakdown") {
            report.paymentMethodBreakdown = breakdown.map {
                let item = ReportPaymentMethodBreakdown()
                item.category = PaymentMethodCategory(value: $0.getValue(key: "category"))
                item.brand = $0.getValue(key: "brand")
                item.count = $0.getValue(key: "count")
                if let amount: Int64 = $0.getValue(key: "amount") {
                    item.amount = amount
                }
                if let gratuity: Int = $0.getValue(key: "gratuity_amount") {
                    item.gratuityAmount = gratuity
                }
                item.sales = mapReportAmountInfo($0.get(valueFor: "sales"))
                item.refunds = mapReportAmountInfo($0.get(valueFor: "refunds"))
                item.reversals = mapReportAmountInfo($0.get(valueFor: "reversals"))
                return item
            }
        }

        return report
    }

    private static func mapReportAmountInfo(_ doc: JsonDoc?) -> ReportAmountInfo? {
        guard let doc = doc else { return nil }

        let info = ReportAmountInfo()
        info.count = doc.getValue(key: "count")
        if let amount: String = doc.getValue(key: "amount") {
            info.amount = NSDecimalNumber(string: amount).amount
        }
        return info
    }

    private static func mapBatchAmountInfo(_ doc: JsonDoc?) -> BatchAmountInfo? {
        guard let doc = doc else {
            return nil
        }

        let info = BatchAmountInfo()
        info.count = doc.getValue(key: "count")
        if let amount: String = doc.getValue(key: "amount") {
            info.amount = NSDecimalNumber(string: amount).amount
        }
        return info
    }

    private static func mapBatchBrandBreakdown(_ docs: [JsonDoc]) -> [BatchBrandBreakdown] {
        return docs.map {
            let breakdown = BatchBrandBreakdown()
            breakdown.brand = $0.getValue(key: "brand")
            breakdown.count = $0.getValue(key: "count")

            if let amount: String = $0.getValue(key: "amount") {
                breakdown.amount = NSDecimalNumber(string: amount).amount
            }
            if let gratuity: String = $0.getValue(key: "gratuity_amount") {
                breakdown.gratuityAmount = NSDecimalNumber(string: gratuity).amount
            }

            breakdown.sales = mapBatchAmountInfo($0.get(valueFor: "sales"))
            breakdown.refunds = mapBatchAmountInfo($0.get(valueFor: "refunds"))
            breakdown.fundingDebit = mapBatchAmountInfo($0.get(valueFor: "funding_debit"))
            breakdown.fundingCredit = mapBatchAmountInfo($0.get(valueFor: "funding_credit"))
            return breakdown
        }
    }

    private static func mapBatchHostBreakdown(_ doc: JsonDoc) -> BatchHostBreakdown {
        let breakdown = BatchHostBreakdown()
        breakdown.merchantName = doc.getValue(key: "merchant_name")
        breakdown.reference = doc.getValue(key: "reference")
        breakdown.count = doc.getValue(key: "count")

        if let amount: String = doc.getValue(key: "amount") {
            breakdown.amount = NSDecimalNumber(string: amount).amount
        }

        breakdown.fundingDebit = mapBatchAmountInfo(doc.get(valueFor: "funding_debit"))
        breakdown.fundingCredit = mapBatchAmountInfo(doc.get(valueFor: "funding_credit"))
        return breakdown
    }

    private static func mapBatchAction(_ doc: JsonDoc) -> BatchActionInfo {
        let action = BatchActionInfo()
        action.id = doc.getValue(key: "id")
        action.type = doc.getValue(key: "type")
        action.resultCode = doc.getValue(key: "result_code")
        action.appId = doc.getValue(key: "app_id")
        action.appName = doc.getValue(key: "app_name")
        let created: String? = doc.getValue(key: "time_created")
        action.timeCreated = parseDate(created)
        return action
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
        let bnplResponse = BNPLResponse()
        bnplResponse.redirectUrl = paymentMethod.getValue(key: "redirect_url")
        bnplResponse.providerName = paymentMethod.get(valueFor: "bnpl")?.getValue(key: "provider")
        bnplResponse.result = paymentMethod.get(valueFor: "bnpl")?.getValue(key: "result")
        return bnplResponse
    }
    
    private static func mapCardDetails(_ cardInfo: JsonDoc?) -> Card {
        let cardDetails = Card()
        cardDetails.maskedCardNumber = cardInfo?.getValue(key: "masked_number_first6last4")
        cardDetails.maskedNumberLast4 = cardInfo?.getValue(key: "masked_number_last4")
        cardDetails.maskedNetworkTokenLast4 = cardInfo?.getValue(key: "masked_network_token_last4")
        cardDetails.funding = cardInfo?.getValue(key: "funding")
        cardDetails.brand = cardInfo?.getValue(key: "brand")
        cardDetails.issuer = cardInfo?.getValue(key: "issuer")
        cardDetails.country = cardInfo?.getValue(key: "country")
        cardDetails.currency = cardInfo?.getValue(key: "currency")
        cardDetails.cvvIndicator = cardInfo?.getValue(key: "cvv_indicator")
        cardDetails.cvvResult = cardInfo?.getValue(key: "cvv_result")
        cardDetails.avsAddressResult = cardInfo?.getValue(key: "avs_address_result")
        cardDetails.avsPostalCodeResult = cardInfo?.getValue(key: "avs_postal_code_result")
        return cardDetails
    }
    
    private static func mapThreeDSInfo(_ response: JsonDoc?) -> ThreeDSecure {
        let threeDSecure = ThreeDSecure()
        threeDSecure.serverTransactionId = response?.getValue(key: "id")
        if let threeDS: JsonDoc = response?.get(valueFor: "three_ds") {
            threeDSecure.authenticationValue = threeDS.getValue(key: "value")
            threeDSecure.providerServerTransRef = threeDS.getValue(key: "server_trans_ref")
            threeDSecure.directoryServerTransactionId = threeDS.getValue(key: "ds_trans_ref")
            if let exemptStatusString: String? = threeDS.getValue(key: "exempt_status"), !exemptStatusString.isNilOrEmpty {
                if let exemptStatus = ExemptStatus(rawValue: exemptStatusString?.uppercased() ?? "") {
                    threeDSecure.exemptStatus = exemptStatus
                }
            }
            threeDSecure.cavv = threeDS.getValue(key: "cavv_result")
            threeDSecure.messageVersion = threeDS.getValue(key: "message_version")
            if let eci: String = threeDS.getValue(key: "eci"), let eciValue = Int(eci) {
                threeDSecure.eci = eciValue
            }
            threeDSecure.status = threeDS.getValue(key: "status")
        }
        
        return threeDSecure
    }
    
    private static func setInstallmentData(_ installment: JsonDoc) -> InstallmentData {
        let installmentData = InstallmentData()
        installmentData.program = installment.getValue(key: "program")
        installmentData.mode = installment.getValue(key: "mode")
        installmentData.count = installment.getValue(key: "count")
        installmentData.gracePeriodCount = installment.getValue(key: "grace_period_count")
        return installmentData
    }
    
    public static func MapInstallmentResponse<T>(_ rawResponse: String) -> T? {
        if !rawResponse.isEmpty {
            
            let json = JsonDoc.parse(rawResponse)
            
            let installment = Installment()
            installment.Id = json?.getValue(key: "id")
            let timeCreated: String? = json?.getValue(key: "time_created")
            installment.TimeCreated = timeCreated?.format() ?? timeCreated?.format("yyyy-MM-dd'T'HH:mm:ss")
            installment.Type = json?.getValue(key: "type")
            installment.Status = json?.getValue(key: "status")
            installment.Channel = json?.getValue(key: "channel")
            if let amount: String = json?.getValue(key: "amount") {
                installment.Amount =  Double(amount)
            }
            installment.Currency = json?.getValue(key: "currency")
            installment.Country = json?.getValue(key: "country")
            installment.MerchantId = json?.getValue(key: "merchant_id")
            installment.MerchantName = json?.getValue(key: "merchant_name")
            installment.AccountId = json?.getValue(key: "account_id")
            installment.AccountName = json?.getValue(key: "account_name")
            installment.Reference = json?.getValue(key: "reference")
            installment.Program = json?.getValue(key: "program")
            
            
            if ((json?.has(key: "payment_method")) != nil) {
                if let paymentMethodJson: JsonDoc = json?.get(valueFor: "payment_method") {
                    installment.Result = paymentMethodJson.getValue(key: "result")
                    installment.EntryMode = paymentMethodJson.getValue(key: "entry_mode")
                    installment.Message = paymentMethodJson.getValue(key: "message")
                    
                    if paymentMethodJson.has(key: "card") {
                        if let cardJson: JsonDoc = paymentMethodJson.getValue(key: "card") {
                            let card = Card()
                            card.brand = cardJson.getValue(key: "brand")
                            card.maskedCardNumber = cardJson.getValue(key: "masked_number_last4")
                            card.brandReference = cardJson.getValue(key: "brand_reference")
                            card.category = cardJson.getValue(key: "category")
                            card.avsPostalCode = cardJson.getValue(key: "avs_postal_code")
                            installment.Card = card
                            installment.AuthCode = cardJson.getValue(key: "authcode")
                        }
                    }
                    
                    if ((json?.has(key: "action")) != nil) {
                        if let actionJson: JsonDoc = json?.getValue(key: "action") {
                            let action = Action()
                            action.Type = actionJson.getValue(key: "type")
                            action.Id = actionJson.getValue(key: "id")
                            action.TimeCreated = actionJson.getValue(key: "time_created")
                            action.AppId = actionJson.getValue(key: "app_id")
                            action.AppName = actionJson.getValue(key: "app_name")
                            action.ResultCode = actionJson.getValue(key: "result_code")
                            installment.Action = action
                        }
                    }
                    
                    if ((json?.has(key: "terms")) != nil) {
                        installment.terms = [Terms]()
                        let termItemList: [JsonDoc] = json?.getValue(key: "terms") ?? []
                        for terms in termItemList {
                            let installmentTerm =  Terms()
                            installmentTerm.Id = terms.getValue(key: "id")
                            installmentTerm.TimeUnit = terms.getValue(key: "time_unit")
                            installmentTerm.timeUnitNumbers = terms.getValue(key: "time_unit_numbers")
                            installmentTerm.reference = terms.getValue(key: "reference")
                            installmentTerm.name = terms.getValue(key: "name")
                            installmentTerm.mode = terms.getValue(key: "mode")
                            installmentTerm.count = terms.getValue(key: "count")
                            installmentTerm.gracePeriodCount = terms.getValue(key: "grace_period_count")
                            installment.terms?.append(installmentTerm)
                        }
                    }
                }
            }
            return installment as? T
        }
        return Installment() as? T
    }
    
    public static func payByLinkOrder(_ doc: JsonDoc?) -> PayByLinkOrder {
        let order = PayByLinkOrder()
        order.amount = doc?.getValue(key: "amount")
        order.currency = doc?.getValue(key: "currency")
        order.reference = doc?.getValue(key: "reference")
        let transactionConfiguration =  doc?.get(valueFor: "transaction_configuration")
        order.country = transactionConfiguration?.getValue(key: "country")
        order.channel = transactionConfiguration?.getValue(key: "channel")
        return order
    }
}
