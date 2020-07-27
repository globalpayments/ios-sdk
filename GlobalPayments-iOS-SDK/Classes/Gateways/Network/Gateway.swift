import Foundation

class Gateway {
    public var headers: [String: String]
    public var requestLogger: RequestLogger?
    public var timeout: TimeInterval = 60.0
    public var serviceUrl: String?
    private let session: URLSession
    private let contentType: String

    init(session: URLSession = .init(configuration: .default),
         contentType: String) {

        self.session = session
        self.contentType = contentType
        self.headers = [String: String]()
    }

    func sendRequest(endpoint: String,
                     method: HTTPMethod,
                     data: String? = nil,
                     queryStringParams: [String: String]? = nil,
                     contentType: String? = nil,
                     completion: @escaping (GatewayResponse?, NetworkError?) -> Void) {

        guard let url = generateURL(serviceUrl: serviceUrl, endpoint: endpoint, queryStringParams: queryStringParams) else {
            completion(nil, NetworkError.canNotGenerateURL)
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)

        request.httpMethod = method.rawValue
        request.addValue(contentType ?? self.contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(contentType ?? self.contentType, forHTTPHeaderField: "Accept")
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        if method != .get && data != nil {
            request.httpBody = data?.data(using: .utf8)
            requestLogger?.requestSent(request: data!)
        }

        let task = session.dataTask(with: request,
                                    completionHandler: { [weak self] (data, urlResponse, error) in
                                        guard let data = data,
                                            let responseString = String(data: data, encoding: String.Encoding.utf8) else {
                                                completion(nil, NetworkError.noData)
                                                return
                                        }
                                        self?.requestLogger?.responseReceived(response: responseString)
                                        guard let urlResponse = urlResponse as? HTTPURLResponse else {
                                            completion(nil, NetworkError.noResponse)
                                            return
                                        }
                                        let gatewayResponse = GatewayResponse(
                                            rawResponse: responseString,
                                            requestUrl: urlResponse.url?.absoluteString,
                                            statusCode: urlResponse.statusCode
                                        )
                                        completion(gatewayResponse, nil)
        })
        task.resume()
    }

    func generateURL(serviceUrl: String?,
                     endpoint: String,
                     queryStringParams: [String: String]?) -> URL? {

        guard let serviceUrl = serviceUrl, !serviceUrl.isEmpty else { return nil }
        var urlComponents = URLComponents(string: serviceUrl + endpoint)
        if let queryStringParams = queryStringParams {
            urlComponents?.queryItems = queryStringParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return urlComponents?.url
    }
}
