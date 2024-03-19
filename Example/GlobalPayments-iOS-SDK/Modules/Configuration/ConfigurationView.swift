import UIKit
import GlobalPayments_iOS_SDK

protocol ConfigurationViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func saveConfigurationPressed()
    func backButtonPressed()
}

final class ConfigurationView: View {
    
    weak var delegate: ConfigurationViewDelegate?
    
    private struct DimensKeys {
        static let margin: CGFloat = 10
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
        static let disabledButton: CGFloat = 0.3
        static let enabledButton: CGFloat = 1.0
    }
    
    private lazy var backImageView: UIImageView = {
        let image = UIImageView()
        let imageSource = #imageLiteral(resourceName: "ic_next_screen")
        image.contentMode = .scaleAspectFit
        image.image = imageSource.rotate(radians: .pi)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var logoGp: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "gp_logo")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "configuration.title".localized().uppercased()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = #colorLiteral(red: 0, green: 0.3087183237, blue: 0.5186551213, alpha: 1)
        return label
    }()
    
    internal lazy var separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.872883141, green: 0.8896381259, blue: 0.905549109, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollContainerView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var appIdFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "access.token.form.app.id".localized()
        field.tagField = .appId
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var appKeyFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "access.token.form.app.key".localized()
        field.tagField = .appKey
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var secondsToExpireFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "access.token.form.seconds".localized()
        field.inputMode = .numberPad
        field.tagField = .secondsToExpire
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var intervalChannelsFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "access.token.form.interval".localized()
        fields.secondTitle = "transaction.report.by.id.channel".localized()
        
        fields.setFirstTagField(.interval, delegate: self)
        fields.setSecondTagField(.channel, delegate: self)
        

        let intervals = IntervalToExpire.allCases.map { $0.rawValue.uppercased() }
        let channels =  Channel.allCases.map { $0.rawValue.uppercased() }
        
        fields.setDropDownBoth(intervals, secondData: channels)
        return fields
    }()
    
    private lazy var languageCountryFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "configuration.language".localized()
        fields.secondTitle = "configuration.country".localized()
        
        fields.setFirstTagField(.language, delegate: self)
        fields.setSecondTagField(.country, delegate: self)
        

        let languages = Language.allCases.map { $0.rawValue.uppercased() }
        let countries =  CountryUtils.ISOCountryInfo.allCountries.map { $0.alpha2.uppercased() }
        
        fields.setDropDownBoth(languages, secondData: countries)
        return fields
    }()
    
    private lazy var merchantIdFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "deposits.mid".localized()
        field.tagField = .merchantId
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var transactionProccesingFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "configuration.transaction.proccesing".localized()
        field.tagField = .transactionProccesing
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var tokenizationFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "configuration.tokenization".localized()
        field.tagField = .tokenization
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var challengeNotificationUrlFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "configuration.challenge.notification.url".localized()
        field.tagField = .challengeNotification
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var methodNotificationUrlFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "configuration.method.notification.url".localized()
        field.tagField = .methodNotification
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var merchantContactUrlFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "configuration.merchant.contact.url".localized()
        field.tagField = .merchantContactUrl
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var statusUrlFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "configuration.merchant.status.url".localized()
        field.tagField = .statusUrl
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var saveConfigurationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "configuration.save".localized().uppercased())
        button.addTarget(self, action: #selector(saveConfigurationPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        setUpLogoGpConstraints()
        setUpBackImageViewConstraints()
        setUpTitleLabelConstraints()
        setUpSeparatorLineConstraints()
        setUpScrollContainerViewConstraints()
        setUpAppIdFieldConstraints()
        setUpAppKeyFieldConstraints()
        setUpSecondsToExpireFieldConstraints()
        setUpIntervalChannelsFieldsConstraints()
        setUpLanguageCountryFieldsConstraints()
        setUpMerchantConfigFieldsConstraints()
        setUpThreeSecureFieldsConstraints()
        setUpSaveConfigurationButtonConstraints()
    }
    
    private func setUpLogoGpConstraints() {
        addSubview(logoGp)
        NSLayoutConstraint.activating([
            logoGp.relativeTo(self, positioned: .safeTop(margin: DimensKeys.marginBig) + . centerX() + .constantHeight(20) + .constantWidth(130))
        ])
    }
    
    private func setUpBackImageViewConstraints() {
        addSubview(backImageView)
        backImageView.setOnClickListener { [weak self] in
            self?.delegate?.backButtonPressed()
        }
        NSLayoutConstraint.activating([
            backImageView.relativeTo(self, positioned: .left(margin: DimensKeys.marginBig)),
            backImageView.relativeTo(logoGp, positioned: .centerY() + .constantHeight(20) + .constantWidth(10))
        ])
    }
    
    private func setUpTitleLabelConstraints() {
        addSubview(titleLabel)
        NSLayoutConstraint.activating([
            titleLabel.relativeTo(logoGp, positioned: .below(spacing: DimensKeys.marginBig) + .centerX())
        ])
    }
    
    private func setUpSeparatorLineConstraints() {
        addSubview(separatorLineView)
        NSLayoutConstraint.activating([
            separatorLineView.relativeTo(titleLabel, positioned: .below(spacing: DimensKeys.marginBig) + .constantHeight(1)),
            separatorLineView.relativeTo(self, positioned: .width(DimensKeys.marginBig))
        ])
    }
    
    private func setUpScrollContainerViewConstraints() {
        addSubview(scrollContainerView)
        scrollContainerView.addSubview(containerView)
        NSLayoutConstraint.activating([
            scrollContainerView.relativeTo(separatorLineView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            containerView.relativeTo(scrollContainerView, positioned: .width() + .top() + .centerX() + .bottom())
        ])
    }
    
    private func setUpAppIdFieldConstraints() {
        containerView.addSubview(appIdFieldView)
        NSLayoutConstraint.activating([
            appIdFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpAppKeyFieldConstraints() {
        containerView.addSubview(appKeyFieldView)
        NSLayoutConstraint.activating([
            appKeyFieldView.relativeTo(appIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpSecondsToExpireFieldConstraints() {
        containerView.addSubview(secondsToExpireFieldView)
        NSLayoutConstraint.activating([
            secondsToExpireFieldView.relativeTo(appKeyFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpIntervalChannelsFieldsConstraints() {
        containerView.addSubview(intervalChannelsFieldsView)
        NSLayoutConstraint.activating([
            intervalChannelsFieldsView.relativeTo(secondsToExpireFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpLanguageCountryFieldsConstraints() {
        containerView.addSubview(languageCountryFieldsView)
        NSLayoutConstraint.activating([
            languageCountryFieldsView.relativeTo(intervalChannelsFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpMerchantConfigFieldsConstraints() {
        containerView.addSubview(merchantIdFieldView)
        containerView.addSubview(transactionProccesingFieldView)
        containerView.addSubview(tokenizationFieldView)
        
        NSLayoutConstraint.activating([
            merchantIdFieldView.relativeTo(languageCountryFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            transactionProccesingFieldView.relativeTo(merchantIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            tokenizationFieldView.relativeTo(transactionProccesingFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpThreeSecureFieldsConstraints() {
        containerView.addSubview(challengeNotificationUrlFieldView)
        containerView.addSubview(methodNotificationUrlFieldView)
        containerView.addSubview(merchantContactUrlFieldView)
        containerView.addSubview(statusUrlFieldView)
        
        NSLayoutConstraint.activating([
            challengeNotificationUrlFieldView.relativeTo(tokenizationFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            methodNotificationUrlFieldView.relativeTo(challengeNotificationUrlFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            merchantContactUrlFieldView.relativeTo(methodNotificationUrlFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            merchantContactUrlFieldView.relativeTo(methodNotificationUrlFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            statusUrlFieldView.relativeTo(merchantContactUrlFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            statusUrlFieldView.relativeTo(containerView, positioned: .bottom(margin: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpSaveConfigurationButtonConstraints() {
        addSubview(saveConfigurationButton)
        NSLayoutConstraint.activating([
            saveConfigurationButton.relativeTo(self, positioned: .width(DimensKeys.marginBig)),
            saveConfigurationButton.constrainedBy(.constantHeight(48)),
            saveConfigurationButton.relativeTo(self, positioned: .safeBottom(margin: DimensKeys.marginBig)),
            saveConfigurationButton.relativeTo(scrollContainerView, positioned: .below(spacing: DimensKeys.marginBig))
        ])
    }
    
    @objc func saveConfigurationPressed() {
        delegate?.saveConfigurationPressed()
    }
    
    func setDefaultData(_ config: Config?) {
        guard let config = config else { return }
        appIdFieldView.text = config.appId
        appKeyFieldView.text = config.appKey
        
        secondsToExpireFieldView.text = "\(config.secondsToExpire ?? 6000)"
        
        intervalChannelsFieldsView.firstText = config.intervalToExpire?.rawValue
        intervalChannelsFieldsView.secondText = config.channel.rawValue
        
        languageCountryFieldsView.firstText = config.language?.rawValue
        languageCountryFieldsView.secondText = config.country
        
        merchantIdFieldView.text = config.merchantId
        transactionProccesingFieldView.text = config.transactionProcessing
        tokenizationFieldView.text = config.tokenization
        challengeNotificationUrlFieldView.text = config.challengeNotificationUrl
        methodNotificationUrlFieldView.text = config.methodNotificationUrl
        merchantContactUrlFieldView.text = config.merchantContactUrl
        statusUrlFieldView.text = config.statusUrl
    }
}

extension ConfigurationView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
