import Foundation
import GlobalPayments_iOS_SDK

protocol TransactionReportViewInput {
    var transactions: [TransactionSummary] { get set }
    func getTransactionByID(_ id: String)
    func getTransactions(form: TransactionListForm)
    func clearViewModels()
}

protocol TransactionReportViewOutput: class {
    func showErrorView(error: Error?)
    func reloadData()
}

final class TransactionReportViewModel: TransactionReportViewInput {

    weak var view: TransactionReportViewOutput?
    var transactions = [TransactionSummary]() {
        didSet {
            view?.reloadData()
        }
    }

    init() {
        do {
            try ServicesContainer.configureService(
                config: GpApiConfig(appId: Constants.gpApiAppID, appKey: Constants.gpApiAppKey)
            )
        } catch {
            view?.showErrorView(error: error)
        }
    }

    func getTransactionByID(_ id: String) {
        ReportingService
            .transactionDetail(transactionId: id)
            .execute { [weak self] transactionSummary, error in
                DispatchQueue.main.async {
                    guard let transactionSummary = transactionSummary else {
                        self?.view?.showErrorView(error: error)
                        return
                    }
                    self?.transactions = [transactionSummary]
                }
            }
    }

    func getTransactions(form: TransactionListForm) {
        ReportingService
            .findTransactions()
            .orderBy(transactionSortProperty: form.sortProperty, form.sordOrder)
            .withPaging(form.page, form.pageSize)
            .withTransactionId(form.transactionId)
            .where(form.transactionStatus)
            .and(searchCriteria: .accountName, value: form.accountName)
            .and(searchCriteria: .cardBrand, value: form.cardBrand)
            .and(searchCriteria: .aquirerReferenceNumber, value: form.arn)
            .and(searchCriteria: .brandReference, value: form.brandReference)
            .and(searchCriteria: .authCode, value: form.authCode)
            .and(searchCriteria: .referenceNumber, value: form.referenceNumber)
            .and(searchCriteria: .startDate, value: form.startDate)
            .and(searchCriteria: .endDate, value: form.endDate)
            .and(dataServiceCriteria: .depositReference, value: form.depositReference)
            .and(dataServiceCriteria: .startDepositDate, value: form.startDepositDate)
            .and(dataServiceCriteria: .endDepositDate, value: form.endDepositDate)
            .and(dataServiceCriteria: .startBatchDate, value: form.startBatchDate)
            .and(dataServiceCriteria: .endBatchDate, value: form.endBatchDate)
            .and(dataServiceCriteria: .merchantId, value: form.merchantId)
            .and(dataServiceCriteria: .systemHierarchy, value: form.systemHierarchy)
            .execute { [weak self] TransactionSummaryList, error in
                DispatchQueue.main.async {
                    guard let transactionSummaryList = TransactionSummaryList else {
                        self?.view?.showErrorView(error: error)
                        return
                    }
                    self?.transactions = transactionSummaryList
                }
            }
//            .and(dataServiceCriteria: .maskedCardNumber, value: form.maskedCardNumber)
    }

    func clearViewModels() {
        transactions.removeAll()
    }
}
