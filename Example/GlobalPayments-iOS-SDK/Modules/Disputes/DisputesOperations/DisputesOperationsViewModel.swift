import Foundation
import GlobalPayments_iOS_SDK

protocol DisputesOperationsViewInput {
    func accceptDispute(with id: String)
    func challengeDispute(with id: String, documents: [DocumentInfo])
}

protocol DisputesOperationsViewOutput: class {
    func showErrorView(error: Error?)
    func showDisputeActionView(disputeAction: DisputeAction)
}

final class DisputesOperationsViewModel: DisputesOperationsViewInput {

    weak var view: DisputesOperationsViewOutput?

    func accceptDispute(with id: String) {
        ReportingService
            .acceptDispute(id: id)
            .execute(completion: handleDisputeAction)
    }

    func challengeDispute(with id: String, documents: [DocumentInfo]) {
        ReportingService
            .challangeDispute(id: id, documents: documents)
            .execute(completion: handleDisputeAction)
    }

    private func handleDisputeAction(action: DisputeAction?, error: Error?) {
        DispatchQueue.main.async {
            guard let disputeAction = action else {
                self.view?.showErrorView(error: error)
                return
            }
            self.view?.showDisputeActionView(disputeAction: disputeAction)
        }
    }
}
