import Foundation
import GlobalPayments_iOS_SDK

final class AccountsListFormViewModel: BaseViewModel {
    
    private lazy var useCase = AccountsListFormUseCase()
    
    func getAccounts() {
        showLoading.executer()
        let form = useCase.form
        let reportingService = ReportingService.findMerchants(form.page ?? 1, pageSize: form.pageSize ?? 5)
        reportingService
            .orderBy(transactionSortProperty: form.orderBy ?? .timeCreated, form.order ?? .descending)
            .withId(form.id)
            .withMerchantStatus(form.status)
            .execute(completion: showOutput)
    }
    
    private func showOutput(summary: PagedResult<MerchantSummary>?, error: Error?) {
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
