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
            .depositDetail(depositId: form.depositId)
            .execute { [weak self] summary, error in
                DispatchQueue.main.async {
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
        ReportingService
            .findDeposits()
            .withPaging(form.page, form.pageSize)
            .orderBy(depositOrderBy: form.orderBy, form.order)
            .withDepositId(form.id)
            .withDepositStatus(form.status)
            .withAmount(form.amount)
            .where(.startDate, form.fromTimeCreated)
            .and(searchCriteria: .endDate, value: form.toTimeCreated)
            .and(searchCriteria: .accountName, value: form.accountName)
            .and(searchCriteria: .accountNumberLastFour, value: form.maskedNumber)
            .and(dataServiceCriteria: .merchantId, value: form.systemMID)
            .and(dataServiceCriteria: .systemHierarchy, value: form.systemHierarchy)
            .execute { [weak self] deposits, error in
                DispatchQueue.main.async {
                    guard let depositsList = deposits else {
                        self?.view?.showErrorView(error: error)
                        return
                    }
                    self?.deposits = depositsList
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
