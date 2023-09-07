import Foundation
import ThreeDS_SDK

/// Protocol defining methods for initializing the SDK and verifying its warnings.
protocol InitializationUseCase {
    
    /// Checks the initializing status of the SDK.
    ///
    /// - Parameters:
    ///   - succesHandler: Closure for when the SDK initialization is successful.
    ///   - errorHandler: Closure for when the SDK initialization is with errors containing the
    ///     error message.
    func initializeSDK(succesHandler: @escaping InitializationCompleteHandler,
                       errorHandler: @escaping ErrorHandler)
    
    /// Method which verifies the warnings during the SDK initialization.
    ///
    /// - Parameter errorHandler: Closure called when warnings are present with an error
    ///   message containing all warning messages
    func verifyWarnings(errorHandler: @escaping ErrorHandler)
    
    /// Configure all the SDK Schemes.
    func configureSDK() throws -> ConfigParameters
}
