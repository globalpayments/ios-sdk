import Foundation
import GlobalPayments_iOS_SDK

final class DepositsListFormViewModel: BaseViewModel {
    
    private var useCase = DepositsListFormUseCase()
    
    func getDeposits() {
        showLoading.executer()
        let form = useCase.form
        let reportingService = ReportingService.findDepositsPaged(page: form.page ?? 1, pageSize: form.pageSize ?? 5)

        reportingService
            .orderBy(depositOrderBy: form.orderBy ?? .timeCreated, form.order ?? .descending)
            .withDepositReference(form.id)
            .withDepositStatus(form.status)
            .withAmount(form.amount)
            .where(.startDate, form.fromTimeCreated)
            .and(searchCriteria: .endDate, value: form.toTimeCreated)
            .and(searchCriteria: .accountName, value: form.accountName)
            .and(searchCriteria: .accountNumberLastFour, value: form.maskedNumber)
            .and(dataServiceCriteria: .merchantId, value: form.systemMID)
            .and(dataServiceCriteria: .systemHierarchy, value: form.systemHierarchy)
            .execute { [weak self] deposits, error in
                UI {
                    guard let depositsList = deposits else {
                        self?.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    self?.showDataResponse.value = (.success, depositsList)
                }
            }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        useCase.fieldDataChanged(value: value, type: type)
    }
}
