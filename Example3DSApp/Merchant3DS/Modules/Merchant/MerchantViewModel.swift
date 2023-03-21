import Foundation
import GirdersSwift
import ThreeDS_SDK

protocol MerchantViewInput {
    func onViewDidLoad()
    func checkEnrollment(_ token: String)
}

protocol MerchantViewOutput: AnyObject {
    func displayError(_ error: Error)
    func showTokenLoaded(_ token: String)
    func showLoading(_ message: String)
    func hideLoading()
    func requestError(_ error: Error)
    func requestSuccess(_ message: String?)
    func showTransaction(_ transaction: TransactionResponse)
}

final class MerchantViewModel: MerchantViewInput {
    
    private let currency = "USD"
    private let amount: Decimal = 10
    private let ENROLLED: String = "ENROLLED"
    private let CHALLENGE_REQUIRED = "CHALLENGE_REQUIRED"
    private let SUCCESS_AUTHENTICATED = "SUCCESS_AUTHENTICATED"
    private let SUCCESS = "SUCCESS"
    private var tokenizedCard: String?
    private var transaction: ThreeDS_SDK.Transaction?
    private var cardBrand: String?
    weak var view: AmountViewController?
    lazy var initializationUseCase: InitializationUseCase = Container.resolve()
    lazy var threeDS2Service: ThreeDS2Service = Container.resolve()
    
    private var currentToken: String = ""
    
    func initThreeDS2Service() -> Bool {
        var initializationStatus = false
        // 7.Initialization
        initializationUseCase.initializeSDK(succesHandler: {
            initializationStatus = true
        }) { _ in
        }
        return initializationStatus
    }
    
    func onViewDidLoad() {
        generateToken()
    }
    
    func generateToken(){
        DemoAppService.generateToken(){ [weak self] response, error in
            UI {
                self?.view?.showTokenLoaded(response?.accessToken ?? "")
            }
        }
    }
    
    //2. Send Cardholder data to server
    func checkEnrollment(_ token: String){
        tokenizedCard = token
        
        //3. 4. Check and Response Status
        DemoAppService.checkEnrollment(
            cardToken: token,
            amount: amount,
            currency: currency,
            decoupledAuth: true){ [weak self] secureEcom, error in
                guard let secureEcom = secureEcom else {
                    if let error = error{
                        self?.view?.requestError(error)
                    }
                    return
                }
                self?.initializationNetcetera(secureEcom)
            }
    }
    
    func initializationNetcetera(_ secureEcom: CheckEnrollmentResponse? = nil){
        //5. If 3DS2 proceed
        if (secureEcom?.status == "AVAILABLE" ) {
            // 6. Instantiation
            if initThreeDS2Service() {
                // SDK Initiated
            }            
            createTransaction(secureEcom: secureEcom)
        }else {
            // Validate Card with other flow
            view?.requestError(ApiException(message: "Api Error"))
        }
    }
    
    private func createTransaction(secureEcom: CheckEnrollmentResponse?) {
        guard let secureEcom = secureEcom else {
            self.view?.requestError(ApiException(message: "SecureEcom is Nil"))
            return
        }
        
        // 9. Show process. Progress Dialog Screen

        do {
            // 10. Create transaction
            transaction = try threeDS2Service.createTransaction(directoryServerId: getDsRidCard(), messageVersion: secureEcom.messageVersion
            )
            
            // 11. Get authentication Params
            if let netceteraParams = try transaction?.getAuthenticationRequestParameters(){
                authenticateTransaction(secureEcom, netceteraParams: netceteraParams)
            }
        } catch {
            view?.requestError(error)
        }
    }
    
    //12. Send Authentication Parameters to server
    func authenticateTransaction(_ secureEcom: CheckEnrollmentResponse, netceteraParams: AuthenticationRequestParameters ) {
        let mobileData = MobileData()
        mobileData.applicationReference = netceteraParams.getSDKAppID()
        mobileData.sdkTransReference = netceteraParams.getSDKTransactionId()
        mobileData.referenceNumber = netceteraParams.getSDKReferenceNumber()
        mobileData.sdkInterface = .both
        mobileData.encodedData = netceteraParams.getDeviceData()
        mobileData.maximumTimeout = 10
        mobileData.ephemeralPublicKey = JsonDoc.parse(netceteraParams.getSDKEphemeralPublicKey())
        mobileData.sdkUiTypes = SdkUiType.allCases
        
        guard let token = tokenizedCard else {
            view?.requestError(ApiException(message: "Card Token is nil"))
            return
        }
        
        let threeDSecureData = ThreeDSecureRequest()
        threeDSecureData.amount = amount
        threeDSecureData.currency = currency
        threeDSecureData.status = secureEcom.status
        threeDSecureData.messageVersion = secureEcom.messageVersion
        threeDSecureData.serverTransactionId = secureEcom.serverTransactionId

        let isDecoupledAuth = ApiConstants.isDecoupledAuth
        
        DemoAppService.sendAuthenticationParams(token, amount: amount, currency: currency, mobileData: mobileData, threeDSecure: threeDSecureData, decoupledAuth: isDecoupledAuth, decoupledTimeout: ApiConstants.decoupledTimeout) { [weak self] secureEcom, error in
            guard let secureEcom = secureEcom else {
                if let error = error {
                    self?.view?.requestError(error)
                }
                return
            }
            self?.startChallengeFlow(secureEcom, decoupledAuth: isDecoupledAuth)
        }
    }
    
    //15.3 Frictionless or Challenge
    private func startChallengeFlow(_ secureEcom: AuthParamsResponse, decoupledAuth: Bool) {
        if(secureEcom.status == self.CHALLENGE_REQUIRED){
            let challengeStatusReceiver = AppChallengeStatusReceiver(view: self, dsTransId: secureEcom.dsTransferReference, secureEcom: secureEcom)
            let challengeParameters = self.prepareChallengeParameters(secureEcom)
            do {
                //16. Do challenge
                try self.transaction?.doChallenge(challengeParameters: challengeParameters,
                                                  challengeStatusReceiver: challengeStatusReceiver,
                                                  timeOut:10,
                                                  inViewController: self.view!)
            } catch {
                self.view?.requestError(error)
            }
        }else if((secureEcom.status == self.SUCCESS_AUTHENTICATED || secureEcom.status == self.SUCCESS) && secureEcom.liabilityShift == "YES"){
            if decoupledAuth {
                self.view?.showLoading("Waiting for auth")
                DispatchQueue.main.asyncAfter(deadline: .now() + ApiConstants.authTimeout) {
                    self.view?.hideLoading()
                    self.doAuth(secureEcom: secureEcom)
                }
            }else {
                self.doAuth(secureEcom: secureEcom)
            }
        }else {
            self.view?.requestError(ApiException(message: "ANOTHER CARD IS NECCESARY"))
        }
    }
    
    private func prepareChallengeParameters(_ secureEcom: AuthParamsResponse) -> ChallengeParameters {
        let challengeParameters = ChallengeParameters.init(threeDSServerTransactionID:              secureEcom.serverTransactionId,
                                                           acsTransactionID: secureEcom.acsTransactionId,
                                                           acsRefNumber: secureEcom.acsReferenceNumber,
                                                           acsSignedContent: secureEcom.payerAuthenticationRequest)
        return challengeParameters
    }
    
    //23.
    func doAuth(secureEcom: AuthParamsResponse) {
        guard let serverTransactionId = secureEcom.serverTransactionId else {
            view?.requestError(ApiException(message: "ServerTransactionId is nil"))
            return
        }
        
        // 24. 25.
        DemoAppService.getAuthData(serverTransactionId) { authData, error in
            guard let _ = authData else {
                if let error = error {
                    self.view?.requestError(error)
                }
                return
            }
            
            self.chargeMoney(serverTransactionId)
        }
    }
    
    private func chargeMoney(_ serverTransactionId: String) {
        //26. 27.
        guard let cardToken = tokenizedCard else {
            self.view?.requestError(ApiException(message: "Card Token is Nil"))
            return
        }
        DemoAppService.authorizationData(cardToken, amount: amount, currency: currency, serverTransactionId: serverTransactionId) { [weak self] transactionData, error in
            guard let transactionData = transactionData else {
                if let error = error {
                    self?.view?.requestError(error)
                }
                return
            }
            //27.2 Auth Response
            self?.view?.showTransaction(transactionData)
        }
    }
    
    func getDsRidCard() -> String {
        switch cardBrand?.lowercased() {
        case "visa":
            return DsRidValues.visa
        default:
            return DsRidValues.visa
        }
    }
}

extension MerchantViewModel: StatusView {
    
    func showErrorScreen(with message: String) {
        
        UI {
            self.view?.requestError(ApiException(message: message))
        }
    }
    
    func showSuccessScreen(with message: String) {
        self.view?.requestSuccess(message)
    }
    
    //20.1
    func successChallenge(by secureEcom: AuthParamsResponse) {
        //21.
        self.doAuth(secureEcom: secureEcom)
    }
}
