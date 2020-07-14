import Foundation

public class PorticoConnector: PaymentGateway {

    var supportsHostedPayments: Bool = false

    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?) -> Void)?) {

    }

    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?) -> Void)?) {
        
    }

    func serializeRequest(_ builder: AuthorizationBuilder) -> String? {
        return nil
    }

    func processReport<T>(_ builder: ReportBuilder<T>) throws where T : AnyObject {
        
    }
}
