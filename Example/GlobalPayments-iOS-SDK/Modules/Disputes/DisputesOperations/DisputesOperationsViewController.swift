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
