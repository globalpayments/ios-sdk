import Foundation
import GlobalPayments_iOS_SDK

final class DisputeListFormViewModel: BaseViewModel {
    
    private lazy var useCase = DisputeListFormUseCase()
    
    func getDisputeList() {
        showLoading.executer()
        let form = useCase.form
        let reportingService = (form.source == .regular) ?
            ReportingService.findDisputesPaged(page: form.page, pageSize: form.pageSize) :
            ReportingService.findSettlementDisputesPaged(page: form.page, pageSize: form.pageSize)

        reportingService
            .orderBy(disputeOrderBy: form.sortProperty ?? .fromStageTimeCreated, form.sortOrder ?? .descending)
            .withArn(form.arn)
            .withDisputeStatus(form.status)
            .where(form.stage ?? .arbitration)
            .and(searchCriteria: .cardBrand, value: form.brand)
            .and(dataServiceCriteria: .startStageDate, value: form.fromStageTimeCreated)
            .and(dataServiceCriteria: .endStageDate, value: form.toStageTimeCreated)
            .and(dataServiceCriteria: .merchantId, value: form.systemMID)
            .and(dataServiceCriteria: .systemHierarchy, value: form.systemHierarchy)
            .execute(completion: handleDisputesResult)
    }
    
    private func handleDisputesResult(summary: PagedResult<DisputeSummary>?, error: Error?) {
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
        useCase.fieldDataChanged(value: value, type: type)
    }
    
    func setFromSettlements(_ value: Bool) {
        useCase.setSettlement(value: value)
    }
}
