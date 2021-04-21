import UIKit
import GlobalPayments_iOS_SDK

final class TransactionView: UIView {

    @IBOutlet private weak var transactionIdLabel: UILabel!
    @IBOutlet private weak var transactionIdContentLabel: SelectableLabel!
    @IBOutlet private weak var timeCreatedLabel: UILabel!
    @IBOutlet private weak var timeCreatedContentLabel: SelectableLabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusContentLabel: SelectableLabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountContentLabel: SelectableLabel!
    @IBOutlet private weak var referenceLabel: UILabel!
    @IBOutlet private weak var referenceContentLabel: SelectableLabel!
    @IBOutlet private weak var batchIdLabel: UILabel!
    @IBOutlet private weak var batchIdContentLabel: SelectableLabel!
    @IBOutlet private weak var resultCodeLabel: UILabel!
    @IBOutlet private weak var resultCodeContentLabel: SelectableLabel!

    class func instantiateFromNib() -> TransactionView {
        let nib = UINib(nibName: "TransactionView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! TransactionView
        nib.setupUI()

        return nib
    }

    private func setupUI() {
        transactionIdLabel?.text = "transaction.view.transaction.id".localized()
        timeCreatedLabel?.text = "transaction.view.time.created".localized()
        statusLabel?.text = "transaction.view.status".localized()
        amountLabel?.text = "transaction.view.amount".localized()
        referenceLabel?.text = "transaction.view.reference".localized()
        batchIdLabel?.text = "transaction.view.batch.id".localized()
        resultCodeLabel?.text = "transaction.view.result.code".localized()
    }

    func display(_ transaction: Transaction) {
        transactionIdContentLabel.text = transaction.transactionId
        timeCreatedContentLabel.text = transaction.timestamp
        statusContentLabel.text = transaction.responseMessage
        amountContentLabel.text = transaction.balanceAmount?.description
        referenceContentLabel.text = transaction.referenceNumber
        batchIdContentLabel.text = transaction.batchSummary?.sequenceNumber
        resultCodeContentLabel.text = transaction.responseCode
    }
}
