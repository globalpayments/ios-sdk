import Foundation

class GpApiConnector: RestGateway, PaymentGateway, ReportingService {
    var appId: String = .empty
    var appKey: String = .empty
    var nonce: String = .empty
    var secondsToExpire: Int?
    var intervalToExpire: IntervalToExpire?
    var channel: Channel?
    var language: Language?
    var sessionToken: String?
    var supportsHostedPayments: Bool = false

    override init() {
        super.init()
        // Set required api version header
        headers["X-GP-Version"] = "2020-04-10"; //"2020-01-20";
        headers["Accept"] = "application/json";
        headers["Accept-Encoding"] = "gzip";
    }

    func signIn() {
        let request = SessionInfo.signIn(appId: appId, appKey: appKey, nonce: nonce, secondsToExpire: secondsToExpire, intervalToExpire: intervalToExpire)
    }

//    public void SignIn() {
//        var request = SessionInfo.SignIn(AppId, AppKey, Nonce, SecondsToExpire, IntervalToExpire);
//
//        var response = SendAccessTokenRequest(request);
//
//        //if (!string.IsNullOrEmpty(response.ErrorMessage))
//        //    throw new ApiException(response.ErrorMessage);
//
//        SessionToken = response.Token;
//
//        // Set the authorization header
//        Headers["Authorization"] = $"Bearer {response.Token}";
//    }


    // ------

    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?) -> Void)?) {

    }

    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?) -> Void)?) {

    }

    func serializeRequest(_ builder: AuthorizationBuilder) -> String? {
        return nil
    }

    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?) -> Void)?) {

    }
}
