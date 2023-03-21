import Foundation
import GlobalPayments_iOS_SDK

protocol DisputeReportViewInput {
    var disputes: [DisputeSummary] { get set }
    func getDocument(form: DisputeDocumentForm)
    func getDisputeDetails(form: DisputeByIDForm)
    func getDusputeList(form: DisputeListForm)
    func clearDisputes()
}

protocol DisputeReportViewOutput: AnyObject {
    func showErrorView(error: Error?)
    func showPDF(_ data: Data)
    func reloadData()
    func displayEmptyView()
}

final class DisputeReportViewModel: DisputeReportViewInput {

    weak var view: DisputeReportViewOutput?

    var disputes = [DisputeSummary]() {
        didSet {
            view?.reloadData()
        }
    }

    func getDocument(form: DisputeDocumentForm) {
        ReportingService
            .findDisputeDocument(id: form.documentId, disputeId: form.disputeId)
            .execute(completion: handleDocument)
    }

    func getDisputeDetails(form: DisputeByIDForm) {
        switch form.source {
        case .regular:
            ReportingService
                .disputeDetail(disputeId: form.disputeId)
                .execute(completion: handleDisputeSummary)
        case .settlement:
            ReportingService
                .settlementDisputeDetail(disputeId: form.disputeId)
                .execute(completion: handleDisputeSummary)
        }
    }

    func getDusputeList(form: DisputeListForm) {
        let reportingService = (form.source == .regular) ?
            ReportingService.findDisputesPaged(page: form.page, pageSize: form.pageSize) :
            ReportingService.findSettlementDisputesPaged(page: form.page, pageSize: form.pageSize)

        reportingService
            .orderBy(disputeOrderBy: form.sortProperty, form.sordOrder)
            .withArn(form.arn)
            .withDisputeStatus(form.status)
            .where(form.stage)
            .and(searchCriteria: .cardBrand, value: form.brand)
            .and(dataServiceCriteria: .startStageDate, value: form.fromStageTimeCreated)
            .and(dataServiceCriteria: .endStageDate, value: form.toStageTimeCreated)
            .and(dataServiceCriteria: .merchantId, value: form.systemMID)
            .and(dataServiceCriteria: .systemHierarchy, value: form.systemHierarchy)
            .execute(completion: handleDisputesResult)
    }

    func clearDisputes() {
        disputes.removeAll()
    }

    private func handleDocument(document: DocumentMetadata?, error: Error?) {
        UI {
            guard let document = document else {
                self.view?.showErrorView(error: error)
                return
            }
            self.view?.showPDF(document.b64Content)
        }
    }

    private func handleDisputeSummary(disputeSummary: DisputeSummary?, error: Error?) {
        UI {
            guard let disputeSummary = disputeSummary else {
                self.view?.showErrorView(error: error)
                return
            }
            self.disputes = [disputeSummary]
            if self.disputes.count == .zero {
                self.view?.displayEmptyView()
            }
        }
    }

    private func handleDisputesResult(result: PagedResult<DisputeSummary>?, error: Error?) {
        UI {
            guard let disputeSummaryList = result?.results else {
                self.view?.showErrorView(error: error)
                return
            }
            self.disputes = disputeSummaryList
            if self.disputes.count == .zero {
                self.view?.displayEmptyView()
            }
        }
    }
}
