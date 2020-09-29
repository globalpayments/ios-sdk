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

        static func transactionsCapture(transactionId: String) -> String {
            return "/ucp/transactions/\(transactionId)/capture"
        }

        static func transactionsRefund(transactionId: String) -> String {
            return "/ucp/transactions/\(transactionId)/refund"
        }

        static func transactionsReversal(transactionId: String) -> String {
            return "/ucp/transactions/\(transactionId)/reversal"
        }

        // MARK: - Others

        static func transactionId(_ transactionId: String) -> String {
            return "/\(transactionId)"
        }

        static func deposits() -> String {
            return "/ucp/settlement/deposits"
        }

        static func disputes() -> String {
            return "/ucp/disputes"
        }
    }
}
