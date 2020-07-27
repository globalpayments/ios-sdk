import Foundation

public class Configuration {
    /// Timeout value for gateway communication (in seconds)
    public var timeout: Int = 65
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
