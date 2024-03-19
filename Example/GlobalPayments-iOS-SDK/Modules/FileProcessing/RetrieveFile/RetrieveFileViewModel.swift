import Foundation
import GlobalPayments_iOS_SDK

final class RetrieveFileViewModel: BaseViewModel {
    
    private lazy var resourceId: String = ""
    
    func getFileDetailById() {
        showLoading.executer()
        let serviceDetails = FileProcessingService.getDetails(resourceId: resourceId)
        serviceDetails.execute(completion: showOutput)
    }
    
    private func showOutput(fileProcessor: FileProcessor?, error: Error?) {
        UI {
            guard let fileProcessor = fileProcessor else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            self.showDataResponse.value = (.success, fileProcessor)
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .resourceId:
            resourceId = value
        default:
            break;
        }
    }
}

