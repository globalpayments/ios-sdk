import Foundation
import ThreeDS_SDK

/// Implementation of ChallengeStatusReceiver protocol.
/// NOTE: The following code is made to serve as an example of ChallengeStatusReceiver protocol implementation.
/// The implementation of the methods is done only for the demo app purposes, and can vary depending of the
/// application flow and design.
class AppChallengeStatusReceiver: ChallengeStatusReceiver {
    
    weak var statusView: StatusView?
    let dsTransId: String?
    let secureEcom: AuthParamsResponse
    
    init(view: StatusView, dsTransId: String?, secureEcom: AuthParamsResponse) {
        self.statusView = view
        self.dsTransId = dsTransId
        self.secureEcom = secureEcom
    }
    
    /// Depending on the TransactionStatus from the completion event, this function decides whether
    /// it should display a success or an error screen with an appropriate message.
    /// This implementaiton can vary depending of the app flow and design.
    ///
    /// - Parameter completionEvent: Completion event received from the SDK
    func completed(completionEvent: CompletionEvent) {
        if TransactionStatus.AuthenticationSuccessful.rawValue == completionEvent.getTransactionStatus() {
            self.statusView?.successChallenge(by: secureEcom)
        } else {
            if let dsTransID = dsTransId {
                self.statusView?.showErrorScreen(with: "Challenge unsuccessful\ndsTransID: \(dsTransID)")
            } else {
                self.statusView?.showErrorScreen(with: "Challenge unsuccessful")
            }
        }
    }
    
    /// An implementation for the canceled method. It just shows an error screen. This implementaiton can vary
    /// depending of the app flow and design.
    func cancelled() {
        if let dsTransID = dsTransId {
            self.statusView?.showErrorScreen(with: "Challenge unsuccessful, cancelled by user\ndsTransID: \(dsTransID)")
        } else {
            self.statusView?.showErrorScreen(with: "Challenge unsuccessful, cancelled by user")
        }
    }
    
    /// An implementation for the timedout method. It just shows an error screen. This implementaiton can vary
    /// depending of the app flow and design.
    func timedout() {
        if let dsTransID = dsTransId {
            self.statusView?.showErrorScreen(with: "Challenge unsuccessful, transaction time has expired\ndsTransID: \(dsTransID)")
        } else {
            self.statusView?.showErrorScreen(with: "Challenge unsuccessful, transaction time has expired")
        }
    }
    
    /// Displays an error screen with a message generated from the protocol error event.
    /// This implementaiton can vary depending of the app flow and design.
    func protocolError(protocolErrorEvent: ProtocolErrorEvent) {
        var message: String = ""
        let errorMessage = protocolErrorEvent.getErrorMessage()
        
        if !errorMessage.getErrorDescription().isEmpty {
            message.append("Description: \(errorMessage.getErrorDescription())\n")
        }
        
        if !errorMessage.getErrorCode().isEmpty {
            message.append("Error code: \(errorMessage.getErrorCode())\n")
        }
        
        if let errorDetails = errorMessage.getErrorDetail(), !errorDetails.isEmpty {
            message.append("Details: \(errorDetails)\n")
        }
        
        if !errorMessage.getErrorComponent().isEmpty {
            message.append("Component: \(errorMessage.getErrorComponent())\n")
        }
        
        if !errorMessage.getErrorMessageType().isEmpty {
            message.append("Error message type: \(errorMessage.getErrorMessageType())\n")
        }
        
        if !errorMessage.getMessageVersionNumber().isEmpty {
            message.append("Version number: \(errorMessage.getMessageVersionNumber())\n")
        }
        
        if let dsTransId = dsTransId {
            message.append("dsTransID: \(dsTransId)\n")
        }

        self.statusView?.showErrorScreen(with: message)
    }
    
    /// An implementation for the runtimeError method. It just shows an error screen. This implementaiton can vary
    /// depending of the app flow and design.
    func runtimeError(runtimeErrorEvent: RuntimeErrorEvent) {
        var message: String = ""

        message.append("Description: \(runtimeErrorEvent.getErrorMessage())\n")

        if let errorCode = runtimeErrorEvent.getErrorCode() {
            message.append("Error code: \(errorCode)\n")
        }
        
        if let dsTransID = dsTransId {
            message.append("dsTransID: \(dsTransID)\n")
        }

        self.statusView?.showErrorScreen(with: message)
    }
}
