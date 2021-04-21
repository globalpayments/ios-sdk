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
    func displayEmptyView()
}

final class TransactionReportViewModel: TransactionReportViewInput {

    weak var view: TransactionReportViewOutput?
    var transactions = [TransactionSummary]() {
        didSet {
            view?.reloadData()
        }
    }

    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func getTransactionByID(_ id: String) {
        ReportingService
            .transactionDetail(transactionId: id)
            .execute { [weak self] transactionSummary, error in
                UI {
                    guard let transactionSummary = transactionSummary else {
                        self?.view?.showErrorView(error: error)
                        return
                    }
                    self?.transactions = [transactionSummary]
                    if self?.transactions.count == .zero {
                        self?.view?.displayEmptyView()
                    }
                }
            }
    }

    func getTransactions(form: TransactionListForm) {
        updateConfiguration(from: form)
        let reportingService = (form.source == .regular) ?
            ReportingService.findTransactionsPaged(page: form.page, pageSize: form.pageSize) :
            ReportingService.findSettlementTransactionsPaged(page: form.page, pageSize: form.pageSize)

        reportingService
            .orderBy(transactionSortProperty: form.sortProperty, form.sordOrder)
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
            .and(searchCriteria: .startDate, value: form.startDate)
            .and(searchCriteria: .endDate, value: form.endDate)
            .and(searchCriteria: .batchId, value: form.batchId)
            .execute { [weak self] transactionSummaryList, error in
                UI {
                    guard let transactionSummaryList = transactionSummaryList else {
                        self?.view?.showErrorView(error: error)
                        return
                    }
                    self?.transactions = transactionSummaryList.results
                    if self?.transactions.count == .zero {
                        self?.view?.displayEmptyView()
                    }
                }
            }
    }

    private func updateConfiguration(from form: TransactionListForm) {
        guard let channel = form.channel else { return }
        guard var config = configuration.loadConfig() else { return }
        config.channel = channel

        do {
            try configuration.saveConfig(config)
            updateConfig()
        } catch {
            view?.showErrorView(error: error)
        }
    }

    private func updateConfig() {
        guard let appConfig = configuration.loadConfig() else { return }
        configureContainer(with: appConfig)
    }

    private func configureContainer(with appConfig: Config) {
        let config = GpApiConfig(
            appId: appConfig.appId,
            appKey: appConfig.appKey,
            secondsToExpire: appConfig.secondsToExpire,
            intervalToExpire: appConfig.intervalToExpire,
            channel: appConfig.channel,
            language: appConfig.language,
            country: appConfig.country
        )
        config.environment = .test

        do {
            try ServicesContainer.configureService(
                config: config
            )
        } catch {
            view?.showErrorView(error: error)
        }
    }

    func clearViewModels() {
        transactions.removeAll()
    }
}
