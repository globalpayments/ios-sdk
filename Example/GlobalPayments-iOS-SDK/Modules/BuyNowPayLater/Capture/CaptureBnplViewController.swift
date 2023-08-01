import UIKit
import GlobalPayments_iOS_SDK

final class CaptureBnplViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "CaptureBnpl"
    
    @IBOutlet weak var transactionIdTextField: UITextField!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
    
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: CaptureBnplViewInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        title = "buyNowPayLater.title".localized()
        captureButton.apply(style: .globalPayStyle, title: "buyNowPayLater.capture.title.button".localized())
        reverseButton.apply(style: .globalPayStyle, title: "buyNowPayLater.reverse.title.button".localized())
        activityIndicator.stopAnimating()
        viewModel.validateTransactionId()
    }
    
    @IBAction func onCaptureAction(_ sender: Any) {
        activityIndicator.startAnimating()
        viewModel.onCaptureTransaction()
    }
    
    @IBAction func onReverseAction(_ sender: Any) {
        activityIndicator.startAnimating()
        viewModel.onReverseTransaction()
    }
}

extension CaptureBnplViewController: CaptureBnplViewOutput {
    
    func setTransactionId(_ value: String) {
        transactionIdTextField.text = value
    }
    
    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }
    
    func showTransaction(_ transaction: Transaction) {
        activityIndicator.stopAnimating()
        let transactionView = TransactionView.instantiateFromNib()
        transactionView.display(transaction)
        supportView.addSubview(transactionView)
        transactionView.bindFrameToSuperviewBounds()
    }
}
