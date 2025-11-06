import Foundation

public struct PorticoRequest {
    var endpoint: String
    var method: HTTPMethod
    var request: String?
    var queryParams: [String: String]?

    init(endpoint: String,
         method: HTTPMethod,
         request: String? = nil,
         queryParams: [String: String]? = nil) {

        self.endpoint = endpoint
        self.method = method
        self.request = request
        self.queryParams = queryParams
    }
}

extension PorticoRequest {
    
    struct Endpoints {
        
        // MARK: - Access Token

        static func exchange() -> String {
            "/Hps.Exchange.PosGateway/PosGatewayService.asmx"
        }
    }
}
