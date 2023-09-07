import Foundation
import GlobalPayments_iOS_SDK
import ThreeDS_SDK
import GirdersSwift

protocol HostedFieldsViewInput {
    func onViewDidLoad()
    func createToken(_ isRecurring: Bool)
    func checkEnrollment(_ token: String, brand: String)
}

protocol HostedFieldsViewOutput: AnyObject{
    func showErrorView(error: Error?)
    func showTransaction(_ transaction: GlobalPayments_iOS_SDK.Transaction)
    func tokenGenerated(token: String)
}

final class HostedFieldsViewModel: HostedFieldsViewInput {
    
    weak var view: HostedFieldsViewController?
    
    private let configuration: Configuration
    private var appConfig: Config?
    private let currency = "GBP"
    private let amount: NSDecimalNumber = 100
    private var isPaymentRecurring = false
    private var cardBrand: String?
    
    private let ENROLLED: String = "ENROLLED"
    private let CHALLENGE_REQUIRED = "CHALLENGE_REQUIRED"
    private let SUCCESS_AUTHENTICATED = "SUCCESS_AUTHENTICATED"
    private let SUCCESS = "SUCCESS"
    
    lazy var initializationUseCase: InitializationUseCase = Container.resolve()
    lazy var threeDS2Service: ThreeDS2Service = Container.resolve()
    private var transaction: ThreeDS_SDK.Transaction?
    private var tokenizedCard: CreditCardData?

    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func onViewDidLoad() {
        guard let config = configuration.loadConfig() else {
            return
        }
        appConfig = config
    }
    
    func initThreeDS2Service() -> Bool {
        var initializationStatus = false
        initializationUseCase.initializeSDK(succesHandler: {
            initializationStatus = true
        }) { _ in
            initializationStatus = false
        }
        return initializationStatus
    }
    
    func createToken(_ isRecurring: Bool) {
        isPaymentRecurring = isRecurring
        guard let appConfig = appConfig else { return }
        GpApiService.generateTransactionKey(
            environment: .test,
            appId: appConfig.appId,
            appKey: appConfig.appKey) { [weak self] accessTokenInfo, error in
            UI {
                guard let accessTokenInfo = accessTokenInfo, let token = accessTokenInfo.token else {
                    self?.view?.showErrorView(error: error)
                    return
                }
                self?.view?.tokenGenerated(token: token)
            }
        }
    }
    
    func checkEnrollment(_ token: String, brand: String) {
        cardBrand = brand
        tokenizedCard = CreditCardData()
        tokenizedCard?.token = token
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .withAuthenticationSource(.browser)
            .execute { secureEcom, error in
                UI {
                    guard let secureEcom = secureEcom else {
                        self.view?.showErrorView(error: error)
                        return
                    }
                    self.initializationNetcetera(secureEcom: secureEcom)
                }
            }
    }
    
    private func initializationNetcetera(secureEcom: ThreeDSecure? = nil) {
        if (secureEcom?.status == "AVAILABLE" ) {
            let _ = initThreeDS2Service()
            createTransaction(secureEcom: secureEcom)
        }else {
            self.view?.showErrorView(error: ApiException(message: "Validate Card with other flow"))
        }
    }
    
    private func createTransaction(secureEcom: ThreeDSecure?) {
        guard let secureEcom = secureEcom else {
            self.view?.showErrorView(error: ApiException(message: "SecureEcom is Nil"))
            return
        }

        do {
            transaction = try threeDS2Service.createTransaction(directoryServerId: getDsRidCard(), messageVersion: secureEcom.messageVersion
            )
            if let netceteraParams = try transaction?.getAuthenticationRequestParameters(){
                authenticateTransaction(secureEcom, netceteraParams)
            }
        } catch {
            self.view?.showErrorView(error: error)
        }
    }
    
    private func authenticateTransaction(_ secureEcom: ThreeDSecure,_ netceteraParams: AuthenticationRequestParameters) {
        let mobileData = MobileData()
        mobileData.applicationReference = netceteraParams.getSDKAppID()
        mobileData.sdkTransReference = netceteraParams.getSDKTransactionId()
        mobileData.referenceNumber = netceteraParams.getSDKReferenceNumber()
        mobileData.sdkInterface = .both
        mobileData.encodedData = netceteraParams.getDeviceData()
        mobileData.maximumTimeout = 10
        mobileData.ephemeralPublicKey = JsonDoc.parse(netceteraParams.getSDKEphemeralPublicKey())
        mobileData.sdkUiTypes = SdkUiType.allCases
        
        Secure3dService
            .initiateAuthentication(paymentMethod: tokenizedCard, secureEcom: secureEcom)
            .withAmount(amount)
            .withCurrency(currency)
            .withAuthenticationSource(.mobileSDK)
            .withMethodUrlCompletion(.yes)
            .withOrderCreateDate(Date())
            .withMobileData(mobileData)
            .execute { authResult, error in
                UI {
                    guard let authResult = authResult else {
                        self.view?.showErrorView(error: error)
                        return
                    }
                    self.startChallengeFlow(authResult)
                }
            }
    }
    
    private func startChallengeFlow(_ secureEcom: ThreeDSecure) {
        if(secureEcom.status == self.CHALLENGE_REQUIRED){
            let challengeStatusReceiver = AppChallengeStatusReceiver(view: self, dsTransId: secureEcom.acsTransactionId, secureEcom: secureEcom)
            let challengeParameters = self.prepareChallengeParameters(secureEcom)
            do {
                try self.transaction?.doChallenge(challengeParameters: challengeParameters,
                                                  challengeStatusReceiver: challengeStatusReceiver,
                                                  timeOut:10,
                                                  inViewController: self.view!)
            } catch {
                self.view?.showErrorView(error: error)
            }
        }else {
            if let transactionId = secureEcom.serverTransactionId {
                self.doAuth(transactionId)
            }
        }
    }
    
    private func prepareChallengeParameters(_ secureEcom: ThreeDSecure) -> ChallengeParameters {
        let challengeParameters = ChallengeParameters.init(threeDSServerTransactionID: secureEcom.serverTransferReference,
                                                           acsTransactionID: secureEcom.acsTransactionId,
                                                           acsRefNumber: secureEcom.acsReferenceNumber,
                                                           acsSignedContent: secureEcom.payerAuthenticationRequest)
        return challengeParameters
    }
    
    private func doAuth(_ serverTransactionId: String) {
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(serverTransactionId)
            .execute(version: .two) { secureEcom, error in
                UI {
                    guard let secureEcom = secureEcom else {
                        self.view?.showErrorView(error: error)
                        return
                    }
                    
                    self.chargeCard(authResult: secureEcom)
                }
            }
    }
    
    private func chargeCard(authResult: ThreeDSecure) {
        tokenizedCard?.threeDSecure = authResult
        tokenizedCard?.charge(amount: amount)
            .withCurrency(currency)
            .execute { chargeResult, error in
                UI {
                    guard let chargeResult = chargeResult else {
                        self.view?.showErrorView(error: error)
                        return
                    }
                    
                    if self.isPaymentRecurring {
                        self.recurringPayment(cardChargeResult: chargeResult)
                    } else {
                        self.view?.showTransaction(chargeResult)
                    }
                }
            }
    }
    
    private func recurringPayment(cardChargeResult: GlobalPayments_iOS_SDK.Transaction) {
        let storedCredentials = StoredCredential(type: .recurring,
                                                 initiator: .merchant,
                                                 sequence: .subsequent,
                                                 reason: .incremental)
        tokenizedCard?.charge(amount: amount)
            .withCurrency(currency)
            .withStoredCredential(storedCredentials)
            .withCardBrandStorage(.merchant, value: cardChargeResult.cardBrandTransactionId)
            .execute { chargeResult, error in
                UI {
                    guard let chargeResult = chargeResult else {
                        self.view?.showErrorView(error: error)
                        return
                    }
                    
                    self.view?.showTransaction(chargeResult)
                }
            }
    }
    
    private func getDsRidCard() -> String {
        switch cardBrand?.lowercased() {
        case "visa":
            return DsRidValues.visa
        default:
            return DsRidValues.visa
        }
    }
}

extension HostedFieldsViewModel: StatusView {
    
    func showErrorScreen(with message: String) {
        UI {
            self.view?.showErrorView(error: ApiException(message: message))
        }
    }
    
    func showSuccessScreen(with message: String) {
//        self.view?.requestSuccess(message)
    }
    
    func successChallenge(by secureEcom: ThreeDSecure) {
        if let transactionId = secureEcom.serverTransactionId {
            self.doAuth(transactionId)
        }
    }
}
