import UIKit

enum PageIndex: Int {
    case first = 0
    case second = 1
}

protocol ReportingControlDelegate: AnyObject {
    func didPageChange(_ index: PageIndex)
}

class GpBaseReportingView: View {
    
    private struct DimensKeys {
        static let logoMargin: CGFloat = 20
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
        static let marginLargeBig: CGFloat = 30
    }
    
    public weak var delegateView: BaseViewDelegate?
    public weak var delegate: ReportingControlDelegate?
    
    var title: String? {
        didSet{
            titleLabel.text = title
        }
    }
    
    private lazy var baseLogoGp: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "gp_logo")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var backImageView: UIImageView = {
        let image = UIImageView()
        let imageSource = #imageLiteral(resourceName: "ic_next_screen")
        image.contentMode = .scaleAspectFit
        image.image = imageSource.rotate(radians: .pi)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    internal lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = #colorLiteral(red: 0, green: 0.3087183237, blue: 0.5186551213, alpha: 1)
        return label
    }()
    
    private lazy var settingsImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "ic_settings")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var segmentedControlView: SegmentedControlView = {
        let controlView = SegmentedControlView()
        controlView.firstTabTitle = "tab.single".localized()
        controlView.secondTabTitle = "tab.list".localized()
        controlView.delegate = self
        controlView.translatesAutoresizingMaskIntoConstraints = false
        return controlView
    }()
    
    private lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .appGreenColor
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    override init() {
        super.init()
        setUpLogoGpConstraints()
        setUpBackImageViewConstraints()
        setUpTitleLabelConstraints()
        setUpSettingsViewConstraints()
        setUpControlViewConstraints()
        setUpContainerPageViewConstraints()
    }
    
    private func setUpLogoGpConstraints() {
        addSubview(baseLogoGp)
        NSLayoutConstraint.activating([
            baseLogoGp.relativeTo(self, positioned: .safeTop(margin: DimensKeys.logoMargin) + . centerX() + .constantHeight(20) + .constantWidth(130))
        ])
    }
    
    private func setUpBackImageViewConstraints() {
        addSubview(backImageView)
        backImageView.setOnClickListener { [weak self] in
            self?.delegateView?.backViewAction()
        }
        NSLayoutConstraint.activating([
            backImageView.relativeTo(self, positioned: .left(margin: DimensKeys.marginSide)),
            backImageView.relativeTo(baseLogoGp, positioned: .centerY() + .constantHeight(20) + .constantWidth(10))
        ])
    }
    
    private func setUpTitleLabelConstraints() {
        addSubview(titleLabel)
        NSLayoutConstraint.activating([
            titleLabel.relativeTo(baseLogoGp, positioned: .below(spacing: DimensKeys.marginTop) + .centerX())
        ])
    }
    
    private func setUpSettingsViewConstraints() {
        addSubview(settingsImage)
        settingsImage.setOnClickListener { [weak self] in
            self?.delegateView?.settingsAction()
        }
        NSLayoutConstraint.activating([
            settingsImage.relativeTo(self, positioned: .right(margin: DimensKeys.marginSide) + .constantHeight(19) + .constantWidth(19)),
            settingsImage.relativeTo(baseLogoGp, positioned: .centerY())
        ])
    }
    
    private func setUpControlViewConstraints() {
        addSubview(segmentedControlView)
        NSLayoutConstraint.activating([
            segmentedControlView.relativeTo(titleLabel, positioned: .below(spacing: DimensKeys.marginLargeBig)),
            segmentedControlView.relativeTo(self, positioned: .width(DimensKeys.marginBig))
        ])
    }
    
    private func setUpContainerPageViewConstraints() {
        addSubview(containerView)
        NSLayoutConstraint.activating([
            containerView.relativeTo(segmentedControlView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            containerView.relativeTo(self, positioned: .safeBottom())
        ])
    }
    
    func setPageView(_ pageView: UIView) {
        containerView.addSubview(pageView)
        pageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activating([
            pageView.relativeTo(containerView, positioned: .allAnchors())
        ])
    }
    
    func setTabsName(first: String, second: String) {
        segmentedControlView.firstTabTitle = first.localized()
        segmentedControlView.secondTabTitle = second.localized()
    }
}

extension GpBaseReportingView: SegmentedControlProtocol {
    
    func onFirstTab() {
        delegate?.didPageChange(.first)
    }
    
    func onSecondTab() {
        delegate?.didPageChange(.second)
    }
}
