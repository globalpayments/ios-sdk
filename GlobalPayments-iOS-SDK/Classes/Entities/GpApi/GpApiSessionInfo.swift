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

    func signIn(appId: String,
                       appKey: String,
                       secondsToExpire: Int? = nil,
                       intervalToExpire: IntervalToExpire? = nil,
                       permissions: [String]? = nil) -> GpApiRequest {
        let nonce = Date().format("MM/dd/yyyy HH:mm:ss.SSSS")
        let request = JsonDoc()
            .set(for: "app_id", value: appId)
            .set(for: "nonce", value: nonce)
            .set(for: "grant_type", value: "client_credentials")
            .set(for: "secret", value: generateSecret(nonce, appKey))
            .set(for: "interval_to_expire", value: intervalToExpire?.rawValue)
            .set(for: "permissions", value: permissions)
        if let secondsToExpire = secondsToExpire {
            request.set(for: "seconds_to_expire", value: String(secondsToExpire))
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
}
