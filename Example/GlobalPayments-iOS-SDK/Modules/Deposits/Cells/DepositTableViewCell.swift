import UIKit
import GlobalPayments_iOS_SDK

final class DepositTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var idContentLabel: SelectableLabel!
    @IBOutlet private weak var timeCreatedLabel: UILabel!
    @IBOutlet private weak var timeCreatedContentLabel: SelectableLabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusContentLabel: SelectableLabel!
    @IBOutlet private weak var fundingTypeLabel: UILabel!
    @IBOutlet private weak var fundingTypeContentLabel: SelectableLabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountContentLabel: SelectableLabel!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var currencyContentLabel: SelectableLabel!
    @IBOutlet private weak var midLabel: UILabel!
    @IBOutlet private weak var midContentLabel: SelectableLabel!
    @IBOutlet private weak var hierarchyLabel: UILabel!
    @IBOutlet private weak var hierarchyContentLabel: SelectableLabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nameContentLabel: SelectableLabel!
    @IBOutlet private weak var dbaLabel: UILabel!
    @IBOutlet private weak var dbaContentLabel: SelectableLabel!
    @IBOutlet private weak var salesCountLabel: UILabel!
    @IBOutlet private weak var salesCountContentLabel: SelectableLabel!
    @IBOutlet private weak var salesAmountLabel: UILabel!
    @IBOutlet private weak var salesAmountContentLabel: SelectableLabel!
    @IBOutlet private weak var refundsCountLabel: UILabel!
    @IBOutlet private weak var refundsCountContentLabel: SelectableLabel!
    @IBOutlet private weak var refundsAmountLabel: UILabel!
    @IBOutlet private weak var refundsAmountContentLabel: SelectableLabel!
    @IBOutlet private weak var discountsCountLabel: UILabel!
    @IBOutlet private weak var discountsCountContentLabel: SelectableLabel!
    @IBOutlet private weak var discountsAmountLabel: UILabel!
    @IBOutlet private weak var discountsAmountContentLabel: SelectableLabel!
    @IBOutlet private weak var taxAmountLabel: UILabel!
    @IBOutlet private weak var taxAmountContentLabel: SelectableLabel!
    @IBOutlet private weak var taxCountLabel: UILabel!
    @IBOutlet private weak var taxCountContentLabel: SelectableLabel!
    @IBOutlet private weak var chargebacksAmountLabel: UILabel!
    @IBOutlet private weak var chargebacksAmountContentLabel: SelectableLabel!
    @IBOutlet private weak var chargebacksCountLabel: UILabel!
    @IBOutlet private weak var chargebacksCountContentLabel: SelectableLabel!
    @IBOutlet private weak var reversalsAmountLabel: UILabel!
    @IBOutlet private weak var reversalsAmountContentLabel: SelectableLabel!
    @IBOutlet private weak var reversalsCountLabel: UILabel!
    @IBOutlet private weak var reversalsCountContentLabel: SelectableLabel!
    @IBOutlet private weak var feesLabel: UILabel!
    @IBOutlet private weak var feesContentLabel: SelectableLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        idLabel?.text = "deposits.id".localized()
        timeCreatedLabel?.text = "deposits.time.created".localized()
        statusLabel?.text = "deposits.status".localized()
        fundingTypeLabel?.text = "deposits.funding.type".localized()
        amountLabel?.text = "deposits.amount".localized()
        currencyLabel?.text = "deposits.currency".localized()
        midLabel?.text = "deposits.mid".localized()
        hierarchyLabel?.text = "deposits.hierarchy".localized()
        nameLabel?.text = "deposits.name".localized()
        dbaLabel?.text = "deposits.dbo".localized()
        salesCountLabel?.text = "deposits.sales.count".localized()
        salesAmountLabel?.text = "deposits.sales.amount".localized()
        refundsCountLabel?.text = "deposits.refunds.count".localized()
        refundsAmountLabel?.text = "deposits.refunds.amount".localized()
        discountsAmountLabel?.text = "deposits.discounts.amount".localized()
        discountsCountLabel?.text = "deposits.discounts.count".localized()
        taxAmountLabel?.text = "deposits.tax.amount".localized()
        taxCountLabel?.text = "deposits.tax.count".localized()
        chargebacksAmountLabel?.text = "deposits.chargebacks.amount".localized()
        chargebacksCountLabel?.text = "deposits.chargebacks.count".localized()
        reversalsAmountLabel?.text = "deposits.reversals.amount".localized()
        reversalsCountLabel?.text = "deposits.reversals.count".localized()
        feesLabel?.text = "deposits.fees.amount".localized()
    }

    func setup(viewModel: DepositSummary) {
        idContentLabel?.text = viewModel.depositId
        timeCreatedContentLabel?.text = viewModel.depositDate?.format("yyyy-MM-dd")
        statusContentLabel?.text = viewModel.status
        fundingTypeContentLabel?.text = viewModel.type
        amountContentLabel?.text = viewModel.amount?.description
        currencyContentLabel?.text = viewModel.currency
        midContentLabel?.text = viewModel.merchantNumber
        hierarchyContentLabel?.text = viewModel.merchantHierarchy
        nameContentLabel?.text = viewModel.merchantName
        dbaContentLabel?.text = viewModel.merchantDbaName

        salesCountContentLabel?.text = String(viewModel.salesTotalCount ?? .zero)
        salesAmountContentLabel?.text = viewModel.salesTotalAmount?.description

        refundsCountContentLabel?.text = String(viewModel.refundsTotalCount ?? .zero)
        refundsAmountContentLabel?.text = viewModel.refundsTotalAmount?.description

        discountsAmountContentLabel?.text = String(viewModel.discountsTotalCount ?? .zero)
        discountsCountContentLabel?.text = viewModel.discountsTotalCount?.description

        taxAmountContentLabel?.text = viewModel.taxTotalAmount?.description
        taxCountContentLabel?.text = String(viewModel.taxTotalCount ?? .zero)

        chargebacksAmountContentLabel?.text = viewModel.chargebackTotalAmount?.description
        chargebacksCountContentLabel?.text = String(viewModel.chargebackTotalCount ?? .zero)

        reversalsAmountContentLabel?.text = viewModel.adjustmentTotalAmount?.description
        reversalsCountContentLabel?.text = String(viewModel.adjustmentTotalCount ?? .zero)

        feesContentLabel?.text = viewModel.feesTotalAmount?.description
    }
}
