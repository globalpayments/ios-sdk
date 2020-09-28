import Foundation

public class GpApiService {
    
    public static func generateTransactionKey(
        environment: Environment,
        appId: String,
        appKey: String,
        secondsToExpire: Int? = nil,
        intervalToExpire: IntervalToExpire? = nil,
        completion: @escaping (AccessTokenInfo?, Error?) -> Void) {
        
        let connector = GpApiConnector()
        connector.appId = appId
        connector.appKey = appKey
        connector.secondsToExpire = secondsToExpire
        connector.intervalToExpire = intervalToExpire
        connector.timeout = 10000
        switch environment {
        case .production:
            connector.serviceUrl = ServiceEndpoints.gpApiProduction.rawValue
        case .test:
            connector.serviceUrl = ServiceEndpoints.gpApiTest.rawValue
        }
        
        connector.getAccessToken { tokenResponse, error in
            if let error = error {
                completion(nil, error)
                return
            }
            let accessTokenInfo = AccessTokenInfo()
            accessTokenInfo.token = tokenResponse?.token
            accessTokenInfo.dataAccountName = tokenResponse?.dataAccountName
            accessTokenInfo.disputeManagementAccountName = tokenResponse?.disputeManagementAccountName
            accessTokenInfo.tokenizationAccountName = tokenResponse?.tokenizationAccountName
            accessTokenInfo.transactionProcessingAccountName = tokenResponse?.transactionProcessingAccountName
            
            completion(accessTokenInfo, nil)
        }
    }
}
