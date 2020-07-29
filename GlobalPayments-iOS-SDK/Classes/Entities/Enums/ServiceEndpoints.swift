import Foundation

public enum ServiceEndpoints: String {
    case globalEcomProduction = "https://api.realexpayments.com/epage-remote.cgi"
    case globalEcomTest = "https://api.sandbox.realexpayments.com/epage-remote.cgi"
    case porticoProduction = "https://api2.heartlandportico.com"
    case porticoTest = "https://cert.api2.heartlandportico.com"
    case threeDsAuthProduction = "https://api.globalpay-ecommerce.com/3ds2/"
    case threeDsAuthTest = "https://api.sandbox.globalpay-ecommerce.com/3ds2/"
    case payrollProduction = "https://taapi.heartlandpayrollonlinetest.com/PosWebUI"
    case payrollTest = "https://taapi.heartlandpayrollonlinetest.com/PosWebUI/Test/Test"
    case tableServiceProduction
    case tableServiceTest = "https://www.freshtxt.com/api31/"
    case geniusApiProduction
    case geniusApiTest = "https://ps1.merchantware.net/Merchantware/ws/RetailTransaction/v45/Credit.asmx"
    case geniusTerminalProduction
    case geniusTerminalTest = "https://transport.merchantware.net/v4/transportService.asmx"
    case transitMultipassProduction = "https://gateway.transit-pass.com/servlets/TransNox_API_Server"
    case transitMultipassTest = "https://stagegw.transnox.com/servlets/TransNox_API_Server"
    case gpApiProduction
    case gpApiTest = "https://apis.sandbox.globalpay.com"
}
