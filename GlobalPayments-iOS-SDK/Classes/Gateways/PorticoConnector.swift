import Foundation

public class PorticoConnector: PaymentGateway, ReportingServiceType {

    var supportsHostedPayments: Bool = false

    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?, Error?) -> Void)?) {

    }

    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?, Error?) -> Void)?) {
        
    }

    func serializeRequest(_ builder: AuthorizationBuilder) -> String? {
        return nil
    }

    func processReport<T>(builder: ReportBuilder<T>, completion: ((T?, Error?) -> Void)?) {
        
    }
}
