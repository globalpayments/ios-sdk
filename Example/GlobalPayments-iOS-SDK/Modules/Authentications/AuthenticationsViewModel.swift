import Foundation
import GlobalPayments_iOS_SDK

protocol AuthenticationsViewModelInput {
    func onCheckAvailability(form: CheckAvailabilityForm)
    func onGetResult(form: AuthenticationDataForm)
    func onInitiate(form: InitiateForm)
    func onFullFlow(form: InitiateForm)
    func onFinishChallenge(form: InitiateForm?, threeDSecure: ThreeDSecure?)
}

protocol AuthenticationsViewModelOutput: AnyObject {
    func showErrorView(error: Error?)
    func showThreeDSecure(_ threeDSecure: ThreeDSecure)
    func showTransaction(_ transaction: Transaction)
    func showChallengeWebView(_ form: InitiateForm, _ threeDSecure: ThreeDSecure)
}

final class AuthenticationsViewModel: AuthenticationsViewModelInput {
    weak var view: AuthenticationsViewModelOutput?

    private let notEnrolled: String = "NOT_ENROLLED"
    private let challengeRequired: String = "CHALLENGE_REQUIRED"
    private let available: String = "AVAILABLE"
    private let successAuthenticated: String = "SUCCESS_AUTHENTICATED"

    func onCheckAvailability(form: CheckAvailabilityForm) {
        checkEnrollment(
            card: form.card,
            authSource: form.authSource,
            currency: form.currency,
            amount: form.amount,
            completion: showOutput
        )
    }

    func onGetResult(form: AuthenticationDataForm) {
        getAuthenticationData(
            serverTransactionId: form.serverTransactionId,
            completion: showOutput
        )
    }

    func onInitiate(form: InitiateForm) {
        checkEnrollment(
            card: form.card,
            authSource: form.authSource,
            currency: form.currency,
            amount: form.amount) { threeDSecure, error in
                guard let threeDSecure = threeDSecure else {
                    self.showOutput(threeDSecure: nil, error: error)
                    return
                }
                guard let liabilityShift = threeDSecure.liabilityShift else { return }
                if liabilityShift == "NO" {
                    self.showOutput(threeDSecure: nil, error: ApiException(message: "Liability Shift is NO please select another card"))
                } else {
                    self.initiateAuthentication(
                        initiateForm: form,
                        threeDSecure: threeDSecure,
                        completion: self.showOutput
                    )
                }
            }
    }

    func onFullFlow(form: InitiateForm) {
        checkEnrollment(card: form.card,authSource: form.authSource, currency: form.currency, amount: form.amount) { [weak self] threeDSecure, error in
            guard let threeDSecure = threeDSecure else {
                self?.showOutput(threeDSecure: nil, error: error)
                return
            }
            guard let checkAvailabilityStatus = threeDSecure.status else { return }
            guard let version = threeDSecure.version else { return }

            if checkAvailabilityStatus == self?.notEnrolled {
                UI { self?.view?.showThreeDSecure(threeDSecure) }
            } else {
                if version == .one {
                    guard let liabilityShift = threeDSecure.liabilityShift else { return }
                    if liabilityShift == "YES" && checkAvailabilityStatus == self?.challengeRequired {
                        UI { self?.view?.showChallengeWebView(form, threeDSecure) }
                    } else if liabilityShift == "NO" {
                        self?.showOutput(threeDSecure: nil, error: ApiException(message: "3DS ONE is not supported anymore"))
                    }
                } else if version == .two {
                    if checkAvailabilityStatus == self?.available {
                        self?.initiateAuthentication(initiateForm: form, threeDSecure: threeDSecure) { threeDSecureInitAuthResult, bbb in
                            guard let threeDSecureInitAuthResult = threeDSecureInitAuthResult else {
                                self?.showOutput(threeDSecure: nil, error: bbb)
                                return
                            }
                            guard let status = threeDSecureInitAuthResult.status else { return }
                            if status == self?.challengeRequired {
                                UI { self?.view?.showChallengeWebView(form, threeDSecureInitAuthResult) }
                            } else if status == self?.successAuthenticated {
                                self?.getAuthenticationData(
                                    serverTransactionId: threeDSecureInitAuthResult.serverTransactionId,
                                    completion: { authThreeDSecure, authError in
                                        guard let authThreeDSecure = authThreeDSecure else {
                                            self?.showOutput(threeDSecure: nil, error: authError)
                                            return
                                        }
                                        self?.charge(
                                            card: form.card,
                                            amount: form.amount,
                                            currency: form.currency,
                                            threeDSecure: authThreeDSecure
                                        )
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    func onFinishChallenge(form: InitiateForm?, threeDSecure: ThreeDSecure?) {
        getAuthenticationData(
            serverTransactionId: threeDSecure?.serverTransactionId,
            completion: { [weak self ]authThreeDSecure, authError in
                guard let authThreeDSecure = authThreeDSecure else {
                    self?.showOutput(threeDSecure: nil, error: authError)
                    return
                }
                self?.charge(
                    card: form?.card,
                    amount: form?.amount,
                    currency: form?.currency,
                    threeDSecure: authThreeDSecure
                )
            }
        )
    }

    // MARK: - Service

    typealias ThreeDSecureCompletion = (ThreeDSecure?, Error?) -> Void

    private func checkEnrollment(card: CreditCardData,
                                 authSource: AuthenticationSource,
                                 currency: String?,
                                 amount: NSDecimalNumber?,
                                 completion: @escaping ThreeDSecureCompletion) {
        Secure3dService
            .checkEnrollment(paymentMethod: card)
            .withAuthenticationSource(authSource)
            .withCurrency(currency)
            .withAmount(amount)
            .execute(completion: completion)
    }

    private func initiateAuthentication(initiateForm: InitiateForm,
                                        threeDSecure: ThreeDSecure,
                                        completion: @escaping ThreeDSecureCompletion) {
        Secure3dService
            .initiateAuthentication(paymentMethod: initiateForm.card, secureEcom: threeDSecure)
            .withAmount(initiateForm.amount)
            .withCurrency(initiateForm.currency)
            .withAuthenticationSource(initiateForm.authSource)
            .withMethodUrlCompletion(initiateForm.mehodCompletion)
            .withOrderCreateDate(initiateForm.createDate)
            .withAddress(initiateForm.billingAddress, .billing)
            .withAddress(initiateForm.shippingAddress, .shipping)
            .withBrowserData(initiateForm.browserData)
            .execute(completion: completion)
    }

    private func getAuthenticationData(serverTransactionId: String?,
                                       payerAuthenticationResponse: String? = nil,
                                       completion: @escaping ThreeDSecureCompletion) {
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(serverTransactionId)
            .withPayerAuthenticationResponse(payerAuthenticationResponse)
            .execute(completion: completion)
    }

    private func showOutput(threeDSecure: ThreeDSecure?, error: Error?) {
        UI {
            guard let threeDSecure = threeDSecure else {
                self.view?.showErrorView(error: error)
                return
            }
            self.view?.showThreeDSecure(threeDSecure)
        }
    }

    private func charge(card: CreditCardData?, amount: NSDecimalNumber?, currency: String?, threeDSecure: ThreeDSecure) {
        card?.threeDSecure = threeDSecure
        card?.charge(amount: amount)
            .withCurrency(currency)
            .execute { transaction, error in
                UI {
                    guard let transaction = transaction else {
                        self.view?.showErrorView(error: error)
                        return
                    }
                    self.view?.showTransaction(transaction)
                }
            }
    }
}
