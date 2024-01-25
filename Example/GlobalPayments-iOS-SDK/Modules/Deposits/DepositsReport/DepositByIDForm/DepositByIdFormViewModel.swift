import Foundation
import GlobalPayments_iOS_SDK

final class DepositByIdFormViewModel: BaseViewModel {
    
    private var depositId: String = ""
    
    func getDepositByID() {
        showLoading.executer()
        ReportingService
            .depositDetail(depositReference: depositId)
            .execute { [weak self] summary, error in
                UI {
                    guard let summary = summary else {
                        self?.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    self?.showDataResponse.value = (.success, summary)
                }
            }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .depositId:
            depositId = value
        default:
            break
        }
    }
}

