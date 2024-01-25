import Foundation

final class ConfigurationViewModel: BaseViewModel {
    
    private let configuration: Configuration
    var initConfig: Dynamic<Config?> = Dynamic(nil)
    var configUpdated: Dynamic<Void> = Dynamic(())
    private lazy var useCase = ConfigurationUseCase()

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    override func viewDidLoad() {
        if let config = configuration.loadConfig() {
            initConfig.value = config
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        useCase.fieldDataChanged(value: value, type: type)
    }
    
    func saveConfiguration(){
        do {
            let config = useCase.getConfig()
            try configuration.saveConfig(config)
            configUpdated.executer()
        } catch {
        }
    }
}
