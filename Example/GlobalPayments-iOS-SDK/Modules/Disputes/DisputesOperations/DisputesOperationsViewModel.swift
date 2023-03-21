import Foundation
import GlobalPayments_iOS_SDK

protocol DisputesOperationsViewInput {
    func accceptDispute(form: DisputesOperationsForm)
    func challengeDispute(form: DisputesOperationsForm, documents: [DocumentInfo])
}

protocol DisputesOperationsViewOutput: AnyObject {
    func showErrorView(error: Error?)
    func showDisputeActionView(disputeAction: DisputeAction)
}

final class DisputesOperationsViewModel: DisputesOperationsViewInput {

    weak var view: DisputesOperationsViewOutput?

    func accceptDispute(form: DisputesOperationsForm) {
        ReportingService
            .acceptDispute(id: form.disputeId)
            .withIdempotencyKey(form.idempotencyKey)
            .execute(completion: handleDisputeAction)
    }

    func challengeDispute(form: DisputesOperationsForm, documents: [DocumentInfo]) {
        ReportingService
            .challangeDispute(id: form.disputeId, documents: documents)
            .withIdempotencyKey(form.idempotencyKey)
            .execute(completion: handleDisputeAction)
    }

    private func handleDisputeAction(action: DisputeAction?, error: Error?) {
        UI {
            guard let disputeAction = action else {
                self.view?.showErrorView(error: error)
                return
            }
            self.view?.showDisputeActionView(disputeAction: disputeAction)
        }
    }
}
