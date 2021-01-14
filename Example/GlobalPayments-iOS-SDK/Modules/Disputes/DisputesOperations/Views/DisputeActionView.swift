import UIKit
import GlobalPayments_iOS_SDK

final class DisputeActionView: UIView {

    @IBOutlet private weak var referenceLabel: UILabel!
    @IBOutlet private weak var referenceContentLabel: SelectableLabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusContentLabel: SelectableLabel!
    @IBOutlet private weak var stageLabel: UILabel!
    @IBOutlet private weak var stageContentLabel: SelectableLabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountContentLabel: SelectableLabel!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var currencyContentLabel: SelectableLabel!
    @IBOutlet private weak var reasonCodeLabel: UILabel!
    @IBOutlet private weak var reasonCodeContentLabel: SelectableLabel!
    @IBOutlet private weak var reasonDescriptionLabel: UILabel!
    @IBOutlet private weak var reasonDescriptionContentLabel: SelectableLabel!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var resultContentLabel: SelectableLabel!
    @IBOutlet private weak var documentsLabel: UILabel!
    @IBOutlet private weak var documentsContentLabel: SelectableLabel!

    class func instantiateFromNib() -> DisputeActionView {
        let nib = UINib(nibName: "DisputeActionView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! DisputeActionView
        nib.setupUI()

        return nib
    }

    private func setupUI() {
        referenceLabel?.text = "dispute.action.view.reference".localized()
        statusLabel?.text = "dispute.action.view.status".localized()
        stageLabel?.text = "dispute.action.view.stage".localized()
        amountLabel?.text = "dispute.action.view.amount".localized()
        currencyLabel?.text = "dispute.action.view.currency".localized()
        reasonCodeLabel?.text = "dispute.action.view.reason.code".localized()
        reasonDescriptionLabel?.text = "dispute.action.view.reason.description".localized()
        resultLabel?.text = "dispute.action.view.reason.result".localized()
        documentsLabel?.text = "dispute.action.view.documents".localized()
    }

    func display(_ action: DisputeAction) {
        referenceContentLabel.text = action.reference
        statusContentLabel.text = action.status?.mapped(for: .gpApi)
        stageContentLabel.text = action.stage?.mapped(for: .gpApi)
        amountContentLabel.text = action.amount?.description
        currencyContentLabel.text = action.currency
        reasonCodeContentLabel.text = action.reasonCode
        reasonDescriptionContentLabel.text = action.reasonDescription
        resultContentLabel.text = action.result?.mapped(for: .gpApi)
        documentsContentLabel.text = action.documents?.joined(separator: "\n") ?? "generic.empty".localized()
    }
}
