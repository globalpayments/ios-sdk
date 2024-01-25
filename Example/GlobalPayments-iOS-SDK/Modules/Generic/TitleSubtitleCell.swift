import UIKit

class TitleSubtitleCell : UITableViewCell {
    
    private struct DimensKeys {
        static let margin: CGFloat = 20
        static let marginBig: CGFloat = 30
        static let marginMedium: CGFloat = 10
        static let marginSmall: CGFloat = 5
    }
    
    var title: String? {
        didSet {
            itemTitleLabel.text = title
        }
    }
    
    var subTitle: String? {
        didSet {
            itemDescriptionLabel.text = subTitle
        }
    }
    
    private let mainBackground: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private let itemTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1882352941, blue: 0.2196078431, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let itemDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomLineView: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        return line
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setUpMainBackgroundConstraints()
        setUpTitleLabelConstraints()
        setUpDescriptionLabelConstraints()
        setUpBottomLineConstraints()
    }
    
    private func setUpMainBackgroundConstraints() {
        addSubview(mainBackground)
        NSLayoutConstraint.activating([
            mainBackground.relativeTo(self, positioned: .top() + .bottom(margin: DimensKeys.marginSmall) + .width())
        ])
    }
    
    private func setUpTitleLabelConstraints() {
        mainBackground.addSubview(itemTitleLabel)
        NSLayoutConstraint.activating([
            itemTitleLabel.relativeTo(mainBackground, positioned: .left(margin: DimensKeys.marginMedium) + .top() + .right())
        ])
    }
    
    private func setUpDescriptionLabelConstraints() {
        mainBackground.addSubview(itemDescriptionLabel)
        NSLayoutConstraint.activating([
            itemDescriptionLabel.relativeTo(itemTitleLabel, positioned: .left() + .below(spacing: DimensKeys.marginSmall)),
            itemDescriptionLabel.relativeTo(mainBackground, positioned: .right())
        ])
    }
    
    private func setUpBottomLineConstraints() {
        mainBackground.addSubview(bottomLineView)
        NSLayoutConstraint.activating([
            bottomLineView.relativeTo(itemDescriptionLabel, positioned: .below(spacing: DimensKeys.marginMedium)),
            bottomLineView.relativeTo(mainBackground, positioned: .bottom() + .width(DimensKeys.marginMedium) + .constantHeight(0.5))
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
