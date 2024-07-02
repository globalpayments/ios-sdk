import Foundation
import GlobalPayments_iOS_SDK

final class MerchantDocumentViewModel: BaseViewModel {
    
    var validateUploadFileButton: Dynamic<Bool> = Dynamic(false)
    
    private var fileUrl: URL?
    private var merchantId: String?
    private var docCategory: MerchantDocumentCategory = .identity_verification
    private var docType: MerchantDocumentType = .tif
    
    func selectedFileToUpload(urls: [URL]) {
        fileUrl = urls.first
        validateFile()
    }
    
    func uploadDocument() {
        showLoading.executer()
        let dataDocument = DocumentUploadData()
        dataDocument.docCategory = docCategory
        dataDocument.docType = docType
        
        guard let fileUrl = fileUrl else { return hideLoading.executer() }
        
        do {
            let data = try Data(contentsOf: fileUrl)
            let base64String = data.base64EncodedString()
            dataDocument.document = base64String
            uploadDocument(data: dataDocument)
        } catch {
            self.showDataResponse.value = (.error, error)
        }
    }
    
    func uploadDocument(data: DocumentUploadData){
        let user = User.fromId(from: merchantId ?? "", userType: .merchant)
        user.uploadDocument(data: data)
            .execute { dataResponse, error in
                UI {
                    guard let _ = dataResponse else {
                        if let error = error as? GatewayException {
                            self.showDataResponse.value = (.error, error)
                        }
                        return
                    }
                    self.showDataResponse.value = (.success, GenericMessage(message: "File Uploaded Successfully"))
                }
            }
    }
    
    private func validateFile() {
        guard let _ = fileUrl else { return validateUploadFileButton.value = false}
        validateUploadFileButton.value = true
    }
    
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .merchantId:
            merchantId = value
        case .merchantDocumentCategory:
            docCategory = MerchantDocumentCategory(value: value.lowercased()) ?? .identity_verification
        case .merchantDocumentType:
            docType = MerchantDocumentType(value: value.lowercased()) ?? .tif
        default:
            break
        }
    }
}
