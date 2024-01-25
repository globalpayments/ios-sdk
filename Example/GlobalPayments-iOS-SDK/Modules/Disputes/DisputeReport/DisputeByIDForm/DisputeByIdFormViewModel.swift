import Foundation
import GlobalPayments_iOS_SDK

final class DisputeByIdFormViewModel: BaseViewModel {
    
    private lazy var disputeId: String = ""
    private lazy var source: DisputeByIDForm.Source = .regular
    
    func getDisputeDetails() {
        showLoading.executer()
        switch source {
        case .regular:
            ReportingService
                .disputeDetail(disputeId: disputeId)
                .execute(completion: handleDisputeSummary)
        case .settlement:
            ReportingService
                .settlementDisputeDetail(disputeId: disputeId)
                .execute(completion: handleDisputeSummary)
        }
    }
    
    private func handleDisputeSummary(summary: DisputeSummary?, error: Error?) {
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
        case .disputeId:
            disputeId = value
        default:
            break;
        }
    }
    
    func setFromSettlements(_ value: Bool) {
        source = value ? .settlement : .regular
    }
}
