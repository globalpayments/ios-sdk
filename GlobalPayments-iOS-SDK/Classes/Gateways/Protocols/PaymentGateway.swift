import Foundation

@objc public protocol PaymentGateway {
    var supportsHostedPayments: Bool { get }

    /// Serializes and executes authorization transactions
    /// - Parameter builder: The transaction's builder
    /// - Returns: Transaction
    func processAuthorization(_ builder: AuthorizationBuilder) -> Transaction?
    /// Serializes and executes follow up transactions
    /// - Parameter builder: The transaction's builder
    /// - Returns: Transaction
    func manageTransaction(_ builder: ManagementBuilder) -> Transaction?
    func processReport(_ builder: ReportBuilder) throws
    func serializeRequest(_ builder: AuthorizationBuilder) -> String?
}
