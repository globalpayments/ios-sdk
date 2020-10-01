import Foundation

public class RealexConnector: PaymentGateway, ReportingServiceType {

    var supportsHostedPayments: Bool = true

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
