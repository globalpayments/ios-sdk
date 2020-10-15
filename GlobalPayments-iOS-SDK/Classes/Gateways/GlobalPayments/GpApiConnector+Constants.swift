import Foundation

extension GpApiConnector {

    struct Header {

        struct Key {
            static let version: String = "X-GP-Version"
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
            return "/ucp/payment-methods"
        }

        static func paymentMethodsWith(token: String) -> String {
            return "/ucp/payment-methods/\(token)"
        }

        static func paymentMethodsEdit(token: String) -> String {
            return "/ucp/payment-methods/\(token)/edit"
        }

        static func paymentMethodsDelete(token: String) -> String {
            return "/ucp/payment-methods/\(token)/delete"
        }

        static func paymentMethodsDetokenize(token: String) -> String {
            return "/ucp/payment-methods/\(token)/detokenize"
        }

        // MARK: - Transactions

        static func transactions() -> String {
            return "/ucp/transactions"
        }

        static func transactionsWith(transactionId: String) -> String {
            return "/ucp/transactions/\(transactionId)"
        }

        static func transactionsCapture(transactionId: String) -> String {
            return "/ucp/transactions/\(transactionId)/capture"
        }

        static func transactionsRefund(transactionId: String) -> String {
            return "/ucp/transactions/\(transactionId)/refund"
        }

        static func transactionsReversal(transactionId: String) -> String {
            return "/ucp/transactions/\(transactionId)/reversal"
        }

        // MARK: - Deposits

        static func deposits() -> String {
            return "/ucp/settlement/deposits"
        }

        static func deposit(id: String) -> String {
            return "/ucp/settlement/deposits/\(id)"
        }

        // MARK: - Disputes

        static func disputes() -> String {
            return "/ucp/disputes"
        }

        static func dispute(id: String) -> String {
            return "/ucp/disputes/\(id)"
        }

        static func settlementDisputes() -> String {
            return "/ucp/settlement/disputes"
        }

        static func acceptDispute(id: String) -> String {
            return "/ucp/disputes/\(id)/acceptance"
        }

        static func challengeDispute(id: String) -> String {
            return "/ucp/disputes/\(id)/challenge"
        }

        static func document(id: String, disputeId: String) -> String {
            return "/ucp/disputes/\(disputeId)/documents/\(id)"
        }
    }
}
