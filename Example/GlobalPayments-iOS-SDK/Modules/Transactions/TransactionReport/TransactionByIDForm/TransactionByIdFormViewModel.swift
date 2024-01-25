import Foundation
import GlobalPayments_iOS_SDK

final class TransactionByIdFormViewModel: BaseViewModel {
    
    private var transactionId: String = ""
    
    func getTransactionByID() {
        showLoading.executer()
        ReportingService
            .transactionDetail(transactionId: transactionId)
            .execute { [weak self] transactionSummary, error in
                UI {
                    guard let transactionSummary = transactionSummary else {
                        self?.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    self?.showDataResponse.value = (.success, transactionSummary)
                }
            }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .transactionId:
            transactionId = value
        default:
            break
        }
    }
}
