import Foundation
import GlobalPayments_iOS_SDK

final class TransactionListFormViewModel: BaseViewModel {
    
    private var useCase: TransactionListFormUseCase = TransactionListFormUseCase()
    
    func getTransactions() {
        showLoading.executer()
        let form: TransactionListForm = useCase.form
        let reportingService = (form.source == .regular) ?
        ReportingService.findTransactionsPaged(page: form.page, pageSize: form.pageSize) :
        ReportingService.findSettlementTransactionsPaged(page: form.page, pageSize: form.pageSize)
        
        reportingService
            .orderBy(transactionSortProperty: form.sortProperty ?? .timeCreated , form.sortOrder ?? .descending)
            .withAmount(form.amount)
            .withTransactionId(form.transactionId)
            .where(form.transactionStatus)
            .and(paymentType: form.type)
            .and(channel: form.channel)
            .and(paymentEntryMode: form.entryMode)
            .and(dataServiceCriteria: .currency, value: form.currency)
            .and(dataServiceCriteria: .country, value: form.country)
            .and(searchCriteria: .cardNumberFirstSix, value: form.numberFirst6)
            .and(searchCriteria: .cardNumberLastFour, value: form.numberLast4)
            .and(searchCriteria: .tokenFirstSix, value: form.tokenFirst6)
            .and(searchCriteria: .tokenLastFour, value: form.tokenLast4)
            .and(searchCriteria: .accountName, value: form.accountName)
            .and(searchCriteria: .cardBrand, value: form.cardBrand)
            .and(searchCriteria: .brandReference, value: form.brandReference)
            .and(searchCriteria: .authCode, value: form.authCode)
            .and(searchCriteria: .referenceNumber, value: form.referenceNumber)
            .and(searchCriteria: .startDate, value: form.startDate )
            .and(searchCriteria: .endDate, value: form.endDate)
            .and(searchCriteria: .batchId, value: form.batchId)
            .execute { [weak self] transactionSummaryList, error in
                UI {
                    guard let transactionSummaryList = transactionSummaryList else {
                        self?.showDataResponse.value = (.error, error as Any)
                        return
                    }
                    self?.showDataResponse.value = (.success, transactionSummaryList)
                }
            }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        useCase.fieldDataChanged(value: value, type: type)
    }
    
    func setSettlement(_ value: Bool){
        useCase.setSettlement(value: value)
    }
}
