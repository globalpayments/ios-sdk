import Foundation
import GlobalPayments_iOS_SDK

final class PaymentMethodsListViewModel: BaseViewModel {
    
    private lazy var useCase = PaymentMethodsListUseCase()
    
    
    func getPaymentMethods() {
        showLoading.executer()
        let form = useCase.form
        let reportingService = ReportingService.findStoredPaymentMethodsPaged(page: form.page ?? 1, pageSize: form.pageSize ?? 5)
//        reportBuilder.where<StoredPaymentMethodStatus>(SearchCriteria.StoredPaymentMethodStatus, model.status)
        reportingService
            .orderBy(depositOrderBy: form.orderBy ?? .timeCreated, form.order ?? .descending)
            .withStoredPaymentMethodId(form.id)
            .where(.startDate, form.fromTimeCreated)
            .and(searchCriteria: .endDate, value: form.toTimeCreated)
            .and(searchCriteria: .accountName, value: form.accountName)
            .and(searchCriteria: .referenceNumber, value: form.referenceNumber)
            .and(dataServiceCriteria: .startLastUpdatedDate, value: form.startLastUpdatedDate)
            .and(dataServiceCriteria: .endLastUpdatedDate, value: form.endLastUpdatedDate)
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
        useCase.fieldDataChanged(value: value, type: type)
    }
}
