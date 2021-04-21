import UIKit
import GlobalPayments_iOS_SDK

final class PaymentMethodView: UIView {

    @IBOutlet private weak var paymentMethodIdLabel: UILabel!
    @IBOutlet private weak var paymentMethodIdContentLabel: SelectableLabel!
    @IBOutlet private weak var timeCreatedLabel: UILabel!
    @IBOutlet private weak var timeCreatedContentLabel: SelectableLabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusContentLabel: SelectableLabel!
    @IBOutlet private weak var referenceLabel: UILabel!
    @IBOutlet private weak var referenceContentLabel: SelectableLabel!
    @IBOutlet private weak var resultCodeLabel: UILabel!
    @IBOutlet private weak var resultCodeContentLabel: SelectableLabel!
    @IBOutlet private weak var cardTypeLabel: UILabel!
    @IBOutlet private weak var cardTypeContentLabel: SelectableLabel!
    @IBOutlet private weak var cardExpiryMonthLabel: UILabel!
    @IBOutlet private weak var cardExpiryMonthContentLabel: SelectableLabel!
    @IBOutlet private weak var cardExpiryYearLabel: UILabel!
    @IBOutlet private weak var cardExpiryYearContentLabel: SelectableLabel!

    class func instantiateFromNib() -> PaymentMethodView {
        let nib = UINib(nibName: "PaymentMethodView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! PaymentMethodView
        nib.setupUI()

        return nib
    }

    private func setupUI() {
        paymentMethodIdLabel?.text = "payment.method.view.method.id".localized()
        timeCreatedLabel?.text = "payment.method.view.time.created".localized()
        statusLabel?.text = "payment.method.view.status".localized()
        referenceLabel?.text = "payment.method.view.reference".localized()
        resultCodeLabel?.text = "payment.method.view.result.code".localized()
        cardTypeLabel?.text = "payment.method.view.card.type".localized()
        cardExpiryMonthLabel?.text = "payment.method.view.card.expiry.month".localized()
        cardExpiryYearLabel?.text = "payment.method.view.card.expiry.year".localized()
    }

    func display(_ transaction: Transaction) {
        paymentMethodIdContentLabel.text = transaction.transactionId
        timeCreatedContentLabel.text = transaction.timestamp
        statusContentLabel.text = transaction.responseMessage
        referenceContentLabel.text = transaction.referenceNumber
        resultCodeContentLabel.text = transaction.responseCode
        cardTypeContentLabel.text = transaction.cardType
        if let cardExpMonth = transaction.cardExpMonth {
            cardExpiryMonthContentLabel.text = "\(cardExpMonth)"
        }
        if let cardExpYear = transaction.cardExpYear {
            cardExpiryYearContentLabel.text = "\(cardExpYear)"
        }
    }
}
