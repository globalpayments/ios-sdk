import Foundation
import GirdersSwift

extension Error {
    func authenticationErrorDescription() -> String {
        if let responseError = self as? ResponseError<AuthenticationResponse> {
            return "An error occured. \n \(responseError.description())"
        }
        return "An error occured. \n \(self.localizedDescription)"
    }
}

extension ResponseError {
    func description() -> String {
        switch self {
        case .BadRequest(let response):
            return detailedDescripton(errorTitle: "Bad Request", response: response)
        case .Unauthorized(let response):
            return detailedDescripton(errorTitle: "Unauthorized", response: response)
        case .Forbidden(let response):
            return detailedDescripton(errorTitle: "Forbidden", response: response)
        case .NotFound(let response):
            return detailedDescripton(errorTitle: "Not Found", response: response)
        case .MethodNotAllowed(let response):
            return detailedDescripton(errorTitle: "Method Not Allowed", response: response)
        case .InternalServerError(let response):
            return detailedDescripton(errorTitle: "Internal Server Error", response: response)
        case .NotImplemented(let response):
            return detailedDescripton(errorTitle: "Not Implemented", response: response)
        case .BadGateway(let response):
            return detailedDescripton(errorTitle: "Bad Gateway", response: response)
        case .Unknown(let response):
            return detailedDescripton(errorTitle: "Unknown", response: response)
        }
    }
    
    func detailedDescripton(errorTitle: String, response: Response<T>) -> String {
        var errorDescription = errorTitle
        errorDescription.append(". \nCode: \(response.statusCode)")
        
        if let urlString = response.url?.absoluteString {
            errorDescription.append("\nURL: \(urlString)")
        }
        
        if let responseBodyData = response.body,
           let responseBodyString = String(data: responseBodyData, encoding: .utf8) {
            errorDescription.append("\nError details: \(responseBodyString)")
        }
        
        return errorDescription
    }
}
