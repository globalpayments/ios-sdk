import UIKit

protocol BaseViewDelegate: AnyObject {
    func backViewAction()
    func settingsAction()
}

class GpBaseView: View {
    
    private struct DimensKeys {
        static let logoMargin: CGFloat = 20
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
    }
    
    public weak var delegateView: BaseViewDelegate?
    
    var title: String? {
        didSet{
            titleLabel.text = title
        }
    }
    
    var descriptionValue: String? {
        didSet{
            descriptionLabel.text = descriptionValue
        }
    }
    
    var descriptionTextAlignment: NSTextAlignment = .left {
        didSet{
            descriptionLabel.textAlignment = descriptionTextAlignment
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
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.3529411765, green: 0.368627451, blue: 0.4274509804, alpha: 1)
        return label
    }()
    
    internal lazy var separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.872883141, green: 0.8896381259, blue: 0.905549109, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        loadingView.stopAnimating()
        loadingView.backgroundColor = #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.2041597682)
        return loadingView
    }()
    
    internal lazy var separatorBottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.872883141, green: 0.8896381259, blue: 0.905549109, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    internal lazy var codeResponseView: CodeExampleResponseView = {
        let codeResponseView = CodeExampleResponseView()
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "unified_payments_code")
        codeResponseView.defaultTabClicked()
        codeResponseView.translatesAutoresizingMaskIntoConstraints = false
        return codeResponseView
    }()
    
    override init() {
        super.init()
        setUpLogoGpConstraints()
        setUpBackImageViewConstraints()
        setUpTitleLabelConstraints()
        setUpSettingsViewConstraints()
        setUpDescriptionLabelConstraints()
        setUpSeparatorLineConstraints()
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
    
    private func setUpDescriptionLabelConstraints() {
        addSubview(descriptionLabel)
        NSLayoutConstraint.activating([
            descriptionLabel.relativeTo(titleLabel, positioned: .below(spacing: DimensKeys.marginTop)),
            descriptionLabel.relativeTo(self, positioned: .left(margin: DimensKeys.marginSide) + .right(margin: DimensKeys.marginSide))
        ])
    }
    
    private func setUpSeparatorLineConstraints() {
        addSubview(separatorLineView)
        NSLayoutConstraint.activating([
            separatorLineView.relativeTo(descriptionLabel, positioned: .below(spacing: DimensKeys.marginBig) + .constantHeight(1) + .width())
        ])
    }
    
    public func setUpLoadingViewConstraints() {
        addSubview(loadingView)
        NSLayoutConstraint.activating([
            loadingView.relativeTo(self, positioned: .allAnchors())
        ])
    }
    
    internal func setUpSeparatorBottomLineConstraints(_ containerView: UIView, belowView: UIView) {
        containerView.addSubview(separatorBottomLineView)
        NSLayoutConstraint.activating([
            separatorBottomLineView.relativeTo(containerView, positioned: .width() + .constantHeight(1)),
            separatorBottomLineView.relativeTo(belowView, positioned: .below(spacing: DimensKeys.marginMedium))
        ])
    }
    
    internal func setUpCodeResponseViewConstraints(_ containerView: UIView) {
        containerView.addSubview(codeResponseView)
        NSLayoutConstraint.activating([
            codeResponseView.relativeTo(separatorBottomLineView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginSmall)),
            codeResponseView.relativeTo(containerView, positioned: .bottom())
        ])
    }
    
    func setResponseData(_ type: ResponseViewType, data: Any) {
        codeResponseView.defaultTabClicked()
        codeResponseView.setResponseData(type, data: data)
    }
    
    public func showLoading(_ show: Bool) {
        if show {
            loadingView.startAnimating()
        }else {
            loadingView.stopAnimating()
        }
    }
}
