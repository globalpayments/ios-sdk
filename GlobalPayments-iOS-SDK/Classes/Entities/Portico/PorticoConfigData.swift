import Foundation

class PorticoConfigData {
    var siteId: Int?
    var licenseId: Int?
    var deviceId: Int?
    var developerId: String?
    var username: String?
    var password: String?
    var versionNumber: String?
    var secretApiKey: String?
    var uniqueDeviceId: String?
    var sdkNameVersion: String?
    var IsSafDataSupported: Bool?
    
    init(siteId: Int? = nil,
         licenseId: Int? = nil,
         deviceId: Int? = nil,
         developerId: String? = nil,
         username: String? = nil,
         password: String? = nil,
         versionNumber: String? = nil,
         secretApiKey: String? = nil,
         uniqueDeviceId: String? = nil,
         sdkNameVersion: String? = nil,
         IsSafDataSupported: Bool? = nil) {
        self.siteId = siteId
        self.licenseId = licenseId
        self.deviceId = deviceId
        self.developerId = developerId
        self.username = username
        self.password = password
        self.versionNumber = versionNumber
        self.secretApiKey = secretApiKey
        self.uniqueDeviceId = uniqueDeviceId
        self.sdkNameVersion = sdkNameVersion
        self.IsSafDataSupported = IsSafDataSupported
    }
}
