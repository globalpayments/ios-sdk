import Foundation

class GpApiConnector: RestGateway, PaymentGateway, IReportingService {
    var appId: String = .empty
    var appKey: String = .empty
    var secondsToExpire: Int?
    var intervalToExpire: IntervalToExpire?
    var channel: Channel?
    var language: Language?
    var sessionToken: String?
    var dataAccountName: String?
    var disputeManagementAccountName: String?
    var tokenizationAccountName: String?
    var transactionProcessingAccountName: String?
    var supportsHostedPayments: Bool = false

    override init() {
        super.init()
        // Set required api version header
        headers["X-GP-Version"] = "2020-04-10"; //"2020-01-20";
        headers["Accept"] = "application/json";
        headers["Accept-Encoding"] = "gzip";
    }

    func signIn(completion: @escaping ((Bool, Error?) -> Void)) {
        sendAccessTokenRequest() { [weak self] response, error in
            guard let response = response,
                let token = response.token else {
                    completion(false, error)
                    return
            }
            self?.dataAccountName = response.dataAccountName
            self?.disputeManagementAccountName = response.disputeManagementAccountName
            self?.tokenizationAccountName = response.tokenizationAccountName
            self?.transactionProcessingAccountName = response.transactionProcessingAccountName
            self?.sessionToken = token
            self?.headers["Authorization"] = "Bearer \(token)"
            completion(true, nil)
        }
    }

    private func sendAccessTokenRequest(_ completion: @escaping ((GpApiTokenResponse?, Error?) -> Void)) {
        headers.removeValue(forKey: "Authorization")
        sessionToken = nil

        let request = SessionInfo.signIn(appId: appId, appKey: appKey, secondsToExpire: secondsToExpire, intervalToExpire: intervalToExpire)

        super.doTransaction(method: .post,
                            endpoint: request.endpoint,
                            data: request.requestBody) { response, error in
                                guard let response = response else {
                                    completion(nil, error)
                                    return
                                }
                                let tokenResponse = GpApiTokenResponse(response)
                                completion(tokenResponse, nil)
        }
    }

    func signOut() { }

    override func doTransaction(method: HTTPMethod,
                                endpoint: String,
                                data: String? = nil,
                                queryStringParams: [String : String]? = nil,
                                completion: @escaping (String?, Error?) -> Void) {
        guard let sessionToken = sessionToken, !sessionToken.isEmpty else {
            signIn { success, error in
                guard success else {
                    completion(nil, error)
                    return
                }
                super.doTransaction(method: method,
                                    endpoint: endpoint,
                                    data: data,
                                    queryStringParams: queryStringParams,
                                    completion: completion)
            }
            return
        }
        super.doTransaction(method: method,
                            endpoint: endpoint,
                            data: data,
                            queryStringParams: queryStringParams,
                            completion: completion)
    }

    override func handleResponse(response: GatewayResponse?,
                                 error: Error?,
                                 completion: @escaping (String?, Error?) -> Void) {
        guard let response = response else {
            completion(nil, error)
            return
        }
        if response.statusCode != 200 && response.statusCode != 204 {
            if let parsed = JsonDoc.parse(response.rawResponse),
                parsed.has(key: "error_code") {

                let errorCode: String = parsed.getValue(key: "error_code") ?? .empty
                let detailedErrorCode: String = parsed.getValue(key: "detailed_error_code") ?? .empty
                let detailedErrorDescription: String = parsed.getValue(key: "detailed_error_description") ?? .empty
                completion(nil, GatewayException.generic(
                    responseCode: Int(errorCode) ?? .zero,
                    responseMessage: "\(String(describing: detailedErrorCode)) - \(String(describing: detailedErrorDescription))"
                    )
                )
                return
            }
            completion(nil, GatewayException.generic(
                responseCode: response.statusCode,
                responseMessage: response.rawResponse
                )
            )
            return
        }
        completion(response.rawResponse, nil)
    }

    private func entryMode(for builder: AuthorizationBuilder) -> String {
        if let card = builder.paymentMethod as? CardData {
            if card.readerPresent {
                return card.cardPresent ? "MANUAL" : "IN_APP"
            } else {
                return card.cardPresent ? "MANUAL" : "ECOM"
            }
        } else if let track = builder.paymentMethod as? TrackData {
            if builder.tagData != nil {
                return track.entryMethod == .swipe ? "CHIP" : "CONTACTLESS_CHIP"
            } else if builder.hasEmvFallbackData {
                return "CONTACTLESS_SWIPE"
            }
            return "SWIPE"
        }
        return "ECOM"
    }

    private func captureMode(for builder: AuthorizationBuilder) -> String {
        if builder.multiCapture {
            return "MULTIPLE"
        } else if builder.transactionType == .auth {
            return "LATER"
        }
        return "AUTO"
    }

    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?, Error?) -> Void)?) {

        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }

            let paymentMethod = JsonDoc()
            paymentMethod.set(for: "entry_mode", value: self?.entryMode(for: builder))

            if let cardData = builder.paymentMethod as? CardData {
                let card = JsonDoc()
                    .set(for: "number", value: cardData.number)
                    .set(for: "expiry_month", value: cardData.expMonth > .zero ? "\(cardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : nil)
                    .set(for: "expiry_year", value: cardData.expYear > .zero ? "\(cardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : nil)
                    //                .set(for: "track", value: "")
                    .set(for: "tag", value: builder.tagData)
                    .set(for: "cvv", value: cardData.cvn)
                    .set(for: "avs_address", value: builder.billingAddress?.streetAddress1)
                    .set(for: "avs_postal_code", value: builder.billingAddress?.postalCode)
                    .set(for: "funding", value: builder.paymentMethod?.paymentMethodType == .debit ? "DEBIT" : "CREDIT")
                    .set(for: "authcode", value: builder.offlineAuthCode)
                //                .set(for: "brand_reference", value: "")

                if builder.transactionType == .verify {
                    if let requestMultiUseToken = builder.requestMultiUseToken,
                        requestMultiUseToken == true {

                        let tokenizationData = JsonDoc()
                            .set(for: "account_name", value: self?.tokenizationAccountName)
                            .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
                            .set(for: "name", value: "")
                            .set(for: "card", doc: card)

                        self?.doTransaction(
                            method: .post,
                            endpoint: "/ucp/payment-methods",
                            data: tokenizationData.toString()) { [weak self] response, error in
                                guard let tokenizationResponse = response else {
                                    completion?(nil, error)
                                    return
                                }
                                if let transaction = self?.mapResponse(tokenizationResponse) {
                                    completion?(transaction, nil)
                                    return
                                }
                                completion?(nil, error)
                                return
                        }
                        return
                    } else {

                        self?.doTransaction(
                            method: .get,
                            endpoint: "/ucp/payment-methods/\((builder.paymentMethod as? Tokenizable)?.token ?? .empty)") { [weak self] response, error in
                                guard let tokenizationResponse = response else {
                                    completion?(nil, error)
                                    return
                                }
                                if let transaction = self?.mapResponse(tokenizationResponse) {
                                    completion?(transaction, nil)
                                    return
                                }
                                completion?(nil, error)
                                return
                        }
                        return
                    }
                }

                if builder.emvLastChipRead != nil {
                    card.set(for: "chip_condition", value: builder.emvLastChipRead?.mapped(for: .gpApi)) // [PREV_SUCCESS, PREV_FAILED]
                }

                if cardData.cvnPresenceIndicator == .present ||
                    cardData.cvnPresenceIndicator == .illegible ||
                    cardData.cvnPresenceIndicator == .notOnCard {
                    card.set(for: "cvv_indicator", value: cardData.cvnPresenceIndicator.mapped(for: .gpApi)) // [ILLEGIBLE, NOT_PRESENT, PRESENT]
                }

                paymentMethod.set(for: "card", doc: card)

            } else if let track = builder.paymentMethod as? TrackData {
                let card = JsonDoc()
                    .set(for: "track", value: track.value)
                    .set(for: "tag", value: builder.tagData)
                    //                .set(for: "cvv", value: "")
                    //                .set(for: "cvv_indicator", value: "")
                    .set(for: "avs_address", value: builder.billingAddress?.streetAddress1)
                    .set(for: "avs_postal_code", value: builder.billingAddress?.postalCode)
                    .set(for: "authcode", value: builder.offlineAuthCode)
                //                .set(for: "brand_reference", value: "")
                if builder.transactionType == .sale {
                    card.set(for: "number", value: track.pan)
                    card.set(for: "expiry_month", value: track.expiry!.substring(with: 2..<4))
                    card.set(for: "expiry_year", value: track.expiry!.substring(with: 0..<2))
                    card.set(for: "chip_condition", value: builder.emvLastChipRead?.mapped(for: .gpApi))
                    card.set(for: "funding", value: builder.paymentMethod?.paymentMethodType == .debit ? "DEBIT" : "CREDIT")
                }

                paymentMethod.set(for: "card", doc: card)
            }

            // Tokenized Payment Method
            if let tokenizable = builder.paymentMethod as? Tokenizable,
                let token = tokenizable.token, !token.isEmpty {
                paymentMethod.set(for: "id", value: token)
            }

            // PIN Block
            if let pinProtected = builder.paymentMethod as? PinProtected {
                paymentMethod
                    .get(valueFor: "card")?
                    .set(for: "pin_block", value: pinProtected.pinBlock)
            }

            // Authentication
            if let creditCardData = builder.paymentMethod as? CreditCardData {
                paymentMethod.set(for: "name", value: creditCardData.cardHolderName)

                if let secureEcom = creditCardData.threeDSecure {
                    let authentication = JsonDoc()
                        .set(for: "xid", value: secureEcom.xid)
                        .set(for: "cavv", value: secureEcom.cavv)
                        .set(for: "eci", value: String(secureEcom.eci ?? .zero))
                    //                    .set(for: "mac", value: "") //A message authentication code submitted to confirm integrity of the request.
                    paymentMethod.set(for: "authentication", doc: authentication)
                }
            }

            // Encryption
            if let encryptable = builder.paymentMethod as? Encryptable,
                let encryptionData = encryptable.encryptionData {
                let encryption = JsonDoc()
                    .set(for: "version", value: encryptionData.version)
                if !encryptionData.ktb.isNilOrEmpty {
                    encryption.set(for: "method", value: "KTB")
                    encryption.set(for: "info", value: encryptionData.ktb)
                } else if !encryptionData.ksn.isNilOrEmpty {
                    encryption.set(for: "method", value: "KSN")
                    encryption.set(for: "info", value: encryptionData.ksn)
                }

                if encryption.has(key: "info") {
                    paymentMethod.set(for: "encryption", doc: encryption)
                }
            }

            let data = JsonDoc()
                .set(for: "account_name", value: self?.transactionProcessingAccountName)
                .set(for: "type", value: builder.transactionType == .refund ? "REFUND" : "SALE")
                .set(for: "channel", value: self?.channel?.mapped(for: .gpApi))
                .set(for: "capture_mode", value: self?.captureMode(for: builder))
                //            .set(for: "remaining_capture_count", value: "") //Pending Russell
                .set(for: "authorization_mode", value: builder.allowPartialAuth ? "PARTIAL" : "WHOLE")
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
                .set(for: "currency", value: builder.currency)
                .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
                .set(for: "description", value: builder.requestDescription)
                .set(for: "order_reference", value: builder.orderId)
                //            .set(for: "initiator", value: "")// [PAYER, MERCHANT] //default to PAYER
                .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString())
                .set(for: "cashback_amount", value: builder.cashBackAmount?.toNumericCurrencyString())
                .set(for: "surcharge_amount", value: builder.surchargeAmount?.toNumericCurrencyString())
                .set(for: "convenience_amount", value: builder.convenienceAmount?.toNumericCurrencyString())
                .set(for: "country", value: builder.billingAddress?.country ?? "US")
                //            .set(for: "language", value: language?.mapped(for: .gpApi))
                .set(for: "ip_address", value: builder.customerIpAddress)
                //            .set(for: "site_reference", value: "")
                .set(for: "payment_method", doc: paymentMethod)

            self?.doTransaction(method: .post,
                                endpoint: "/ucp/transactions",
                                data: data.toString()) { [weak self] response, error in
                                    guard let response = response else {
                                        completion?(nil, error)
                                        return
                                    }
                                    if let transaction = self?.mapResponse(response) {
                                        completion?(transaction, nil)
                                        return
                                    }
                                    completion?(nil, error)
                                    return
            }
        }
    }

    private func verifyAuthentication(_ completion: @escaping (Error?) -> Void) {
        if sessionToken.isNilOrEmpty {
            signIn { _, error in
                completion(error)
            }
        } else {
            completion(nil)
        }
    }

    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?) -> Void)?) {

        if builder.transactionType == .capture {
            let data = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
                .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString())
            doTransaction(
                method: .post,
                endpoint: "/ucp/transactions/\(builder.transactionId ?? .empty)/capture",
                data: data.toString()
            ) { [weak self] response, _ in
                guard let response = response else {
                    completion?(nil)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction)
            }
        } else if builder.transactionType == .refund {
            let data = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            doTransaction(
                method: .post,
                endpoint: "/ucp/transactions/\(builder.transactionId ?? .empty)/refund",
                data: data.toString()
            ) { [weak self] response, _ in
                guard let response = response else {
                    completion?(nil)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction)
            }
        } else if builder.transactionType == .reversal {
            let data = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            doTransaction(
                method: .post,
                endpoint: "/ucp/transactions/\(builder.transactionId ?? .empty)/reversal",
                data: data.toString()
            ) { [weak self] response, _ in
                guard let response = response else {
                    completion?(nil)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction)
            }
        } else if let creditCardData = builder.paymentMethod as? CreditCardData, builder.transactionType == .tokenUpdate {

            let card = JsonDoc()
                .set(for: "expiry_month", value: creditCardData.expMonth > .zero ? "\(creditCardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : .empty)
                .set(for: "expiry_year", value: creditCardData.expYear > .zero ? "\(creditCardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : .empty)

            let payload = JsonDoc()
                .set(for: "card", doc: card)

            doTransaction(
                method: .patch,
                endpoint: "/ucp/payment-methods/\((builder.paymentMethod as? Tokenizable)?.token ?? .empty)/edit",
                data: payload.toString()
            ) { [weak self] response, error in
                guard let response = response else {
                    completion?(nil)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction)
            }
        } else if let tokenizable = builder.paymentMethod as? Tokenizable,
            builder.transactionType == .tokenDelete {

            doTransaction(
                method: .post,
                endpoint: "/ucp/payment-methods/\(tokenizable.token ?? .empty)/delete"
            ) { [weak self] response, _ in
                guard let response = response else {
                    completion?(nil)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction)
            }
        } else if let detokenizable = builder.paymentMethod as? Tokenizable,
            builder.transactionType == .detokenize {

            doTransaction(
                method: .post,
                endpoint: "/ucp/payment-methods/\(detokenizable.token ?? .empty)/detokenize"
            ) { [weak self] response, _ in
                guard let response = response else {
                    completion?(nil)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction)
            }
        }
    }

    private func mapResponse(_ rawResponse: String) -> Transaction {
        let json = JsonDoc.parse(rawResponse)

        let transaction = Transaction()
        transaction.transactionId = json?.getValue(key: "id")
        if let amount: String = json?.getValue(key: "amount"), !amount.isEmpty {
            transaction.balanceAmount = NSDecimalNumber(string: amount).amount
        }
        transaction.timestamp = json?.getValue(key: "time_created")
        transaction.responseMessage = json?.getValue(key: "status")
        transaction.referenceNumber = json?.getValue(key: "reference")
        let batchSummary = BatchSummary()
        batchSummary.sequenceNumber = json?.getValue(key: "batch_id")
        transaction.batchSummary = batchSummary
        transaction.responseCode = json?.get(valueFor: "action")?.getValue(key: "result_code")
        transaction.token = json?.getValue(key: "id")

        if let paymentMethod: JsonDoc = json?.get(valueFor: "payment_method"),
            let card: JsonDoc = paymentMethod.get(valueFor: "card") {
            transaction.cardLast4 = card.getValue(key: "masked_number_last4")
        }

        if let card: JsonDoc = json?.get(valueFor: "card") {
            transaction.cardExpMonth = Int(card.getValue(key: "expiry_month") ?? .empty)
            transaction.cardExpYear = Int(card.getValue(key: "expiry_year") ?? .empty)
            transaction.cardNumber = card.getValue(key: "number")
            transaction.cardType = card.getValue(key: "brand")
        }

        return transaction
    }

    func serializeRequest(_ builder: AuthorizationBuilder) -> String? {
        print("Not implemented yet")
        abort()
    }

    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?, Error?) -> Void)?) {
        var reportUrl = "/ucp/transactions"
        var queryStringParams = [String: String]()

        if let builder = builder as? TransactionReportBuilder<T> {
            if builder.reportType == .transactionDetail,
                let transactionId = builder.transactionId {
                reportUrl += "/\(transactionId)"
            } else if builder.reportType == .findTransactions {
                queryStringParams["PAGE"] = String(builder.page ?? .zero)
                queryStringParams["PAGE_SIZE"] = String(builder.pageSize ?? .zero)
                queryStringParams["ORDER_BY"] = builder.orderProperty?.mapped(for: .gpApi)
                queryStringParams["ORDER"] = builder.orderDirection?.mapped(for: .gpApi)
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
        }

        doTransaction(
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
        }

        return result
    }

    private func mapTransactionSummary(_ doc: JsonDoc?) -> TransactionSummary {
        let paymentMethod = doc?.get(valueFor: "payment_method")
        let card = paymentMethod?.get(valueFor: "card")

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
}
