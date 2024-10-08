import Foundation

class GpApiConnector: RestGateway {
    var gpApiConfig: GpApiConfig
    var accessToken: String?
    var supportsHostedPayments: Bool = false

    init(gpApiConfig: GpApiConfig) {
        self.gpApiConfig = gpApiConfig
        super.init()
        headers[GpApiConnector.Header.Key.version]         = GpApiConnector.Header.Value.version
        headers[GpApiConnector.Header.Key.accept]          = GpApiConnector.Header.Value.accept
        headers[GpApiConnector.Header.Key.acceptEnconding] = GpApiConnector.Header.Value.acceptEnconding
        headers[GpApiConnector.Header.Key.versionSdk]      = "iOS;version=\(getVersionSDK())"
        headers[GpApiConnector.Header.Key.versionLibrary]  = "swift;version=\(SwiftLang.getVersion())"

        if let headers = gpApiConfig.dynamicHeaders {
            dynamicHeaders = headers
        }
        self.requestLogger = gpApiConfig.requestLogger
    }

    func signIn(completion: @escaping ((Bool, Error?) -> Void)) {
        getAccessToken { [weak self] response, error in
            
            var accessTokenInfo = self?.gpApiConfig.accessTokenInfo
            if let accessTokenInfo = accessTokenInfo, let token = accessTokenInfo.token, !token.isEmpty {
                self?.headers[GpApiConnector.Header.Key.authorization] = "Bearer \(token)"
                completion(true, nil)
                return
            }
            
            guard let response = response else {
                completion(false, error)
                return
            }
            
            let token = response.token ?? .empty
            
            self?.accessToken = token
            self?.headers[GpApiConnector.Header.Key.authorization] = "Bearer \(token)"
            
            if accessTokenInfo == nil {
                accessTokenInfo = AccessTokenInfo()
            }
            
            if accessTokenInfo?.token.isNilOrEmpty ??  true {
                accessTokenInfo?.token = token
            }
            
            if let dataAccountId = accessTokenInfo?.dataAccountID, dataAccountId.isEmpty {
                accessTokenInfo?.dataAccountID = response.dataAccountID
            }
            
            if accessTokenInfo?.tokenizationAccountName?.isEmpty ?? true, accessTokenInfo?.tokenizationAccountID?.isEmpty ?? true {
                accessTokenInfo?.tokenizationAccountID = response.tokenizationAccountID
            }
            
            if accessTokenInfo?.transactionProcessingAccountName?.isEmpty ?? true, accessTokenInfo?.transactionProcessingAccountID?.isEmpty ?? true {
                accessTokenInfo?.transactionProcessingAccountID = response.TransactionProcessingAccountID
            }
             
            if accessTokenInfo?.disputeManagementAccountName?.isEmpty ?? true, accessTokenInfo?.disputeManagementAccountID?.isEmpty ?? true {
                accessTokenInfo?.disputeManagementAccountID = response.disputeManagementAccountID
            }
            
            if accessTokenInfo?.riskAssessmentAccountName?.isEmpty ?? true, accessTokenInfo?.riskAssessmentAccountID?.isEmpty ?? true {
                accessTokenInfo?.riskAssessmentAccountID = response.riskAssessmentAccountID
            }
            
            if accessTokenInfo?.fileProcessingAccountName?.isEmpty ?? true, accessTokenInfo?.fileProcessingAccountID?.isEmpty ?? true {
                accessTokenInfo?.fileProcessingAccountID = response.fileProcessingAccountID
            }
            
            self?.gpApiConfig.accessTokenInfo = accessTokenInfo

            completion(true, nil)
        }
    }

    func signOut() { }

    func getAccessToken(_ completion: @escaping ((GpApiTokenResponse?, Error?) -> Void)) {
        headers.removeValue(forKey: GpApiConnector.Header.Key.authorization)
        accessToken = nil

        guard let request = gpApiConfig.accessTokenProvider?.signIn(
            appId: gpApiConfig.appId,
            appKey: gpApiConfig.appKey,
            secondsToExpire: gpApiConfig.secondsToExpire,
            intervalToExpire: gpApiConfig.intervalToExpire,
            permissions: gpApiConfig.permissions
        ) else { return completion(nil, ApiException(message: "Access token provider can't be nil!"))}

        super.doTransaction(method: request.method, endpoint: request.endpoint, data: request.requestBody) { response, error in
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
                                                 queryStringParams: [String: String]? = nil,
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
                       queryStringParams: [String: String]? = nil,
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
                   gatewayError.responseCode == "NOT_AUTHENTICATED" ||
                    gatewayError.responseCode == "401" &&
                    !self.gpApiConfig.appId.isEmpty &&
                    !self.gpApiConfig.appKey.isEmpty {
                    
                    if (self.gpApiConfig.accessTokenInfo?.token != nil) {
                        self.gpApiConfig.accessTokenInfo?.token = nil
                    }

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
            if let parsed = JsonDoc.parse(response.rawResponse), parsed.has(key: "error_code") {

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
}

// MARK: - PaymentGateway

extension GpApiConnector: PaymentGateway {

    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?, Error?) -> Void)?) {

        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }

            let requestBuilder = GpApiAuthorizationRequestBuilder()
            guard let request = requestBuilder.generateRequest(for: builder, config: self?.gpApiConfig) else {
                completion?(nil, ApiException(message: "Operation not supported"))
                return
            }

            self?.doTransaction(method: request.method,
                                endpoint: request.endpoint,
                                data: request.requestBody,
                                idempotencyKey: builder.idempotencyKey) { response, error in
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                let doc = JsonDoc.parse(response)
                let transaction = GpApiMapping.mapTransaction(doc)
                completion?(transaction, nil)
            }
        }
    }

    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?, Error?) -> Void)?) {

        let requestBuilder = GpApiManagementRequestBuilder()
        guard let request = requestBuilder.generateRequest(for: builder, config: self.gpApiConfig) else {
            completion?(nil, ApiException(message: "Operation not supported"))
            return
        }

        doTransaction(method: request.method,
                      endpoint: request.endpoint,
                      data: request.requestBody,
                      idempotencyKey: builder.idempotencyKey,
                      queryStringParams: request.queryParams) { response, error in

            guard let response = response else {
                completion?(nil, error)
                return
            }
            let doc = JsonDoc.parse(response)
            let transaction = GpApiMapping.mapTransaction(doc)
            completion?(transaction, nil)
        }
    }

    func serializeRequest(_ builder: AuthorizationBuilder) -> String? {
        return nil
    }

    private func getVersionSDK() -> String {
        if let version = Bundle(identifier: "org.cocoapods.GlobalPayments-iOS-SDK")?.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
}

// MARK: - ReportingServiceType

extension GpApiConnector: ReportingServiceType {

    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?, Error?) -> Void)?) {

        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }

            if let builder = builder as? TransactionReportBuilder<T> {
                let requestBuilder = GpApiReportRequestBuilder<T>()
                guard let request = requestBuilder.generateRequest(for: builder, config: self?.gpApiConfig) else {
                    completion?(nil, ApiException(message: "Operation not supported"))
                    return
                }

                self?.doTransaction(
                    method: request.method,
                    endpoint: request.endpoint,
                    data: request.requestBody,
                    idempotencyKey: builder.idempotencyKey,
                    queryStringParams: request.queryParams) { response, error in
                    if let error = error {
                        completion?(nil, error)
                        return
                    }
                    guard let response = response else {
                        completion?(nil, error)
                        return
                    }

                    completion?(GpApiMapping.mapReportResponse(response, builder.reportType), nil)
                }
            } else if let builder = builder as? UserReportBuilder<T> {
                let requestBuilder = GpApiReportRequestBuilder<T>()
                guard let request = requestBuilder.generateRequest(for: builder, config: self?.gpApiConfig) else {
                    completion?(nil, ApiException(message: "Operation not supported"))
                    return
                }
                
                self?.doTransaction(
                    method: request.method,
                    endpoint: request.endpoint,
                    data: request.requestBody,
                    queryStringParams: request.queryParams) { response, error in
                        if let error = error {
                            completion?(nil, error)
                            return
                        }
                        guard let response = response else {
                            completion?(nil, error)
                            return
                        }
                        
                        completion?(GpApiMapping.mapUserReportResponse(response, builder.reportType), nil)
                    }
            } else {
                completion?(nil, ApiException(message: "Operation not supported"))
            }
        }
    }
}

// MARK: - Secure3dProvider

extension GpApiConnector: Secure3dProvider {

    var version: Secure3dVersion {
        .any
    }

    func processSecure3d(_ builder: Secure3dBuilder, _ completion: @escaping (Transaction?, Error?) -> Void) {

        verifyAuthentication { [weak self] error in
            if let error = error {
                completion(nil, error)
                return
            }

            let requestBuilder = GpApiSecure3dRequestBuilder()
            guard let request = requestBuilder.generateRequest(for: builder, config: self?.gpApiConfig) else {
                completion(nil, ApiException(message: "Operation not supported"))
                return
            }

            self?.doTransaction(method: request.method,
                                endpoint: request.endpoint,
                                data: request.requestBody,
                                idempotencyKey: builder.idempotencyKey) { response, error in
                guard let response = response else {
                    completion(nil, error)
                    return
                }
                let doc = JsonDoc.parse(response)
                let transaction = GpApiMapping.mapThreeDSecure(doc)
                completion(transaction, nil)
            }
        }
    }
}

extension GpApiConnector: PayFacServiceType {
    
    func processPayFac<T>(builder: PayFacBuilder<T>, completion: ((T?, Error?) -> Void)?) {
        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }
            
            let request: GpApiRequest? = GpApiPayFacRequestBuilder<T>().buildRequest(for: builder, config: self?.gpApiConfig)
            
            if let request = request {
                self?.doTransaction(
                    method: request.method,
                    endpoint: request.endpoint,
                    data: request.requestBody,
                    idempotencyKey: builder.idempotencyKey) { response, error in
                        guard let response = response else {
                            completion?(nil, error)
                            return
                        }
                        completion?(GpApiMapping.mapMerchantResponse(response, modifier: builder.transactionModifier), nil)
                    }
            }
        }
    }
    
    func processBoardingUser<T>(builder: PayFacBuilder<T>, completion: ((T?, Error?) -> Void)?) {
        
        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }
            
            let request: GpApiRequest? = GpApiPayFacRequestBuilder<T>().buildRequest(for: builder, config: self?.gpApiConfig)
            
            if let request = request {
                self?.doTransaction(
                    method: request.method,
                    endpoint: request.endpoint,
                    data: request.requestBody,
                    idempotencyKey: builder.idempotencyKey) { response, error in
                        guard let response = response else {
                            completion?(nil, error)
                            return
                        }
                        completion?(GpApiMapping.mapMerchantResponse(response, modifier: builder.transactionModifier), nil)
                    }
            }
        }
    }
}

extension GpApiConnector: FileProcessingType {
    
    func processFileUpload<T>(builder: FileProcessingBuilder<T>, completion: ((T?, Error?) -> Void)?) {
        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }
            
            let request: GpApiRequest? = GpApiFileProcessingRequestBuilder<T>().buildRequest(for: builder, config: self?.gpApiConfig)
            
            if let request = request {
                self?.doTransaction(
                    method: request.method,
                    endpoint: request.endpoint,
                    data: request.requestBody) { response, error in
                        guard let response = response else {
                            completion?(nil, error)
                            return
                        }
                        completion?(GpApiMapping.mapFileProcessingResponse(response), nil)
                    }
            }
        }
    }
}

extension GpApiConnector: RecurringServiceType {
    
    func processRecurring<T>(builder: RecurringBuilder<T>, completion: ((T?, (any Error)?) -> Void)?) {
        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }
            let request: GpApiRequest? = GpApiRecurringRequestBuilder<T>().buildRequest(for: builder, config: self?.gpApiConfig)
            
            if let request = request {
                self?.doTransaction(
                    method: request.method,
                    endpoint: request.endpoint,
                    data: request.requestBody) { response, error in
                        guard let response = response else {
                            completion?(nil, error)
                            return
                        }
                        completion?(GpApiMapping.mapRecurringEntity(response), nil)
                    }
            }
        }
    }
    
    var supportsRetrieval: Bool {
        return false
    }
    
    var supportsUpdatePaymentDetails: Bool {
        return false
    }
    
}

// MARK: - Constants

extension GpApiConnector {

    struct Header {

        struct Key {
            static let version: String = "X-GP-Version"
            static let idempotency: String = "x-gp-idempotency"
            static let accept: String = "Accept"
            static let acceptEnconding: String = "Accept-Encoding"
            static let authorization: String = "Authorization"
            static let versionSdk: String = "x-gp-sdk"
            static let versionLibrary: String = "x-gp-library"
        }

        struct Value {
            static let version: String = "2021-03-22"
            static let accept: String = "application/json"
            static let acceptEnconding: String = "gzip"
        }
    }
}
