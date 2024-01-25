import Foundation

protocol ConfigurationDataUseCase {
    func loadConfig() -> Config?
    func saveConfig(_ config: Config) throws
}
