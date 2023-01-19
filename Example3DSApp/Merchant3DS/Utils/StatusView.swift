import Foundation

protocol StatusView: AnyObject {
    /// Shows the Error Screen with the appropriate message.
    ///
    /// - Parameter message: Error Message shown in the Error Screen.
    func showErrorScreen(with message: String)
    
    /// Shows Success Screen.
    func successChallenge(by secureEcom: AuthParamsResponse)
    
    /// Shows the Success Screen with the appropriate message.
    ///
    /// - Parameter message: Success Message shown in the Success Screen.
    func showSuccessScreen(with message: String)
}
