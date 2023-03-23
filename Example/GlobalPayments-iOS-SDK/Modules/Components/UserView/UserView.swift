import UIKit
import GlobalPayments_iOS_SDK

final class UserView: UIView {

    @IBOutlet private weak var userIdLabel: UILabel!
    @IBOutlet private weak var userIdContentLabel: SelectableLabel!
    @IBOutlet private weak var timeCreatedLabel: UILabel!
    @IBOutlet private weak var timeCreatedContentLabel: SelectableLabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusContentLabel: SelectableLabel!
    @IBOutlet private weak var resultCodeLabel: UILabel!
    @IBOutlet private weak var resultCodeContentLabel: SelectableLabel!

    class func instantiateFromNib() -> UserView {
        let nib = UINib(nibName: "UserView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! UserView
        nib.setupUI()

        return nib
    }

    private func setupUI() {
        userIdLabel?.text = "transaction.view.transaction.id".localized()
        timeCreatedLabel?.text = "transaction.view.time.created".localized()
        statusLabel?.text = "transaction.view.status".localized()
        resultCodeLabel?.text = "transaction.view.result.code".localized()
    }
    
    func display(_ user: User) {
        userIdContentLabel.text = user.userReference?.userId
        timeCreatedContentLabel.text = user.timeCreated
        statusContentLabel.text = user.userReference?.userStatus?.mapped(for: .gpApi)
        resultCodeContentLabel.text = user.responseCode
    }
}
