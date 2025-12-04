import Foundation

class GpApiSessionInfo: AccessTokenProvider {
    /// A unique string created using the nonce and app-key.
    /// This value is used to further authenticate the request.
    /// Created as follows - SHA512(NONCE + APP-KEY).
    /// - Parameters:
    ///   - nonce: string to hash
    ///   - appKey: app key
    /// - Returns: hash of the input string
    private func generateSecret(_ nonce: String, _ appKey: String) -> String {
        return (nonce + appKey).sha512.lowercased()
    }

    func signIn(appId: String? = nil,
                       appKey: String? = nil,
                       secondsToExpire: Int? = nil,
                       intervalToExpire: IntervalToExpire? = nil,
                       permissions: [String]? = nil,
                       porticoTokenConfig: PorticoTokenConfig? = nil) -> GpApiRequest {
        let request = JsonDoc()
        
        if let porticoCredentials = porticoTokenConfig {
            if let appId = appId {
                request.set(for: "app_id", value: appId)
            }
            
            let porticoCredentialsArray: [[String: String]] = self.porticoCredentials(porticoTokenConfig: porticoCredentials)
            request.set(for: "credentials", value: porticoCredentialsArray)
            request.set(for: "grant_type", value: "client_credentials")
        } else {
            let nonce = Date().format("MM/dd/yyyy HH:mm:ss.SSSS")
            request.set(for: "app_id", value: appId)
            request.set(for: "nonce", value: nonce)
            request.set(for: "grant_type", value: "client_credentials")
            request.set(for: "secret", value: generateSecret(nonce, appKey ?? ""))
            request.set(for: "interval_to_expire", value: intervalToExpire?.rawValue)
            request.set(for: "permissions", value: permissions)
            if let secondsToExpire = secondsToExpire {
                request.set(for: "seconds_to_expire", value: String(secondsToExpire))
            }
        }

        return GpApiRequest(
            endpoint: GpApiRequest.Endpoints.accesstoken(),
            method: .post,
            requestBody: request.toString()
        )
    }
    
    func signOut() -> GpApiRequest? {
        return nil
    }
    
    func porticoCredentials(porticoTokenConfig: PorticoTokenConfig) -> [[String: String]] {
        var credentials: [[String: String]] = [[:]]
        
        if let deviceId = porticoTokenConfig.deviceId,
            let siteId = porticoTokenConfig.siteId,
            let licenseId = porticoTokenConfig.licenseId,
            let username = porticoTokenConfig.username,
            let password = porticoTokenConfig.password {
            credentials = [
                ["name": "device_id", "value": deviceId.toString],
                ["name": "site_id", "value": siteId.toString],
                ["name": "license_id", "value": licenseId.toString],
                ["name": "username", "value": username],
                ["name": "password", "value": password]]
            
            if let apiKey  = porticoTokenConfig.secretApiKey  {
                credentials.append(["name": "apikey", "value": apiKey])
            }
        } else if let apiKey  = porticoTokenConfig.secretApiKey  {
            credentials = [["name": "apikey", "value": apiKey]]
        }
        return credentials
    }
}
