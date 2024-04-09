import UIKit
import GlobalPayments_iOS_SDK
import ThreeDS_SDK

class UnifiedPaymentsViewModel: BaseViewModel {
    
    var validateChargeButton: Dynamic<Bool> = Dynamic(false)
    
    private var amount: NSDecimalNumber = 0.0
    private var currency: String = "USD"
    private var recurringPayment: Bool  = false
    private var cardNumber: String = ""
    private var cardExpiration: String = ""
    private var cvv: String = ""
    private var cardHolderName: String = ""
    private var isPaymentRecurring = false
    
    private let ENROLLED: String = "ENROLLED"
    private let CHALLENGE_REQUIRED = "CHALLENGE_REQUIRED"
    private let SUCCESS_AUTHENTICATED = "SUCCESS_AUTHENTICATED"
    private let SUCCESS = "SUCCESS"
    
    private lazy var initializationUseCase: InitializationUseCase = GpContainer.resolve()
    private lazy var threeDS2Service: ThreeDS2Service = GpContainer.resolve()
    private var transaction: ThreeDS_SDK.Transaction?
    private var tokenizedCard: CreditCardData?
    private var cardBrand: String?
    
    weak var viewController: UIViewController?
    
    func makePayment() {
        showLoading.executer()
        tokenizeCard()
    }
    
    private func tokenizeCard() {
        let card = CreditCardData()
        card.number = cardNumber
        
        let dateExpSplit = cardExpiration.split(separator: "/")
        let month = Int(dateExpSplit[0]) ?? 0
        let year = Int(dateExpSplit[1]) ?? 0
        card.expMonth = month
        card.expYear = year
        card.cvn = cvv
        card.cardHolderName = cardHolderName
        
        card.tokenize { [weak self] token, error in
            UI {
                if let error = error as? GatewayException {
                    self?.showDataResponse.value = (.error, error)
                    return
                }
                
                if let token = token, !token.isEmpty {
                    self?.checkEnrollment(token)
                }else {
                    self?.hideLoading.executer()
                }
            }
        }
    }
    
    func checkEnrollment(_ token: String) {
        tokenizedCard = CreditCardData()
        tokenizedCard?.token = token
        tokenizedCard?.cardHolderName = cardHolderName
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
                    
                    if (secureEcom.enrolled == self.ENROLLED) {
                        self.initializationNetcetera(secureEcom: secureEcom)
                    }else {
                        self.tokenizedCard?.threeDSecure = secureEcom
                        self.chargeCard(self.tokenizedCard)
                    }
                }
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
            showDataResponse.value = (.error, ApiException(message: "Please check Netcetera 3DS SDK"))
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
                guard let viewController = viewController else {
                    showDataResponse.value = (.error, ApiException(message: "No ViewController setted"))
                    return
                }
                try self.transaction?.doChallenge(challengeParameters: challengeParameters,
                                                  challengeStatusReceiver: challengeStatusReceiver,
                                                  timeOut:60,
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
                    
                    self.tokenizedCard?.threeDSecure = secureEcom
                    self.chargeCard(self.tokenizedCard)
                }
            }
    }
    
    private func chargeCard(_ tokenizedCard: CreditCardData?) {
        tokenizedCard?.charge(amount: amount)
            .withCurrency(currency)
            .execute { chargeResult, error in
                UI {
                    guard let chargeResult = chargeResult else {
                        self.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    
                    if self.recurringPayment {
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
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .amount:
            amount = NSDecimalNumber(string: value)
        case .cardNumber:
            cardNumber = value
        case .cardHolderName:
            cardHolderName = value
        case .cardCvv:
            cvv = value
        case .cardExpiryDate:
            cardExpiration = value
        default:
            break
        }
        
        validateFields()
    }
    
    private func validateFields() {
        guard amount.doubleValue > 0.0,
              !cardHolderName.isEmpty,
              !cardNumber.isEmpty,
              !cvv.isEmpty,
              !cardExpiration.isEmpty else {
            validateChargeButton.value = false
            return
        }
        
        validateChargeButton.value = true
    }
    
    private func getDsRidCard() -> String {
        switch cardBrand?.lowercased() {
        case "visa":
            return DsRidValues.visa
        default:
            return DsRidValues.visa
        }
    }
    
    func setMakeRecurring(_ value: Bool){
        recurringPayment = value
    }
}

extension UnifiedPaymentsViewModel: StatusView {
    
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
