import Foundation

class SessionInfo {

    /// A unique string created using the nonce and app-key.
    /// This value is used to further authenticate the request.
    /// Created as follows - SHA512(NONCE + APP-KEY).
    /// - Parameters:
    ///   - nonce: string to hash
    ///   - appKey: app key
    /// - Returns: hash of the input string
    private static func generateSecret(_ nonce: String, _ appKey: String) -> String {
        return (nonce + appKey).sha512.lowercased()
    }

    static func signIn(appId: String,
                       appKey: String,
                       nonce: String,
                       secondsToExpire: Int? = nil,
                       intervalToExpire: IntervalToExpire? = nil) -> GpApiRequest {

        let request = JsonDoc()
            .set(for: "app_id", value: appId)
            .set(for: "nonce", value: nonce)
            .set(for: "grant_type", value: "client_credentials")
            .set(for: "secret", value: generateSecret(nonce, appKey))
            .set(for: "seconds_to_expire", value: String(secondsToExpire ?? .zero))
            .set(for: "interval_to_expire", value: intervalToExpire?.rawValue)

        return GpApiRequest(
            endpoint: "/ucp/accesstoken",
            requestBody: request.toString()
        )
    }

    static func signOut() {
        print("signOut not implemented")
        abort()
    }
}
