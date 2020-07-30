import Foundation

class GpApiRequest {
    var endpoint: String
    var requestBody: String?
    var resultsField: String?

    init(endpoint: String,
         requestBody: String? = nil,
         resultsField: String? = nil) {

        self.endpoint = endpoint
        self.requestBody = requestBody
        self.resultsField = resultsField
    }
}
