import Foundation
import ThreeDS_SDK

class AppBootstraper {
    
    static func setupApp() {
        setupContainer()
    }
    
    private static func setupContainer() {
        
        GpContainer.addSingleton { () -> ThreeDS2Service in
            ThreeDS2ServiceSDK()
        }
        
        GpContainer.addPerRequest { () -> InitializationUseCase in
            InitializationUseCaseImplementation()
        }
        
        GpContainer.addPerRequest{ () -> ConfigurationDataUseCase in
            ConfigurationUseCaseImplementation()
        }
    }
}
