import Foundation
import GlobalPayments_iOS_SDK

final class ActionsListViewModel: BaseViewModel {
    
    private lazy var useCase = ActionsListUseCase()
    
    func getActions() {
        showLoading.executer()
        let form = useCase.form
        let reportingService = ReportingService.findActionsPaged(page: form.page ?? 1, pageSize: form.pageSize ?? 5)
        reportingService
            .orderBy(actionOrderBy: form.orderBy ?? .timeCreated, form.order ?? .descending)
            .withActionId(form.id)
            .where(.startDate, form.fromTimeCreated)
            .and(searchCriteria: .endDate, value: form.toTimeCreated)
            .and(searchCriteria: .actionType, value: form.type)
            .and(searchCriteria: .resource, value: form.resource)
            .and(searchCriteria: .resourceStatus, value: form.resourceStatus)
            .and(searchCriteria: .resourceId, value: form.resourceId)
            .and(searchCriteria: .merchantName, value: form.merchantName)
            .and(searchCriteria: .accountName, value: form.accountName)
            .and(searchCriteria: .responseCode, value: form.responseCode)
            .and(searchCriteria: .httpResponseCode, value: form.httpResponseCode)
            .and(searchCriteria: .appName, value: form.appName)
            .and(searchCriteria: .version, value: form.version)
            .execute(completion: showOutput)
    }
    
    private func showOutput(summary: PagedResult<ActionSummary>?, error: Error?) {
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
}
