import Foundation
import ThreeDS_SDK
import GirdersSwift

typealias InitializationCompleteHandler = () -> Void
typealias ErrorHandler = (_ errorMessage: String) -> Void

class InitializationUseCaseImplementation: InitializationUseCase {
    
    lazy var threeDS2Service: ThreeDS2Service = Container.resolve()
    
    func initializeSDK(succesHandler: @escaping InitializationCompleteHandler,
                       errorHandler: @escaping ErrorHandler) {
        do {
            let configParameters = try configureSDK()
            
            // Change uicustomization to nil for default design.
            let uicustomization = try createUICustomization()
            try threeDS2Service.initialize(configParameters,
                                           locale: nil,
                                           uiCustomization: uicustomization)
            succesHandler()
        }catch let error as NSError {
            print(error.localizedDescription)
            errorHandler(error.localizedDescription)
        }
    }
    
    func configureSDK() throws -> ConfigParameters {
        return try configureWithBuilder()
    }
    
    func configureWithBuilder() throws -> ConfigParameters {
        let configBuilder = ConfigurationBuilder()
        // License
        if let filepath = Bundle.main.path(forResource: "license", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                try configBuilder.license(key: contents)
            } catch {
                // contents could not be loaded
            }
        }
        
        // Schemes
        
        //Visa
        let visa = Scheme.visa()
        visa.encryptionKeyValue = "acs2022.pem"
        visa.rootCertificateValue = "acs2022.pem"
        
        try configBuilder.add(visa)
        
        try configBuilder.log(to: .debug)
        
        let configParams = configBuilder.configParameters()
        return configParams
    }
    
    
    func verifyWarnings(errorHandler: @escaping ErrorHandler) {
        
        var sdkWarnings: [Warning] = []
        do {
            sdkWarnings = try threeDS2Service.getWarnings()
        } catch let error as NSError {
            errorHandler(error.localizedDescription)
        } catch {
            errorHandler("ThreeDS SDK couldn't calculate warnings")
        }
        
        if sdkWarnings.count > 0 {
            var message = ""
            for warning in sdkWarnings {
                message = message + warning.getMessage()
                message = message + "\n"
            }
            
            errorHandler(message)
        }
        
    }
    
    /// Sets the UiCustomization for the NDM.
    /// The following function is made to serve as an example of how the UiCustomization of the app
    /// can be made. All of the functions called are optional and are completely based depending on
    /// how the developers wants to modify the app design.
    ///
    /// - Returns: UiCustomization
    /// - Throws: SDK Error
    func createUICustomization() throws -> UiCustomization {
        let uiCustomization = UiCustomization()
        
        let labelCustomization  = LabelCustomization()
        try labelCustomization.setHeadingTextFontSize(fontSize: 24)
        try labelCustomization.setTextFontSize(fontSize: 16)
        uiCustomization.setLabelCustomization(labelCustomization: labelCustomization)

        let textBoxCustomization = TextBoxCustomization()
        try textBoxCustomization.setBorderColor(hexColorCode: "#e4e4e4")
        try textBoxCustomization.setBorderWidth(borderWidth: 2)
        try textBoxCustomization.setCornerRadius(cornerRadius: 20)
        uiCustomization.setTextBoxCustomization(textBoxCustomization: textBoxCustomization)

        let toolbarCustomization = ToolbarCustomization()
        try toolbarCustomization.setBackgroundColor(hexColorCode: "#ec5851")
        try toolbarCustomization.setTextColor(hexColorCode: "#ffffff")
        try toolbarCustomization.setButtonText(buttonText: "Cancel")
        try toolbarCustomization.setHeaderText(headerText: "Secure Checkout")
        uiCustomization.setToolbarCustomization(toolbarCustomization: toolbarCustomization)

        let submitButtonCustomization = ButtonCustomization()
        try submitButtonCustomization.setBackgroundColor(hexColorCode: "#ec5851")
        try submitButtonCustomization.setCornerRadius(cornerRadius: 20)
        try submitButtonCustomization.setTextFontSize(fontSize: 14)
        try submitButtonCustomization.setTextColor(hexColorCode: "#ffffff")
        try uiCustomization.setButtonCustomization(buttonCustomization: submitButtonCustomization, btnType: "SUBMIT")
        try uiCustomization.setButtonCustomization(buttonCustomization: submitButtonCustomization, btnType: "CONTINUE")
        try uiCustomization.setButtonCustomization(buttonCustomization: submitButtonCustomization, btnType: "NEXT")

        let resendButtonCustomization = ButtonCustomization()
        try resendButtonCustomization.setBackgroundColor(hexColorCode: "#f6dddc")
        try resendButtonCustomization.setCornerRadius(cornerRadius: 20)
        try resendButtonCustomization.setTextColor(hexColorCode: "#000000")
        try resendButtonCustomization.setTextFontSize(fontSize: 14)
        uiCustomization.setButtonCustomization(buttonCustomization: resendButtonCustomization, buttonType: .RESEND)

        let cancelButtonCustomization = ButtonCustomization()
        try cancelButtonCustomization.setTextColor(hexColorCode: "#ffffff")
        try cancelButtonCustomization.setTextFontSize(fontSize: 14)
        uiCustomization.setButtonCustomization(buttonCustomization: cancelButtonCustomization, buttonType: .CANCEL)
        
        return uiCustomization
    }
}

