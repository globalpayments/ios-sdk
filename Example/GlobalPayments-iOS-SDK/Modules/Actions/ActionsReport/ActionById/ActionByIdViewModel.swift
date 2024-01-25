import Foundation
import GlobalPayments_iOS_SDK

final class ActionByIdViewModel: BaseViewModel {
    
    private lazy var actionId: String = ""
    
    
    func getActionById() {
        showLoading.executer()
        let reportingService = ReportingService.actionDetail(actionId: actionId)
        reportingService.execute(completion: showOutput)
    }
    
    private func showOutput(summary: ActionSummary?, error: Error?) {
        UI {
            guard let summary = summary else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            self.showDataResponse.value = (.success, summary)
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .actionId:
            actionId = value
        default:
            break;
        }
    }
}
