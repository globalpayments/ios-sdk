import Foundation

private enum ApplicationKeys: String {
    case appConfiguration
}

extension ValuesKeys {
    static let appConfiguration = ValuesKey<Config>(ApplicationKeys.appConfiguration.rawValue)
}
