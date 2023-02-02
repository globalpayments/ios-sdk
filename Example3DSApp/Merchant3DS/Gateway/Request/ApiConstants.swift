import Foundation
import GirdersSwift

/// Constants used in the api gateway
struct ApiConstants {
    
    static let JSONHeader = "application/json"
    static let contentType = "Content-Type"

    static let baseURL = "BASE_URL"
    static let appId = "APP_ID"
    static let apiKey = "API_KEY"

    static let decoupledTimeout = 9001
    static let authTimeout: CGFloat = 5.0
    static let isDecoupledAuth = true
    
}
