import Foundation

enum ServiceEndpoints: String {
    case globalEcomProduction = "https://api.realexpayments.com/epage-remote.cgi"
    case globalEcomTest = "https://api.sandbox.realexpayments.com/epage-remote.cgi"
    case porticoProduction = "https://api2.heartlandportico.com"
    case porticoTest = "https://cert.api2.heartlandportico.com"
    case threeDsAuthProduction = "https://api.globalpay-ecommerce.com/3ds2/"
    case threeDsAuthTest = "https://api.sandbox.globalpay-ecommerce.com/3ds2/"
}
