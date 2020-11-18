import Foundation
import GlobalPayments_iOS_SDK

protocol TransactionReportViewInput {
    var transactions: [TransactionSummary] { get set }
    func getTransactionByID(_ id: String)
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

    func clearViewModels() {
        transactions.removeAll()
    }
}
