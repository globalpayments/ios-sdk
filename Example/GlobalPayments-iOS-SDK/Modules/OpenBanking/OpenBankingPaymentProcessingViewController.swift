import UIKit
import GlobalPayments_iOS_SDK

final class OpenBankingPaymentProcessingViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "OpenBankingPaymentProcessing"
    
    var transaction: Transaction?
    
    @IBOutlet weak var supportView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        title = "openBanking.fasterPayments.title.button".localized()
        showTransaction()
    }
    
    private func showTransaction() {
        guard let transaction = transaction else { return }
        let transactionView = TransactionView.instantiateFromNib()
        transactionView.display(transaction)
        supportView.addSubview(transactionView)
        transactionView.bindFrameToSuperviewBounds()
    }
}
