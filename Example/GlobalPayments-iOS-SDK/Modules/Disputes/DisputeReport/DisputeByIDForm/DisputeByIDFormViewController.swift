import UIKit

protocol DisputeByIDFormDelegate: class {
    func onComletedForm(_ form: DisputeByIDForm)
}

final class DisputeByIDFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Disputes"

    private let defaultDisputeId = "DIS_SAND_abcd1235"

    weak var delegate: DisputeByIDFormDelegate?

    @IBOutlet private weak var disputeLabel: UILabel!
    @IBOutlet private weak var disputeTextField: UITextField!
    @IBOutlet private weak var settlementsLabel: UILabel!
    @IBOutlet private weak var settlementSwitch: UISwitch!
    @IBOutlet private weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "dispute.by.id.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        disputeLabel.text = "dispute.by.id".localized()
        disputeTextField.text = defaultDisputeId
        settlementsLabel.text = "dispute.by.id.settlements".localized()
        submitButton.apply(style: .globalPayStyle, title: "dispute.by.id.submit".localized())
        hideKeyboardWhenTappedAround()
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let disputeId = disputeTextField.text, !disputeId.isEmpty else { return }
        let source: DisputeByIDForm.Source = settlementSwitch.isOn ? .settlement : .regular
        let form = DisputeByIDForm(disputeId: disputeId, source: source)
        delegate?.onComletedForm(form)
        dismiss(animated: true, completion: nil)
    }
}
