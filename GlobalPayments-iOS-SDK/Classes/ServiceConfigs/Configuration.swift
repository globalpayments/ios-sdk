import Foundation

public class Configuration {
    /// Timeout value for gateway communication (in milliseconds)
    public var timeout: Int = 65000
    var environment: Environment = .test
    public var requestLogger: RequestLogger?
    /// Gateway service URL
    public var serviceUrl: String = .empty
    var validated: Bool = false

    init(services: ConfiguredServices) { }

    func configureContainer(services: ConfiguredServices) { }

    func validate() {
        validated = true
    }
}
