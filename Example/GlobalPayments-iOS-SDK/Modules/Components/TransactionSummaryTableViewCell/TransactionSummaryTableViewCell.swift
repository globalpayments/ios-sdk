import UIKit
import GlobalPayments_iOS_SDK

final class TransactionSummaryTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet private weak var idTitleLabel: UILabel!
    @IBOutlet private weak var idContentLabel: UILabel!
    @IBOutlet private weak var timeTitleLabel: UILabel!
    @IBOutlet private weak var timeContentLabel: UILabel!
    @IBOutlet private weak var statusTitleLabel: UILabel!
    @IBOutlet private weak var statusContentLabel: UILabel!
    @IBOutlet private weak var typeTitleLabel: UILabel!
    @IBOutlet private weak var typeContentLabel: UILabel!
    @IBOutlet private weak var channelTitleLabel: UILabel!
    @IBOutlet private weak var channelContentLabel: UILabel!
    @IBOutlet private weak var amountTitleLabel: UILabel!
    @IBOutlet private weak var amountContentLabel: UILabel!
    @IBOutlet private weak var currencyTitleLabel: UILabel!
    @IBOutlet private weak var currencyContentLabel: UILabel!
    @IBOutlet private weak var referenceTitleLabel: UILabel!
    @IBOutlet private weak var referenceContentLabel: UILabel!
    @IBOutlet private weak var clientTransIdTitleLabel: UILabel!
    @IBOutlet private weak var clientTransIdContentLabel: UILabel!
    @IBOutlet private weak var batchIdTitleLabel: UILabel!
    @IBOutlet private weak var batchIdContentLabel: UILabel!
    @IBOutlet private weak var countryTitleLabel: UILabel!
    @IBOutlet private weak var countryContentLabel: UILabel!
    @IBOutlet private weak var origTransIdTitleLabel: UILabel!
    @IBOutlet private weak var origTransIdContentLabel: UILabel!
    @IBOutlet private weak var gatewayResponseMsgTitleLabel: UILabel!
    @IBOutlet private weak var gatewayResponseMsgContentLabel: UILabel!
    @IBOutlet private weak var entryModeTitleLabel: UILabel!
    @IBOutlet private weak var entryModeContentLabel: UILabel!
    @IBOutlet private weak var cardTypeTitleLabel: UILabel!
    @IBOutlet private weak var cardTypeContentLabel: UILabel!
    @IBOutlet private weak var authCodeTitleLabel: UILabel!
    @IBOutlet private weak var authCodeContentLabel: UILabel!
    @IBOutlet private weak var arnTitleLabel: UILabel!
    @IBOutlet private weak var arnContentLabel: UILabel!
    @IBOutlet private weak var maskedCardNumberTitleLabel: UILabel!
    @IBOutlet private weak var maskedCardNumberContentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        idTitleLabel.text = "transaction.report.by.id.id".localized()
        timeTitleLabel.text = "transaction.report.by.id.time".localized()
        statusTitleLabel.text = "transaction.report.by.id.status".localized()
        typeTitleLabel.text = "transaction.report.by.id.type".localized()
        channelTitleLabel.text = "transaction.report.by.id.channel".localized()
        amountTitleLabel.text = "transaction.report.by.id.amount".localized()
        currencyTitleLabel.text = "transaction.report.by.id.currency".localized()
        referenceTitleLabel.text = "transaction.report.by.id.reference".localized()
        clientTransIdTitleLabel.text = "transaction.report.by.id.client.trans.id".localized()
        batchIdTitleLabel.text = "transaction.report.by.id.batch.id".localized()
        countryTitleLabel.text = "transaction.report.by.id.country".localized()
        origTransIdTitleLabel.text = "transaction.report.by.id.org.trans.id".localized()
        gatewayResponseMsgTitleLabel.text = "transaction.report.by.id.gateway.msg".localized()
        entryModeTitleLabel.text = "transaction.report.by.id.entry.mode".localized()
        cardTypeTitleLabel.text = "transaction.report.by.id.card.type".localized()
        authCodeTitleLabel.text = "transaction.report.by.id.auth.code".localized()
        arnTitleLabel.text = "transaction.report.by.id.arn".localized()
        maskedCardNumberTitleLabel.text = "transaction.report.by.id.masked.number".localized()
    }

    func setup(viewModel: TransactionSummary) {
        idContentLabel.text = viewModel.transactionId
        timeContentLabel.text = viewModel.transactionDate?.format()
        statusContentLabel.text = viewModel.transactionStatus?.rawValue
        typeContentLabel.text = viewModel.transactionType
        channelContentLabel.text = viewModel.channel
        amountContentLabel.text = viewModel.amount?.description
        currencyContentLabel.text = viewModel.currency
        referenceContentLabel.text = viewModel.referenceNumber
        clientTransIdContentLabel.text = viewModel.clientTransactionId
        batchIdContentLabel.text = viewModel.batchSequenceNumber
        countryContentLabel.text = viewModel.country
        origTransIdContentLabel.text = viewModel.originalTransactionId
        gatewayResponseMsgContentLabel.text = viewModel.gatewayResponseMessage
        entryModeContentLabel.text = viewModel.entryMode
        cardTypeContentLabel.text = viewModel.cardType
        authCodeContentLabel.text = viewModel.authCode
        arnContentLabel.text = viewModel.aquirerReferenceNumber
        maskedCardNumberContentLabel.text = viewModel.maskedCardNumber
    }
}
