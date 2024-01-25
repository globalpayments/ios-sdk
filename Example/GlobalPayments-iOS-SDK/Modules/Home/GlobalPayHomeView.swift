import UIKit

protocol GlobalPayHomeDelegate: AnyObject {
    func onSettingsButtonPressed()
    func homeItemAction(_ index: Int)
}

class GlobalPayHomeView: View {
    
    private struct DimensKeys {
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let cellId: String = "HomeViewCell"
    }
    
    public weak var delegate: GlobalPayHomeDelegate?
    
    private var items: [HomeItemEntity] = []
    
    private lazy var logoGp: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "gp_logo")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var settingsImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "ic_settings")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "home.title".localized()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = #colorLiteral(red: 0, green: 0.3087183237, blue: 0.5186551213, alpha: 1)
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = formatedDescriptionLabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.3529411765, green: 0.368627451, blue: 0.4274509804, alpha: 1)
        return label
    }()
    
    private lazy var homeItemsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HomeItemViewCell.self, forCellReuseIdentifier: DimensKeys.cellId)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override init() {
        super.init()
        setUpLogoGpConstraints()
        setUpSettingsViewConstraints()
        setUpTitleLabelConstraints()
        setUpSubTitleLabelConstraints()
        setUpHomeItemsTableViewConstraints()
    }
    
    private func setUpLogoGpConstraints() {
        addSubview(logoGp)
        NSLayoutConstraint.activating([
            logoGp.relativeTo(self, positioned: .safeTop(margin: DimensKeys.marginTop) + . centerX() + .constantHeight(20) + .constantWidth(130))
        ])
    }
    
    private func setUpSettingsViewConstraints() {
        addSubview(settingsImage)
        settingsImage.setOnClickListener { [weak self] in
            self?.delegate?.onSettingsButtonPressed()
        }
        NSLayoutConstraint.activating([
            settingsImage.relativeTo(self, positioned: .right(margin: DimensKeys.marginSide) + .constantHeight(19) + .constantWidth(19)),
            settingsImage.relativeTo(logoGp, positioned: .centerY())
        ])
    }
    
    private func setUpTitleLabelConstraints() {
        addSubview(titleLabel)
        NSLayoutConstraint.activating([
            titleLabel.relativeTo(logoGp, positioned: .below(spacing: DimensKeys.marginTop) + .centerX())
        ])
    }
    
    private func setUpSubTitleLabelConstraints() {
        addSubview(subTitleLabel)
        NSLayoutConstraint.activating([
            subTitleLabel.relativeTo(titleLabel, positioned: .below(spacing: DimensKeys.marginTop)),
            subTitleLabel.relativeTo(self, positioned: .left(margin: DimensKeys.marginSide) + .right(margin: DimensKeys.marginSide))
        ])
    }
    
    private func setUpHomeItemsTableViewConstraints() {
        addSubview(homeItemsTableView)
        NSLayoutConstraint.activating([
            homeItemsTableView.relativeTo(subTitleLabel, positioned: .below(spacing: DimensKeys.marginSmall)),
            homeItemsTableView.relativeTo(self, positioned: .left(margin: DimensKeys.marginSide) + .right(margin: DimensKeys.marginSide) + .safeBottom(margin: DimensKeys.marginSmall))
        ])
    }
    
    private func formatedDescriptionLabel() -> NSAttributedString {
        let firstAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.boldSystemFont(ofSize: 14)]
        let secondAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 14)]

        let firstString = NSMutableAttributedString(string: "home.prefixSubTitle".localized(), attributes: firstAttributes)
        let secondString = NSAttributedString(string: "home.subTitle".localized(), attributes: secondAttributes)
        firstString.append(secondString)
        return firstString
    }
    
    func setItems(_ items: [HomeItemEntity]) {
        self.items = items
        homeItemsTableView.reloadData()
    }
}

extension GlobalPayHomeView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DimensKeys.cellId, for: indexPath) as! HomeItemViewCell
        let item = items[indexPath.row]
        cell.homeItem = item
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.homeItemAction(indexPath.row)
    }
}
