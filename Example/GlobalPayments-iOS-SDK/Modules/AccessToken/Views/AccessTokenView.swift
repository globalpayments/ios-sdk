import UIKit
import GlobalPayments_iOS_SDK

final class AccessTokenView: UIView {

    @IBOutlet private weak var tokenLabel: UILabel!
    @IBOutlet private weak var dataAccountNameLabel: UILabel!
    @IBOutlet private weak var disputeManagementAccountNameLabel: UILabel!
    @IBOutlet private weak var tokenizationAccountNameLabel: UILabel!
    @IBOutlet private weak var transactionProcessingAccountNameLabel: UILabel!

    class func instantiateFromNib() -> AccessTokenView {
        UINib(nibName: "AccessTokenView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! AccessTokenView
    }

    func setTokenInfo(_ tokenInfo: AccessTokenInfo) {
        tokenLabel.text = tokenInfo.token ?? "EMPTY"
        dataAccountNameLabel.text = tokenInfo.dataAccountName ?? "EMPTY"
        disputeManagementAccountNameLabel.text = tokenInfo.disputeManagementAccountName ?? "EMPTY"
        tokenizationAccountNameLabel.text = tokenInfo.tokenizationAccountName ?? "EMPTY"
        transactionProcessingAccountNameLabel.text = tokenInfo.transactionProcessingAccountName ?? "EMPTY"
    }
}
