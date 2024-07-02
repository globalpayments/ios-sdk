import Foundation
import GlobalPayments_iOS_SDK

final class UploadFileViewModel: BaseViewModel {
    
    var validateUploadFileButton: Dynamic<Bool> = Dynamic(false)
    
    private var fileUrl: URL?
    
    func selectedFileToUpload(urls: [URL]) {
        fileUrl = urls.first
        validateFile()
    }
    
    func uploadFile() {
        showLoading.executer()
        let service = FileProcessingService.initiate()
        service.execute { fileProcessor, error in
            UI {
                guard let fileProcessor = fileProcessor else {
                    if let error = error as? GatewayException {
                        self.showDataResponse.value = (.error, error)
                    }
                    return
                }
                self.uploadFileFromUrl(urlToUpload: fileProcessor.uploadUrl)
            }
        }
    }
    
    private func uploadFileFromUrl(urlToUpload: String?) {
        let uploadDocumentClient = FileProcessingClient(uploadUrl: urlToUpload ?? "")
        uploadDocumentClient.uploadFile(file: fileUrl) { dataResponse, error in
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
}
