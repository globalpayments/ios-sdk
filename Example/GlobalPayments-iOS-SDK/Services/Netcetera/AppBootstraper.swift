import Foundation
import GirdersSwift
import ThreeDS_SDK

class AppBootstraper {
    
    static func setupApp() {
        setupContainer()
    }
    
    private static func setupContainer() {
        
        Container.addSingleton { () -> ThreeDS2Service in
            ThreeDS2ServiceSDK()
        }
        
        Container.addPerRequest { () -> InitializationUseCase in
            InitializationUseCaseImplementation()
        }
        
        Container.addPerRequest{ () -> ConfigurationDataUseCase in
            ConfigurationUseCaseImplementation()
        }
    }
}
