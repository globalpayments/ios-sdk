import Foundation
import GlobalPayments_iOS_SDK

struct Config: Codable {
    let appId: String
    let appKey: String
    let secondsToExpire: Int?
    let intervalToExpire: IntervalToExpire?
    var channel: Channel
    let language: Language?
    let country: String?
}

protocol Configuration {
    func loadConfig() -> Config?
    func saveConfig(_ config: Config) throws
}

struct ConfigutationService: Configuration {

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadConfig() -> Config? {
        defaults.get(.appConfiguration)
    }

    func saveConfig(_ config: Config) throws {
        try defaults.set(.appConfiguration, to: config)
    }
}
