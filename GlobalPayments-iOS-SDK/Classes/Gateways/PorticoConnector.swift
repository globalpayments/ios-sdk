import Foundation

class PorticoConnector: XmlGateway {

    var supportsHostedPayments: Bool = false
    var porticoConfig: PorticoConfig
    var porticoConfigData: PorticoConfigData
    
    init(porticoConfig: PorticoConfig, porticoConfigData: PorticoConfigData) {
        self.porticoConfig = porticoConfig
        self.porticoConfigData = porticoConfigData
        super.init()
        self.requestLogger = porticoConfig.requestLogger
    }
}

extension PorticoConnector: PaymentGateway {
    
    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?, Error?) -> Void)?) {
    }
    
    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?, Error?) -> Void)?) {
    }
    
    func serializeRequest(_ builder: AuthorizationBuilder) -> String? {
        return nil
    }
}

extension PorticoConnector: ReportingServiceType {
    
    func processReport<T>(builder: ReportBuilder<T>, completion: ((T?, Error?) -> Void)?) {
        
        if let builder = builder as? TransactionReportBuilder<T> {
            let requestBuilder = PorticoReportRequestBuilder<T>()
            guard let request = requestBuilder.generateRequest(for: builder, config: self.porticoConfig, porticoConfigData: self.porticoConfigData) else {
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
                
                completion?(PorticoApiMapping.mapReportResponse(response, builder.reportType), nil)
            }
        }
    }
}
