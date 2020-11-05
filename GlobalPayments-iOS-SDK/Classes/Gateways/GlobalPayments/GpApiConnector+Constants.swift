import Foundation

extension GpApiConnector {

    struct Header {

        struct Key {
            static let version: String = "X-GP-Version"
            static let idempotency: String = "x-gp-idempotency"
            static let accept: String = "Accept"
            static let acceptEnconding: String = "Accept-Encoding"
            static let authorization: String = "Authorization"
        }

        struct Value {
            static let version: String = "2020-04-10"
            static let accept: String = "application/json"
            static let acceptEnconding: String = "gzip"
        }
    }

    struct Endpoints {

        // MARK: - Payment Methods

        static func paymentMethods() -> String {
            return "/payment-methods"
        }

        static func paymentMethodsWith(token: String) -> String {
            return "/payment-methods/\(token)"
        }

        static func paymentMethodsEdit(token: String) -> String {
            return "/payment-methods/\(token)/edit"
        }

        static func paymentMethodsDelete(token: String) -> String {
            return "/payment-methods/\(token)/delete"
        }

        static func paymentMethodsDetokenize(token: String) -> String {
            return "/payment-methods/\(token)/detokenize"
        }

        // MARK: - Transactions

        static func transactions() -> String {
            return "/transactions"
        }

        static func settlementTransactions() -> String {
            return "/settlement/transactions"
        }

        static func transactionsWith(transactionId: String) -> String {
            return "/transactions/\(transactionId)"
        }

        static func transactionsCapture(transactionId: String) -> String {
            return "/transactions/\(transactionId)/capture"
        }

        static func transactionsRefund(transactionId: String) -> String {
            return "/transactions/\(transactionId)/refund"
        }

        static func transactionsReversal(transactionId: String) -> String {
            return "/transactions/\(transactionId)/reversal"
        }

        // MARK: - Verifications

        static func verify() -> String {
            return "/verifications"
        }

        // MARK: - Deposits

        static func deposits() -> String {
            return "/settlement/deposits"
        }

        static func deposit(id: String) -> String {
            return "/settlement/deposits/\(id)"
        }

        // MARK: - Disputes

        static func disputes() -> String {
            return "/disputes"
        }

        static func dispute(id: String) -> String {
            return "/disputes/\(id)"
        }

        static func settlementDisputes() -> String {
            return "/settlement/disputes"
        }

        static func settlementDispute(id: String) -> String {
            return "/settlement/disputes/\(id)"
        }

        static func acceptDispute(id: String) -> String {
            return "/disputes/\(id)/acceptance"
        }

        static func challengeDispute(id: String) -> String {
            return "/disputes/\(id)/challenge"
        }

        static func document(id: String, disputeId: String) -> String {
            return "/disputes/\(disputeId)/documents/\(id)"
        }
    }
}
