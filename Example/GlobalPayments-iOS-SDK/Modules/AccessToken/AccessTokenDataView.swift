import UIKit
import GlobalPayments_iOS_SDK

protocol AccessTokenDataDelegate: AnyObject {
    func createAccessTokenAction()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

final class AccessTokenDataView: GpBaseView {
    
    private let defaultAppId = "OWTP5ptQZKGj7EnvPt3uqO844XDBt8Oj"
    private let defaultAppKey = "qM31FmlFiyXRHGYh"
    private let defaultSecondsToExpiry = "60000"
    
    private var permissions: [String] = []
    weak var delegate: AccessTokenDataDelegate?
    
    private struct DimensKeys {
        static let margin: CGFloat = 10
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
        static let disabledButton: CGFloat = 0.3
        static let enabledButton: CGFloat = 1.0
    }
    
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
        field.titleMandatory = "access.token.form.seconds".localized()
        field.inputMode = .numberPad
        field.tagField = .secondsToExpire
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var envIntervalFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "access.token.form.environment".localized()
        fields.secondTitle = "access.token.form.interval".localized()
        
        fields.setFirstTagField(.env, delegate: self)
        fields.setSecondTagField(.interval, delegate: self)
        
        let envs =  Environment.allCases.map { "\($0)".uppercased() }
        let intervals = IntervalToExpire.allCases.map { $0.rawValue.uppercased() }
        
        fields.setDropDownBoth(envs, secondData: intervals)
        return fields
    }()
    
    private lazy var permissionsLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.2368322909, green: 0.2476202846, blue: 0.2835682631, alpha: 1)
        label.text = "home.create.token.permissions.label".localized()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let columnLayout = ColumnFlowLayout(
        cellsPerRow: 2,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    )
    
    private lazy var collectionPermissionsView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: columnLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(PermissionItemViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var createTokenButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "access.token.create".localized())
        button.addTarget(self, action: #selector(createTokenPressed), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = DimensKeys.disabledButton
        return button
    }()
    
    override init() {
        super.init()
        title = "access.token.create".localized()
        descriptionValue = "home.create.token.description.long".localized()
        setUpScrollContainerViewConstraints()
        setUpAppIdFieldConstraints()
        setUpAppKeyFieldConstraints()
        setUpSecondsToExpireFieldConstraints()
        setUpEnvIntervalFieldsConstraints()
        setUpPermissionsLabelConstraints()
        setUpCollectionPermissionsViewConstraints()
        setUpCreateTokenButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: createTokenButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/AccessToken/"
        codeResponseView.fileLabel = "AccessTokenViewModel.swift"
        codeResponseView.titleResponseDataView = "AccessTokenInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "access_token_code")
    }
    
    private func setUpScrollContainerViewConstraints() {
        addSubview(scrollContainerView)
        scrollContainerView.addSubview(containerView)
        NSLayoutConstraint.activating([
            scrollContainerView.relativeTo(separatorLineView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            scrollContainerView.relativeTo(self, positioned: .safeBottom()),
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
    
    private func setUpEnvIntervalFieldsConstraints() {
        containerView.addSubview(envIntervalFieldsView)
        NSLayoutConstraint.activating([
            envIntervalFieldsView.relativeTo(secondsToExpireFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpPermissionsLabelConstraints() {
        containerView.addSubview(permissionsLabelView)
        NSLayoutConstraint.activating([
            permissionsLabelView.relativeTo(envIntervalFieldsView, positioned: .left() + .below(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCollectionPermissionsViewConstraints() {
        containerView.addSubview(collectionPermissionsView)
        NSLayoutConstraint.activating([
            collectionPermissionsView.relativeTo(permissionsLabelView, positioned: .below(spacing: DimensKeys.marginSmall) + .left()),
            collectionPermissionsView.relativeTo(envIntervalFieldsView, positioned: .right() + .constantHeight(200))
        ])
    }
    
    private func setUpCreateTokenButtonConstraints() {
        containerView.addSubview(createTokenButton)
        NSLayoutConstraint.activating([
            createTokenButton.relativeTo(containerView, positioned: .width(DimensKeys.marginBig)),
            createTokenButton.constrainedBy(.constantHeight(48)),
            createTokenButton.relativeTo(collectionPermissionsView, positioned: .below(spacing: DimensKeys.marginMedium))
        ])
    }
    
    func setPermissions(_ permissions: [String]) {
        self.permissions = permissions
        collectionPermissionsView.reloadData()
    }
    
    func enableCreateAccessButton(_ enable: Bool) {
        createTokenButton.isEnabled = enable
        createTokenButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.enabledButton
    }
    
    @objc func createTokenPressed() {
        delegate?.createAccessTokenAction()
    }
    
    func setDefaultData() {
        appIdFieldView.text = defaultAppId
        appKeyFieldView.text = defaultAppKey
        secondsToExpireFieldView.text = defaultSecondsToExpiry
    }
    
    func toBottomView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.moveToBottomView()
        }
    }
    
    private func moveToBottomView() {
        let bottomOffset = CGPoint(x: 0, y: scrollContainerView.contentSize.height - scrollContainerView.bounds.height + scrollContainerView.contentInset.bottom)
        scrollContainerView.setContentOffset(bottomOffset, animated: true)
    }
}

extension AccessTokenDataView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return permissions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PermissionItemViewCell
        cell.title = permissions[indexPath.row]
        return cell
    }
}

extension AccessTokenDataView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
