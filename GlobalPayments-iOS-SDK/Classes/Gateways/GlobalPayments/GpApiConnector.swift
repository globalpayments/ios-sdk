import Foundation

class GpApiConnector: RestGateway, PaymentGateway {
    var appId: String = .empty
    var appKey: String = .empty
    var secondsToExpire: Int?
    var intervalToExpire: IntervalToExpire?
    var channel: Channel?
    var language: Language?
    var country: String?
    var supportsHostedPayments: Bool = false
    var accessToken: String?
    var dataAccountName: String?
    var disputeManagementAccountName: String?
    var tokenizationAccountName: String?
    var transactionProcessingAccountName: String?

    override init() {
        super.init()
        // Set required api version header
        headers[GpApiConnector.Header.Key.version]         = GpApiConnector.Header.Value.version
        headers[GpApiConnector.Header.Key.accept]          = GpApiConnector.Header.Value.accept
        headers[GpApiConnector.Header.Key.acceptEnconding] = GpApiConnector.Header.Value.acceptEnconding
    }

    func signIn(completion: @escaping ((Bool, Error?) -> Void)) {
        getAccessToken() { [weak self] response, error in
            guard let response = response,
                  let token = response.token else {
                completion(false, error)
                return
            }
            self?.dataAccountName = response.dataAccountName
            self?.disputeManagementAccountName = response.disputeManagementAccountName
            self?.tokenizationAccountName = response.tokenizationAccountName
            self?.transactionProcessingAccountName = response.transactionProcessingAccountName
            self?.accessToken = token
            self?.headers[GpApiConnector.Header.Key.authorization] = "Bearer \(token)"
            completion(true, nil)
        }
    }

    func signOut() { }

    func getAccessToken(_ completion: @escaping ((GpApiTokenResponse?, Error?) -> Void)) {
        headers.removeValue(forKey: GpApiConnector.Header.Key.authorization)
        accessToken = nil

        let request = GpApiSessionInfo.signIn(appId: appId, appKey: appKey, secondsToExpire: secondsToExpire, intervalToExpire: intervalToExpire)

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

    private func doTransactionWithIdempotencyKey(method: HTTPMethod,
                                                 endpoint: String,
                                                 data: String? = nil,
                                                 idempotencyKey: String? = nil,
                                                 queryStringParams: [String : String]? = nil,
                                                 completion: @escaping (String?, Error?) -> Void) {

        if !idempotencyKey.isNilOrEmpty {
            headers[GpApiConnector.Header.Key.idempotency] = idempotencyKey
        }

        super.doTransaction(
            method: method,
            endpoint: endpoint,
            data: data,
            queryStringParams: queryStringParams) { [weak self] response, error in
            self?.headers.removeValue(forKey: GpApiConnector.Header.Key.idempotency)
            completion(response, error)
        }
    }

    func doTransaction(method: HTTPMethod,
                       endpoint: String,
                       data: String? = nil,
                       idempotencyKey: String? = nil,
                       queryStringParams: [String : String]? = nil,
                       completion: @escaping (String?, Error?) -> Void) {


        verifyAuthentication { error in

            if let error = error {
                completion(nil, error)
                return
            }

            self.doTransactionWithIdempotencyKey(
                method: method,
                endpoint: endpoint,
                data: data,
                idempotencyKey: idempotencyKey,
                queryStringParams: queryStringParams) { response, error in

                if let gatewayError = error as? GatewayException,
                   gatewayError.responseCode == "NOT_AUTHENTICATED" {

                    self.signIn { _, _ in

                        self.doTransactionWithIdempotencyKey(
                            method: method,
                            endpoint: endpoint,
                            data: data,
                            idempotencyKey: idempotencyKey,
                            queryStringParams: queryStringParams,
                            completion: completion
                        )
                    }
                    return
                }

                completion(response, error)
            }
        }
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

                let exception = GatewayException(
                    message: "Status Code: \(response.statusCode) - \(String(describing: detailedErrorDescription))",
                    responseCode: errorCode,
                    responseMessage: detailedErrorCode
                )
                completion(nil, exception)
                return
            }
            completion(nil,
                       GatewayException(
                        responseCode: "Status Code: \(response.statusCode)",
                        responseMessage: response.rawResponse
                       )
            )
            return
        }
        completion(response.rawResponse, nil)
    }

    func verifyAuthentication(_ completion: @escaping (Error?) -> Void) {
        if accessToken.isNilOrEmpty {
            signIn { _, error in
                completion(error)
            }
        } else {
            completion(nil)
        }
    }

    func mapResponse(_ rawResponse: String) -> Transaction {
        let json = JsonDoc.parse(rawResponse)

        let transaction = Transaction()
        transaction.transactionId = json?.getValue(key: "id")
        transaction.balanceAmount = NSDecimalNumber(string: json?.getValue(key: "amount")).amount
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
            transaction.cardExpMonth = Int(card.getValue(key: "expiry_month") ?? .empty)
            transaction.cardExpYear = Int(card.getValue(key: "expiry_year") ?? .empty)
            transaction.cardNumber = card.getValue(key: "number")
            transaction.cardType = card.getValue(key: "brand")
        }

        return transaction
    }
}
