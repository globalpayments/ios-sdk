import Foundation
import GlobalPayments_iOS_SDK

protocol DepositsViewInput {
    var deposits: [DepositSummary] { get set }
    func getDeposit(form: DepositByIDForm)
    func getDeposits(form: DepositsListForm)
    func clearViewModels()
}

protocol DepositsViewOutput: class {
    func showErrorView(error: Error?)
    func reloadData()
    func displayEmptyView()
}

final class DepositsViewModel: DepositsViewInput {

    weak var view: DepositsViewOutput?

    var deposits = [DepositSummary]() {
        didSet {
            view?.reloadData()
        }
    }

    func getDeposit(form: DepositByIDForm) {
        ReportingService
            .depositDetail(depositReference: form.depositReference)
            .execute { [weak self] summary, error in
                UI {
                    guard let depositSummary = summary else {
                        self?.view?.showErrorView(error: error)
                        return
                    }
                    self?.deposits = [depositSummary]
                    if self?.deposits.count == .zero {
                        self?.view?.displayEmptyView()
                    }
                }
            }
    }

    func getDeposits(form: DepositsListForm) {
        let reportingService = ReportingService.findDepositsPaged(page: form.page, pageSize: form.pageSize)

        reportingService
            .orderBy(depositOrderBy: form.orderBy, form.order)
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
                        self?.view?.showErrorView(error: error)
                        return
                    }
                    self?.deposits = depositsList.results
                    if self?.deposits.count == .zero {
                        self?.view?.displayEmptyView()
                    }
                }
            }
    }

    func clearViewModels() {
        deposits.removeAll()
    }
}
