import Foundation

public enum NetworkError: Error {
    case noData
    case noResponse
    case canNotGenerateURL
    case undefined
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
