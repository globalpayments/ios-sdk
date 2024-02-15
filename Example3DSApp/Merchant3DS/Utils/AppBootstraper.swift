import Foundation
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
    }
}
