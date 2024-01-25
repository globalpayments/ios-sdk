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

final class DisputeReportViewModel {
}
