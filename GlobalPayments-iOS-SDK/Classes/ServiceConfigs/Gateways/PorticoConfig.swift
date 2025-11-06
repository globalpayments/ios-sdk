import Foundation
import Foundation

public class PorticoConfig: GatewayConfig {
    
    // Account's site ID
    public var siteId: Int?
    
    // Account's license ID
    public var licenseId: Int?
    
    // Account's device ID
    public var deviceId: Int?
    
    // Account's username
    public var username: String?
    
    // Account's password
    public var password: String?
    
    // Integration's developer ID
    // This is provided at the start of an integration's certification.
    public var developerId: String?
    
    // Integration's version number
    public var versionNumber: String?
    
    // Account's secret API key
    public var secretApiKey: String?
    
    // A unique device id to be passed with each transaction
    public var uniqueDeviceId: String?
    
    //Name and Version of the SDK used for integration, where applicable.  Expected for users of the Heartland SDK.
    public var sdkNameVersion: String?
    
    // ProPay CertificationStr Value
    public var certificationStr: String?
    
    // ProPay TerminalID Value
    public var terminalID: String?
    
    // ProPay X509 Certificate Location
    public var X509CertificatePath: String?
    
    // ProPay X509 Certificate Base64 String (Optional: Can be used instead of X509CertificatePath)
    public var X509CertificateBase64String: String?
    
    // If true (default), use the US ProPay endpoints. If false, use the Canadian ProPay endpoints
    public var proPayUS: Bool?
    
    public init(siteId: Int? = nil,
                licenseId: Int? = nil,
                deviceId: Int? = nil,
                username: String? = nil,
                password: String? = nil,
                developerId: String? = nil,
                versionNumber: String? = nil,
                secretApiKey: String? = nil,
                uniqueDeviceId: String? = nil,
                sdkNameVersion: String? = nil,
                certificationStr: String? = nil,
                terminalID: String? = nil,
                X509CertificatePath: String? = nil,
                X509CertificateBase64String: String? = nil,
                proPayUS: Bool? = false) {
        self.siteId = siteId
        self.licenseId = licenseId
        self.deviceId = deviceId
        self.username = username
        self.password = password
        self.developerId = developerId
        self.versionNumber = versionNumber
        self.secretApiKey = secretApiKey
        self.uniqueDeviceId = uniqueDeviceId
        self.sdkNameVersion = sdkNameVersion
        self.certificationStr = certificationStr
        self.terminalID = terminalID
        self.X509CertificatePath = X509CertificatePath
        self.X509CertificateBase64String = X509CertificateBase64String
        self.proPayUS = proPayUS
        super.init(gatewayProvider: .portico)
    }
    
    override func configureContainer(services: ConfiguredServices) {
        if serviceUrl.isNilOrEmpty {
            if environment == .test {
                serviceUrl = ServiceEndpoints.gpApiTest.rawValue
            } else {
                serviceUrl = ServiceEndpoints.gpApiProduction.rawValue
            }
        }
        
        let porticoConfigData = PorticoConfigData()
        porticoConfigData.siteId = siteId
        porticoConfigData.licenseId = licenseId
        porticoConfigData.developerId = developerId
        porticoConfigData.username = username
        porticoConfigData.password = password
        porticoConfigData.versionNumber = versionNumber
        porticoConfigData.secretApiKey = secretApiKey
        porticoConfigData.uniqueDeviceId = uniqueDeviceId
        porticoConfigData.sdkNameVersion = sdkNameVersion
        
        let gateway = PorticoConnector(porticoConfig: self, porticoConfigData: porticoConfigData)
        gateway.serviceUrl = serviceUrl
        
        services.gatewayConnector = gateway
        services.reportingService = gateway
    }
}
