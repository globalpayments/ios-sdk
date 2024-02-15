import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct GatewayResponse {
    let rawResponse: String
    let requestUrl: String?
    let statusCode: Int
}

enum NetworkError: Error {
    case noData
    case noResponse
    case canNotGenerateURL
    case undefined
}

public protocol RequestLogger {
    func requestSent(request: String)
    func responseReceived(response: String)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noData: return "No data to decode."
        case .noResponse: return "No HTTP response."
        case .canNotGenerateURL: return "Can not generate request URL."
        case .undefined: return "Something went wrong."
        }
    }
}

public class Gateway3ds {
    public var headers: [String: String]
    public var dynamicHeaders: [String: String]
    public var requestLogger: RequestLogger?
    public var timeout: TimeInterval = 60.0
    private let session: URLSession
    private let contentType: String

    init(session: URLSession,
         contentType: String) {

        self.session = session
        self.contentType = contentType
        self.headers = [String: String]()
        self.dynamicHeaders = [String: String]()
    }

    func sendRequest(endpoint: String,
                     method: HTTPMethod,
                     data: String? = nil,
                     queryStringParams: [String: String]? = nil,
                     contentType: String? = nil,
                     completion: @escaping (GatewayResponse?, NetworkError?) -> Void) {

        guard let url = generateURL(serviceUrl: ApiConstants.baseURL, endpoint: endpoint, queryStringParams: queryStringParams) else {
            completion(nil, NetworkError.canNotGenerateURL)
            return
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)

        request.httpMethod = method.rawValue
        request.addValue(contentType ?? self.contentType, forHTTPHeaderField: "Accept")
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        dynamicHeaders.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        if method != .get && data != nil {
            request.httpBody = data?.data(using: .utf8)
            request.addValue(contentType ?? self.contentType, forHTTPHeaderField: ApiConstants.contentType)
            requestLogger?.requestSent(request: data!)
        }

        let task = session.dataTask(with: request,
                                    completionHandler: { [weak self] data, urlResponse, _ in
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

