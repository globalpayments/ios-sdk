import Foundation
import GlobalPayments_iOS_SDK
import ThreeDS_SDK

final class HostedFieldsViewModel: BaseViewModel {
    
    var tokenGenerated: Dynamic<String> = Dynamic("")
    
    private let configuration: Configuration
    private var appConfig: Config?
    private let currency = "USD"
    private var amount: NSDecimalNumber?
    private var isPaymentRecurring = false
    private var cardBrand: String?
    
    private let ENROLLED: String = "ENROLLED"
    private let CHALLENGE_REQUIRED = "CHALLENGE_REQUIRED"
    private let SUCCESS_AUTHENTICATED = "SUCCESS_AUTHENTICATED"
    private let SUCCESS = "SUCCESS"
    
    private lazy var initializationUseCase: InitializationUseCase = GpContainer.resolve()
    private lazy var threeDS2Service: ThreeDS2Service = GpContainer.resolve()
    private var transaction: ThreeDS_SDK.Transaction?
    private var tokenizedCard: CreditCardData?
    weak var viewController: UIViewController?

    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    override func viewDidLoad() {
        guard let config = configuration.loadConfig() else {
            return
        }
        appConfig = config
        createToken()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum){
        switch type {
        case .amount:
            amount = NSDecimalNumber(string: value)
        default:
            break
        }
    }
    
    private func initThreeDS2Service() -> Bool {
        var initializationStatus = false
        initializationUseCase.initializeSDK(succesHandler: {
            initializationStatus = true
        }) { _ in
            initializationStatus = false
        }
        return initializationStatus
    }
    
    func createToken() {
        guard let appConfig = appConfig else { return }
        showLoading.executer()
        let permissions = ["PMT_POST_Create_Single", "ACC_GET_Single"]
        GpApiService.generateTransactionKey(
            environment: .test,
            appId: appConfig.appId,
            appKey: appConfig.appKey,
            secondsToExpire: appConfig.secondsToExpire,
            intervalToExpire: appConfig.intervalToExpire,
            permissions: permissions) { [weak self] accessTokenInfo, error in
                UI {
                    self?.hideLoading.executer()
                    guard let accessTokenInfo = accessTokenInfo, let token = accessTokenInfo.token else {
                        self?.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    self?.tokenGenerated.value = token
                }
            }
    }
    
    func onHostedFieldsTokenError(_ message: String) {
        hideLoading.executer()
        showDataResponse.value = (.error, ApiException(message: message))
    }
    
    func onSubmitAction() {
        showLoading.executer()
    }
    
    func checkEnrollment(_ token: String, brand: String) {
        cardBrand = brand
        tokenizedCard = CreditCardData()
        tokenizedCard?.token = token
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .withAuthenticationSource(.mobileSDK)
            .execute { secureEcom, error in
                UI {
                    guard let secureEcom = secureEcom else {
                        self.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    
                    if secureEcom.enrolled != self.ENROLLED {
                        self.chargeCard(authResult: secureEcom)
                    } else {
                        self.initializationNetcetera(secureEcom: secureEcom)
                    }
                }
            }
    }
    
    private func initializationNetcetera(secureEcom: ThreeDSecure? = nil) {
        if (secureEcom?.status == "AVAILABLE" ) {
            let _ = initThreeDS2Service()
            createTransaction(secureEcom: secureEcom)
        }else {
            showDataResponse.value = (.error, ApiException(message: "Validate Card with other flow"))
        }
    }
    
    private func createTransaction(secureEcom: ThreeDSecure?) {
        guard let secureEcom = secureEcom else {
            showDataResponse.value = (.error, ApiException(message: "SecureEcom is Nil"))
            return
        }

        do {
            transaction = try threeDS2Service.createTransaction(directoryServerId: getDsRidCard(), messageVersion: secureEcom.messageVersion
            )
            if let netceteraParams = try transaction?.getAuthenticationRequestParameters(){
                authenticateTransaction(secureEcom, netceteraParams)
            }
        } catch {
            self.showDataResponse.value = (.error, GenericMessage(message: error.localizedDescription))
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
                        self.showDataResponse.value = (.error, error as Any)
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
                guard let viewController = viewController else { return }
                try self.transaction?.doChallenge(challengeParameters: challengeParameters,
                                                  challengeStatusReceiver: challengeStatusReceiver,
                                                  timeOut:10,
                                                  inViewController: viewController)
            } catch {
                showDataResponse.value = (.error, error as Any)
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
                        self.showDataResponse.value = (.error, error as Any)
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
                        self.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    
                    if self.isPaymentRecurring {
                        self.recurringPayment(cardChargeResult: chargeResult)
                    } else {
                        self.showDataResponse.value = (.success, chargeResult)
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
                        self.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    self.showDataResponse.value = (.success, chargeResult)
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
            self.showDataResponse.value = (.error, ApiException(message: message))
        }
    }
    
    func showSuccessScreen(with message: String) {
    }
    
    func successChallenge(by secureEcom: ThreeDSecure) {
        if let transactionId = secureEcom.serverTransactionId {
            self.doAuth(transactionId)
        }
    }
}
