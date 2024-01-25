import UIKit

protocol SegmentedControlProtocol: AnyObject {
    func onFirstTab()
    func onSecondTab()
}

class SegmentedControlView: View {
    
    private struct DimensKeys {
        static let margin: CGFloat = 10
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
    }
    
    private var currentTabSelected: UILabel?
    weak var delegate: SegmentedControlProtocol?
    
    var firstTabTitle: String? {
        didSet {
            firstTabLabel.text = firstTabTitle
        }
    }
    
    var secondTabTitle: String? {
        didSet {
            secondTabLabel.text = secondTabTitle
        }
    }
    
    private lazy var containerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        return container
    }()
    
    private lazy var firstTabLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Response"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        label.setOnClickListener(action: onFirstTabClicked)
        selectedTab(tab: label)
        return label
    }()
    
    private func onFirstTabClicked() {
        self.selectedTab(tab: firstTabLabel)
        self.delegate?.onFirstTab()
    }
    
    private lazy var secondTabLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Code Example"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.setOnClickListener {
            self.selectedTab(tab: label)
            self.delegate?.onSecondTab()
        }
        return label
    }()
    
    private lazy var centerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init() {
        super.init()
        setUpContainerViewConstraints()
        setUpCenterViewConstraints()
        setUpCodeExampleLabelConstraints()
        setUpResponseLabelConstraints()
    }
    
    private func setUpContainerViewConstraints() {
        addSubview(containerView)
        containerView.cornersBorder()
        NSLayoutConstraint.activating([
            containerView.relativeTo(self, positioned: .allAnchors() + .constantHeight(55))
        ])
    }
    
    private func setUpCenterViewConstraints() {
        containerView.addSubview(centerView)
        NSLayoutConstraint.activating([
            centerView.relativeTo(containerView, positioned: .centerX() + .centerY() + .constantHeight(1) + .constantWidth(1))
        ])
    }
    
    private func setUpCodeExampleLabelConstraints() {
        containerView.addSubview(firstTabLabel)
        NSLayoutConstraint.activating([
            firstTabLabel.relativeTo(containerView, positioned: .left(margin: DimensKeys.marginSmall) + .top(margin: DimensKeys.marginSmall) + .bottom(margin: DimensKeys.marginSmall)),
            firstTabLabel.relativeTo(centerView, positioned: .toLeft() + .constantHeight(30))
        ])
    }
    
    private func setUpResponseLabelConstraints() {
        containerView.addSubview(secondTabLabel)
        NSLayoutConstraint.activating([
            secondTabLabel.relativeTo(containerView, positioned: .right(margin: DimensKeys.marginSmall) + .top(margin: DimensKeys.marginSmall) + .bottom(margin: DimensKeys.marginSmall)),
            secondTabLabel.relativeTo(centerView, positioned: .toRight(spacing: DimensKeys.marginSmall))
        ])
    }
    
    private func selectedTab(tab: UILabel?) {
        unSelectedTab(tab: currentTabSelected)
        guard let tab = tab else { return }
        tab.backgroundColor = .white
        tab.font = .boldSystemFont(ofSize: 16)
        let borderColor = #colorLiteral(red: 0, green: 0.4549019608, blue: 0.7803921569, alpha: 1)
        tab.cornersBorder(borderColor: borderColor)
        currentTabSelected = tab
    }
    
    private func unSelectedTab(tab: UILabel?) {
        guard let tab = tab else { return }
        tab.font = .systemFont(ofSize: 16)
        tab.textColor = .black
        let borderColor = UIColor.clear
        tab.cornersBorder(borderColor: borderColor)
    }
    
    func selectResponseTab() {
        onFirstTabClicked()
    }
}
