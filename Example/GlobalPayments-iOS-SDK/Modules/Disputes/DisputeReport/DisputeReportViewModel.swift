import Foundation
import GlobalPayments_iOS_SDK

protocol DisputeReportViewInput {
    var disputes: [DisputeSummary] { get set }
    func getDocument(form: DisputeDocumentForm)
    func getDisputeDetails(form: DisputeByIDForm)
    func getDusputeList(form: DisputeListForm)
    func clearDisputes()
}

protocol DisputeReportViewOutput: class {
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
        switch form.source {
        case .regular:
            ReportingService
                .findDisputes()
                .withPaging(form.page, form.pageSize)
                .orderBy(disputeOrderBy: form.sortProperty, form.sordOrder)
                .withArn(form.arn)
                .withDisputeStatus(form.status)
                .withDisputeStage(form.stage)
                .where(form.adjustmentFunding)
                .and(searchCriteria: .cardBrand, value: form.brand)
                .and(dataServiceCriteria: .startStageDate, value: form.fromStageTimeCreated)
                .and(dataServiceCriteria: .endStageDate, value: form.toStageTimeCreated)
                .and(dataServiceCriteria: .startAdjustmentDate, value: form.fromAdjustmentTimeCreated)
                .and(dataServiceCriteria: .endAdjustmentDate, value: form.toAdjustmentTimeCreated)
                .and(dataServiceCriteria: .merchantId, value: form.systemMID)
                .and(dataServiceCriteria: .systemHierarchy, value: form.systemHierarchy)
                .execute(completion: handleDisputesList)
        case .settlement:
            ReportingService
                .findSettlementDisputes()
                .withPaging(form.page, form.pageSize)
                .orderBy(disputeOrderBy: form.sortProperty, form.sordOrder)
                .withArn(form.arn)
                .withDisputeStatus(form.status)
                .withDisputeStage(form.stage)
                .where(form.adjustmentFunding)
                .and(searchCriteria: .cardBrand, value: form.brand)
                .and(dataServiceCriteria: .startStageDate, value: form.fromStageTimeCreated)
                .and(dataServiceCriteria: .endStageDate, value: form.toStageTimeCreated)
                .and(dataServiceCriteria: .startAdjustmentDate, value: form.fromAdjustmentTimeCreated)
                .and(dataServiceCriteria: .endAdjustmentDate, value: form.toAdjustmentTimeCreated)
                .and(dataServiceCriteria: .merchantId, value: form.systemMID)
                .and(dataServiceCriteria: .systemHierarchy, value: form.systemHierarchy)
                .execute(completion: handleDisputesList)
        }
    }

    func clearDisputes() {
        disputes.removeAll()
    }

    private func handleDocument(document: DocumentMetadata?, error: Error?) {
        DispatchQueue.main.async {
            guard let document = document else {
                self.view?.showErrorView(error: error)
                return
            }
            self.view?.showPDF(document.b64Content)
        }
    }

    private func handleDisputeSummary(disputeSummary: DisputeSummary?, error: Error?) {
        DispatchQueue.main.async {
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

    private func handleDisputesList(list: [DisputeSummary]?, error: Error?) {
        DispatchQueue.main.async {
            guard let disputeSummaryList = list else {
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
