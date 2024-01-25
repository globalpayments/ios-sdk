import UIKit

class SingleItemViewCell : UITableViewCell {
    
    private struct DimensKeys {
        static let margin: CGFloat = 20
        static let marginBig: CGFloat = 30
        static let marginMedium: CGFloat = 10
        static let marginSmall: CGFloat = 5
    }
    
    var singleItem : SingleItemEntity? {
        didSet {
            itemTitleLabel.text = singleItem?.title
            itemDescriptionLabel.text = singleItem?.description
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
        label.font = UIFont.boldSystemFont(ofSize: 16)
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
    
    private lazy var nextScreenImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "ic_next_screen")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setRoundedShadowCorners()
        setUpMainBackgroundConstraints()
        setUpTitleLabelConstraints()
        setUpDescriptionLabelConstraints()
        setUpNextScreenImageConstraints()
    }
    
    private func setRoundedShadowCorners() {
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        
        mainBackground.backgroundColor = .white
        mainBackground.layer.cornerRadius = 8
    }
    
    private func setUpMainBackgroundConstraints() {
        addSubview(mainBackground)
        NSLayoutConstraint.activating([
            mainBackground.relativeTo(self, positioned: .top(margin: DimensKeys.margin) + .bottom(margin: DimensKeys.marginSmall) + .left(margin: DimensKeys.marginSmall) + .right(margin: DimensKeys.marginSmall))
        ])
    }
    
    private func setUpTitleLabelConstraints() {
        mainBackground.addSubview(itemTitleLabel)
        NSLayoutConstraint.activating([
            itemTitleLabel.relativeTo(mainBackground, positioned: .left(margin: DimensKeys.margin) + .top(margin: DimensKeys.margin))
        ])
    }
    
    private func setUpDescriptionLabelConstraints() {
        mainBackground.addSubview(itemDescriptionLabel)
        NSLayoutConstraint.activating([
            itemDescriptionLabel.relativeTo(itemTitleLabel, positioned: .left() + .below(spacing: DimensKeys.marginSmall)),
            itemDescriptionLabel.relativeTo(mainBackground, positioned: .bottom(margin: DimensKeys.margin))
        ])
    }
    
    private func setUpNextScreenImageConstraints() {
        mainBackground.addSubview(nextScreenImage)
        NSLayoutConstraint.activating([
            nextScreenImage.relativeTo(mainBackground, positioned: .right(margin: DimensKeys.margin) + .centerY()),
            nextScreenImage.relativeTo(itemDescriptionLabel, positioned: .toRight(spacing: DimensKeys.marginSmall)),
            nextScreenImage.constrainedBy(.constantHeight(12) + .constantWidth(7))
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

