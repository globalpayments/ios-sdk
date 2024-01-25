import UIKit

protocol GlobalPaymentProcessDelegate: AnyObject {
    func menuItemAction(_ index: Int)
    func backViewAction()
}

class PaymentProcessView: GpBaseView {
    
    private struct DimensKeys {
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let cellId: String = "SingleItemViewCell"
    }
    
    public weak var delegate: GlobalPaymentProcessDelegate?
    
    private var items: [SingleItemEntity] = []
    
    private lazy var homeItemsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SingleItemViewCell.self, forCellReuseIdentifier: DimensKeys.cellId)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override init() {
        super.init()
        title = "home.process.payment.title".localized()
        separatorLineView.backgroundColor = .clear
        setUpHomeItemsTableViewConstraints()
    }
    
    private func setUpHomeItemsTableViewConstraints() {
        addSubview(homeItemsTableView)
        NSLayoutConstraint.activating([
            homeItemsTableView.relativeTo(titleLabel, positioned: .below(spacing: DimensKeys.marginSmall)),
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
    
    func setItems(_ items: [SingleItemEntity]) {
        self.items = items
        homeItemsTableView.reloadData()
    }
}

extension PaymentProcessView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DimensKeys.cellId, for: indexPath) as! SingleItemViewCell
        let item = items[indexPath.row]
        cell.singleItem = item
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.menuItemAction(indexPath.row)
    }
}
