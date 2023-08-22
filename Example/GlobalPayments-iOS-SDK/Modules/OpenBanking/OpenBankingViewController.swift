import UIKit
import GlobalPayments_iOS_SDK

final class OpenBankingViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "OpenBanking"
    
    @IBOutlet weak var sepaButton: UIButton!
    @IBOutlet weak var fasterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        title = "openBanking.title".localized()
        sepaButton.backgroundColor = .appTintColor
        fasterButton.backgroundColor = .appTintColor
        sepaButton.titleLabel?.textColor = .white
        fasterButton.titleLabel?.textColor = .white
        if #available(iOS 15.0, *) {
            sepaButton.subtitleLabel?.textColor = .white
            fasterButton.subtitleLabel?.textColor = .white
        }
    }
}
