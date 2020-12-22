import UIKit
import GlobalPayments_iOS_SDK

final class DisputesOperationsViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Disputes"

    var viewModel: DisputesOperationsViewInput!

    @IBOutlet private weak var initiateButton: UIButton!
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "disputes.operations.title".localized()
        initiateButton.apply(style: .globalPayStyle, title: "disputes.operations.initiate.opearation".localized())
        activityIndicator.stopAnimating()
    }

    // MARK: - Actions

    @IBAction private func onInitiateDisputeOperation() {
        let form = DisputesOperationsFormBuilder.build(with: self)
        present(form, animated: true, completion: nil)
    }
}

// MARK: - DisputesOperationsViewOutput

extension DisputesOperationsViewController: DisputesOperationsViewOutput {

    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }

    func showDisputeActionView(disputeAction: DisputeAction) {
        activityIndicator.stopAnimating()
        let disputeActionView = DisputeActionView.instantiateFromNib()
        disputeActionView.display(disputeAction)
        supportView.addSubview(disputeActionView)
        disputeActionView.bindFrameToSuperviewBounds()
    }
}

// MARK: - DisputesOperationsFormDelegate

extension DisputesOperationsViewController: DisputesOperationsFormDelegate {

    func onAcceptDispute(_ disputeId: String) {
        activityIndicator.startAnimating()
        viewModel.accceptDispute(with: disputeId)
        supportView.clearSubviews()
    }

    func onChallengeDispute(_ disputeId: String, documents: [DocumentInfo]) {
        activityIndicator.startAnimating()
        viewModel.challengeDispute(with: disputeId, documents: documents)
        supportView.clearSubviews()
    }
}
