import Foundation
import GlobalPayments_iOS_SDK

protocol StatusView: AnyObject {
    /// Shows the Error Screen with the appropriate message.
    ///
    /// - Parameter message: Error Message shown in the Error Screen.
    func showErrorScreen(with message: String)
    
    /// Shows Success Screen.
    func successChallenge(by secureEcom: ThreeDSecure)
    
    /// Shows the Success Screen with the appropriate message.
    ///
    /// - Parameter message: Success Message shown in the Success Screen.
    func showSuccessScreen(with message: String)
}
