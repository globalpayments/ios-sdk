import Foundation

struct GpApiRequest {
    var endpoint: String
    var method: HTTPMethod
    var requestBody: String?
    var queryParams: [String: String]?

    init(endpoint: String,
         method: HTTPMethod,
         requestBody: String? = nil,
         queryParams: [String: String]? = nil) {

        self.endpoint = endpoint
        self.method = method
        self.requestBody = requestBody
        self.queryParams = queryParams
    }
}

extension GpApiRequest {

    struct Endpoints {

        // MARK: - Access Token

        static func accesstoken() -> String {
            "/accesstoken"
        }

        // MARK: - Payment Methods

        static func paymentMethods() -> String {
            "/payment-methods"
        }

        static func paymentMethodsWith(token: String) -> String {
            "/payment-methods/\(token)"
        }

        static func paymentMethodsWith(paymentMethodId: String) -> String {
            "/payment-methods/\(paymentMethodId)"
        }

        // MARK: - Transactions

        static func transactions() -> String {
            "/transactions"
        }

        static func settlementTransactions() -> String {
            "/settlement/transactions"
        }

        static func transactionsWith(transactionId: String) -> String {
            "/transactions/\(transactionId)"
        }

        static func transactionsCapture(transactionId: String) -> String {
            "/transactions/\(transactionId)/capture"
        }

        static func transactionsRefund(transactionId: String) -> String {
            "/transactions/\(transactionId)/refund"
        }

        static func transactionsReversal(transactionId: String) -> String {
            "/transactions/\(transactionId)/reversal"
        }

        static func transactionsReauthorization(transactionId: String) -> String {
            "/transactions/\(transactionId)/reauthorization"
        }

        // MARK: - Verifications

        static func verify() -> String {
            "/verifications"
        }

        // MARK: - Deposits

        static func deposits() -> String {
            "/settlement/deposits"
        }

        static func deposit(id: String) -> String {
            "/settlement/deposits/\(id)"
        }

        // MARK: - Disputes

        static func disputes() -> String {
            "/disputes"
        }

        static func dispute(id: String) -> String {
            "/disputes/\(id)"
        }

        static func settlementDisputes() -> String {
            "/settlement/disputes"
        }

        static func settlementDispute(id: String) -> String {
            "/settlement/disputes/\(id)"
        }

        static func acceptDispute(id: String) -> String {
            "/disputes/\(id)/acceptance"
        }

        static func challengeDispute(id: String) -> String {
            "/disputes/\(id)/challenge"
        }

        static func document(id: String, disputeId: String) -> String {
            "/disputes/\(disputeId)/documents/\(id)"
        }

        // MARK: - Authentications

        static func authenticationCheckAvailability() -> String {
            "/authentications"
        }

        static func authenticationInitiate(id: String) -> String {
            "/authentications/\(id)/initiate"
        }

        static func authenticationResult(id: String) -> String {
            "/authentications/\(id)/result"
        }

        // MARK: - Batches

        static func batchClose(id: String) -> String {
            "/batches/\(id)"
        }

        // MARK: - Actions

        static func action(id: String) -> String {
            "/actions/\(id)"
        }

        static func actions() -> String {
            "/actions"
        }
    }
}
