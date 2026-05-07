import Foundation

protocol PaymentGateway {
    var supportsHostedPayments: Bool { get }

    /// Serializes and executes authorization transactions
    /// - Parameters:
    ///   - builder:  The transaction's builder
    ///   - completion: Transaction
    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?, Error?) -> Void)?)
    /// Serializes and executes follow up transactions
    /// - Parameters:
    ///   - builder: The transaction's builder
    ///   - completion: Transaction
    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?, Error?) -> Void)?)
    func serializeRequest(_ builder: AuthorizationBuilder) -> String?
}

extension PaymentGateway {
    func processSurchargeEligibilityLookup(_ builder: SurchargeEligibilityLookupBuilder,
                                           completion: ((Transaction?, Error?) -> Void)?) {
        completion?(nil, ApiException(message: "Surcharge eligibility lookup not supported"))
    }
}
