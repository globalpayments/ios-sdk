import Foundation

@objcMembers public class PorticoConnector: PaymentGateway {

    public var supportsHostedPayments: Bool = false

    public func processAuthorization(_ builder: AuthorizationBuilder) -> Transaction? {
        return nil
    }

    public func manageTransaction(_ builder: ManagementBuilder) -> Transaction? {
        return nil
    }

    public func processReport(_ builder: ReportBuilder) {

    }

    public func serializeRequest(_ builder: AuthorizationBuilder) -> String? {
        return nil
    }
}
