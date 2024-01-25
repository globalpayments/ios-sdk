import Foundation
import GlobalPayments_iOS_SDK

final class BatchViewModel: BaseViewModel {
    
    private var batchReference: String = ""

    func closeBatch() {
        showLoading.executer()
        BatchService.closeBatch(
            batchReference: batchReference,
            completion: showOutput
        )
    }

    private func showOutput(batchSummary: BatchSummary?, error: Error?) {
        UI {
            guard let batchSummary = batchSummary else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            self.showDataResponse.value = (.success, batchSummary)
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .batchId:
            batchReference = value
        default:
            break
        }
    }
}
