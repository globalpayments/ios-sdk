import Foundation

class PorticoConnector: XmlGateway {

    var supportsHostedPayments: Bool = false
    var porticoConfig: PorticoConfig
    
    init(porticoConfig: PorticoConfig) {
        self.porticoConfig = porticoConfig
        super.init()
        self.requestLogger = porticoConfig.requestLogger
    }
}

extension PorticoConnector: PaymentGateway {
    
    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?, Error?) -> Void)?) {
        let requestBuilder = PorticoAuthorizationRequestBuilder()
        
        guard let requestType = requestBuilder.mapRequestType(builder) else {
            completion?(nil, ApiException(message: "Operation not supported"))
            return
        }
        
        guard let request = requestBuilder.generateRequest(for: builder, config: self.porticoConfig) else {
            completion?(nil, ApiException(message: "Operation not supported"))
            return
        }
        
        super.doTransaction(endpoint: request.endpoint,
                            method: .post,
                            request: request.request) { response, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            guard let response = response else {
                completion?(nil, error)
                return
            }
            // Map XML response to Transaction
            let parser = PorticoXmlResponseParser(xml: response)
            let transaction = Transaction()
            _ = parser.parse(requestType: requestType)
            PorticoXmlApiMapping.mapTransaction(parser, transaction)
            completion?(transaction, nil)
        }
    }
    
    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?, Error?) -> Void)?) {
        let requestBuilder = PorticoManagementRequestBuilder()
        guard let requestType = requestBuilder.mapRequestType(builder) else {
            completion?(nil, ApiException(message: "Operation not supported"))
            return
        }
        guard let request = requestBuilder.generateRequest(for: builder, config: self.porticoConfig) else {
            completion?(nil, ApiException(message: "Operation not supported"))
            return
        }
        
        super.doTransaction(endpoint: request.endpoint,
                            method: .post,
                            request: request.request) { response, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            guard let response = response else {
                completion?(nil, error)
                return
            }
            
            // Map XML response to Transaction
            let parser = PorticoXmlResponseParser(xml: response)
            let transaction = Transaction()
            _ = parser.parse(requestType: requestType)
            PorticoXmlApiMapping.mapTransaction(parser, transaction)
            completion?(transaction, nil)
        }
    }
    
    func processSurchargeEligibilityLookup(_ builder: SurchargeEligibilityLookupBuilder,
                                           completion: ((Transaction?, Error?) -> Void)?) {
        let requestBuilder = PorticoSurchargeEligibilityLookupRequestBuilder()
        guard let requestType = requestBuilder.mapRequestType(builder) else {
            completion?(nil, ApiException(message: "Operation not supported"))
            return
        }
        guard let request = requestBuilder.generateRequest(for: builder, config: self.porticoConfig) else {
            completion?(nil, ApiException(message: "Operation not supported"))
            return
        }
        
        super.doTransaction(endpoint: request.endpoint,
                            method: .post,
                            request: request.request) { response, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            guard let response = response else {
                completion?(nil, error)
                return
            }
            
            // Map XML response to Transaction
            let parser = PorticoXmlResponseParser(xml: response)
            let transaction = Transaction()
            _ = parser.parse(requestType: requestType)
            PorticoXmlApiMapping.mapTransaction(parser, transaction)
            completion?(transaction, nil)
        }
    }
   
    func serializeRequest(_ builder: AuthorizationBuilder) -> String? {
        return nil
    }
}

extension PorticoConnector: ReportingServiceType {
    
    func processReport<T>(builder: ReportBuilder<T>, completion: ((T?, Error?) -> Void)?) {
        
        if let builder = builder as? TransactionReportBuilder<T> {
            let requestBuilder = PorticoReportRequestBuilder<T>()
            guard let requestType = requestBuilder.mapRequestType(builder) else {
                completion?(nil, ApiException(message: "Operation not supported"))
                return
            }
            
            guard let request = requestBuilder.generateRequest(for: builder, config: self.porticoConfig) else {
                completion?(nil, ApiException(message: "Operation not supported"))
                return
            }
            
            super.doTransaction(endpoint: request.endpoint,
                                method: .post,
                                request: request.request) { response, error in
                if let error = error {
                    completion?(nil, error)
                    return
                }
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                
                // Map XML response to Transaction
                let parser = PorticoXmlResponseParser(xml: response)
                _ = parser.parse(requestType: requestType)
                if T.self == TransactionSummary.self {
                    completion?(parser.singleReport as? T, nil)
                } else {
                    let transactionSummury = PorticoXmlApiMapping.mapTransactionSummary(parser)
                    completion?(transactionSummury as? T, nil)
                }
            }
        }
    }
}
