import Foundation

public class GpApiService {

    public static func generateTransactionKey(
        environment: Environment,
        appId: String,
        appKey: String,
        secondsToExpire: Int? = nil,
        intervalToExpire: IntervalToExpire? = nil,
        permissions: [String]? = nil,
        requestLogger: RequestLogger? = nil,
        completion: @escaping (AccessTokenInfo?, Error?) -> Void) {

        let config = GpApiConfig(appId: appId,
                                 appKey: appKey,
                                 secondsToExpire: secondsToExpire,
                                 intervalToExpire: intervalToExpire,
                                 permissions: permissions)
            
        if (config.accessTokenProvider == nil) {
            config.accessTokenProvider = GpApiSessionInfo()
        }
            
        let connector = GpApiConnector(gpApiConfig: config)
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
            
            accessTokenInfo.dataAccountID = tokenResponse?.dataAccountID
            accessTokenInfo.disputeManagementAccountID = tokenResponse?.disputeManagementAccountID
            accessTokenInfo.tokenizationAccountID = tokenResponse?.tokenizationAccountID
            accessTokenInfo.transactionProcessingAccountID = tokenResponse?.TransactionProcessingAccountID
            accessTokenInfo.riskAssessmentAccountID = tokenResponse?.riskAssessmentAccountID
            completion(accessTokenInfo, nil)
        }
    }
}
