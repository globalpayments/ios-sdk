import UIKit

class GpLabelSwitchView: View {
    
    private struct DimensKeys {
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
        static let switchSize: CGFloat = 30
    }
    
    var title: String? {
        didSet{
            switchLabel.text = title
        }
    }
    
    private lazy var switchContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        container.cornerRadius = 5.0
        return container
    }()
    
    private lazy var switchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonSwitch: UISwitch = {
        let switchButton = UISwitch()
                
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    override init() {
        super.init()
        setUpRecurringPaymentContainerContraints()
    }
    
    private func setUpRecurringPaymentContainerContraints() {
        addSubview(switchContainer)
        switchContainer.addSubview(switchLabel)
        switchContainer.addSubview(buttonSwitch)
        NSLayoutConstraint.activating([
            switchContainer.relativeTo(self, positioned: .allAnchors()),
            switchLabel.relativeTo(switchContainer, positioned: .top(margin: DimensKeys.marginBig) + .bottom(margin: DimensKeys.marginBig) + .left(margin: DimensKeys.marginMedium)),
            buttonSwitch.relativeTo(switchContainer, positioned: .right(margin: DimensKeys.marginMedium) + .centerY() + .constantHeight(DimensKeys.switchSize))
        ])
    }
    
    func addAction(_ target: AnyObject, selector: Selector) {
        buttonSwitch.addTarget(target, action: selector, for: .valueChanged)
    }
}

