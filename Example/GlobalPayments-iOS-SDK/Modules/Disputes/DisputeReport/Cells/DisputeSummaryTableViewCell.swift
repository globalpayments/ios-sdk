import UIKit
import GlobalPayments_iOS_SDK

final class DisputeSummaryTableViewCell: UITableViewCell, CellIdentifiable {

    private var documents: [DisputeDocument]?
    var onSelectDocuments: (([DisputeDocument]?) -> Void)?

    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var idContentLabel: SelectableLabel!
    @IBOutlet private weak var timeCreatedLabel: UILabel!
    @IBOutlet private weak var timeCreatedContentLabel: SelectableLabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusContentLabel: SelectableLabel!
    @IBOutlet private weak var stageLabel: UILabel!
    @IBOutlet private weak var stageContentLabel: SelectableLabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountContentLabel: SelectableLabel!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var currencyContentLabel: SelectableLabel!
    @IBOutlet private weak var midLabel: UILabel!
    @IBOutlet private weak var midContentLabel: SelectableLabel!
    @IBOutlet private weak var merchantHierarchyLabel: UILabel!
    @IBOutlet private weak var merchantHierarchyContentLabel: SelectableLabel!
    @IBOutlet private weak var transARNLabel: UILabel!
    @IBOutlet private weak var transARNContentLabel: SelectableLabel!
    @IBOutlet private weak var transRefNumberLabel: UILabel!
    @IBOutlet private weak var transRefNumberContentLabel: SelectableLabel!
    @IBOutlet private weak var transAuthCodeLabel: UILabel!
    @IBOutlet private weak var transAuthCodeContentLabel: SelectableLabel!
    @IBOutlet private weak var transCardTypeLabel: UILabel!
    @IBOutlet private weak var transCardTypeContentLabel: SelectableLabel!
    @IBOutlet private weak var transMaskedNumberLabel: UILabel!
    @IBOutlet private weak var transMaskedNumberContentLabel: SelectableLabel!
    @IBOutlet private weak var reasonLabel: UILabel!
    @IBOutlet private weak var reasonContentLabel: SelectableLabel!
    @IBOutlet private weak var reasonCodeLabel: UILabel!
    @IBOutlet private weak var reasonCodeContentLabel: SelectableLabel!
    @IBOutlet private weak var respondByDateLabel: UILabel!
    @IBOutlet private weak var respondByDateContentLabel: SelectableLabel!
    @IBOutlet private weak var documentsLabel: UILabel!
    @IBOutlet private weak var documentsMoreButton: UIButton!
    @IBOutlet private weak var lastAdjFundingLabel: UILabel!
    @IBOutlet private weak var lastAdjFundingContentLabel: SelectableLabel!
    @IBOutlet private weak var lastAdjAmountLabel: UILabel!
    @IBOutlet private weak var lastAdjAmountContentLabel: SelectableLabel!
    @IBOutlet private weak var lastAdjCurrencyLabel: UILabel!
    @IBOutlet private weak var lastAdjCurrencyContentLabel: SelectableLabel!
    @IBOutlet private weak var lastAdjTimeLabel: UILabel!
    @IBOutlet private weak var lastAdjTimeContentLabel: SelectableLabel!
    @IBOutlet private weak var lastAdjResultLabel: UILabel!
    @IBOutlet private weak var lastAdjResultContentLabel: SelectableLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        idLabel.text = "disputes.report.document.id".localized()
        timeCreatedLabel.text = "disputes.report.document.time.created".localized()
        statusLabel.text = "disputes.report.document.status".localized()
        stageLabel.text = "disputes.report.document.stage".localized()
        amountLabel.text = "disputes.report.document.amount".localized()
        currencyLabel.text = "disputes.report.document.currency".localized()
        midLabel.text = "disputes.report.document.mid".localized()
        merchantHierarchyLabel.text = "disputes.report.document.merchant.hierarchy".localized()
        transARNLabel.text = "disputes.report.document.arn".localized()
        transRefNumberLabel.text = "disputes.report.document.reference.number".localized()
        transAuthCodeLabel.text = "disputes.report.document.auth.code".localized()
        transCardTypeLabel.text = "disputes.report.document.card.type".localized()
        transMaskedNumberLabel.text = "disputes.report.document.masked.number".localized()
        reasonLabel.text = "disputes.report.document.reason".localized()
        reasonCodeLabel.text = "disputes.report.document.reason.code".localized()
        respondByDateLabel.text = "disputes.report.document.time.end".localized()
        documentsLabel.text = "disputes.report.document.documents".localized()
        documentsMoreButton.setTitle("disputes.report.document.more".localized(), for: .normal)
        documentsMoreButton.isEnabled = false
        lastAdjFundingLabel.text = "disputes.report.document.last.adjustment.funding".localized()
        lastAdjAmountLabel.text = "disputes.report.document.last.adjustment.amount".localized()
        lastAdjCurrencyLabel.text = "disputes.report.document.last.adjustment.currency".localized()
        lastAdjTimeLabel.text = "disputes.report.document.last.adjustment.time".localized()
        lastAdjResultLabel.text = "disputes.report.document.result".localized()
    }

    func setup(viewModel: DisputeSummary) {
        idContentLabel.text = viewModel.caseId
        timeCreatedContentLabel.text = viewModel.caseIdTime?.format()
        statusContentLabel.text = viewModel.caseStatus
        stageContentLabel.text = viewModel.caseStage?.mapped(for: .gpApi)
        amountContentLabel.text = viewModel.caseAmount?.description
        currencyContentLabel.text = viewModel.caseCurrency
        midContentLabel.text = viewModel.caseMerchantId
        merchantHierarchyContentLabel.text = viewModel.merchantHierarchy
        transARNContentLabel.text = viewModel.transactionARN
        transRefNumberContentLabel.text = viewModel.transactionReferenceNumber
        transAuthCodeContentLabel.text = viewModel.transactionAuthCode
        transCardTypeContentLabel.text = viewModel.transactionCardType
        transMaskedNumberContentLabel.text = viewModel.transactionMaskedCardNumber
        reasonContentLabel.text = viewModel.reason
        reasonCodeContentLabel.text = viewModel.reasonCode
        respondByDateContentLabel.text = viewModel.respondByDate?.format()
        lastAdjFundingContentLabel.text = viewModel.lastAdjustmentFunding?.mapped(for: .gpApi)
        lastAdjAmountContentLabel.text = viewModel.lastAdjustmentAmount?.description
        lastAdjCurrencyContentLabel.text = viewModel.lastAdjustmentCurrency
        lastAdjTimeContentLabel.text = viewModel.lastAdjustmentTimeCreated?.format()
        lastAdjResultContentLabel.text = viewModel.result

        if let documents = viewModel.documents, !documents.isEmpty {
            self.documents = documents
            documentsMoreButton.isEnabled = true
        }
    }

    @IBAction private func onSelectDocumentsAction() {
        onSelectDocuments?(documents)
    }
}
