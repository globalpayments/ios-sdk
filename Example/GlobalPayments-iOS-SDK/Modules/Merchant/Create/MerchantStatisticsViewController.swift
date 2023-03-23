import UIKit
import GlobalPayments_iOS_SDK

protocol MerchantStatisticsDelegate: AnyObject {
    func onSubmitStatistics(statistics: PaymentStatistics)
}

final class MerchantStatisticsController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Merchant"
    weak var delegate: MerchantStatisticsDelegate?
    
    
    @IBOutlet weak var textFieldMonthly: UITextField!
    
    @IBOutlet weak var textFieldAverageTicket: UITextField!
    @IBOutlet weak var textfieldHighestTicket: UITextField!
    @IBOutlet weak var buttonCreate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        buttonCreate.apply(style: .globalPayStyle, title: "merchant.create.payment.statistics.label".localized())
    }

    private func setupUI() {
        title = "merchant.create.payment.statistics.title".localized()
        hideKeyboardWhenTappedAround()
        addMockData()
    }
    
    private func addMockData() {
        textFieldMonthly.text = "3000000"
        textFieldAverageTicket.text = "50000"
        textfieldHighestTicket.text = "60000"
    }
    
    @IBAction func createPaymentAction(_ sender: Any) {
        let paymentStatistics = PaymentStatistics()
        paymentStatistics.totalMonthlySalesAmount = NSDecimalNumber(string: textFieldMonthly.text ?? "0")
        paymentStatistics.averageTicketSalesAmount = NSDecimalNumber(string: textFieldAverageTicket.text ?? "0")
        paymentStatistics.highestTicketSalesAmount = NSDecimalNumber(string: textfieldHighestTicket.text ?? "0")
        delegate?.onSubmitStatistics(statistics: paymentStatistics)
        dismiss(animated: true)
    }
}
