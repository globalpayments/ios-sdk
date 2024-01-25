import UIKit

class HomeItemViewCell : UITableViewCell {
    
    private struct DimensKeys {
        static let margin: CGFloat = 20
        static let marginBig: CGFloat = 30
        static let marginMedium: CGFloat = 10
        static let marginSmall: CGFloat = 5
    }
    
    var homeItem : HomeItemEntity? {
        didSet {
            itemImage.image = homeItem?.image
            itemTitleLabel.text = homeItem?.title
            itemDescriptionLabel.text = homeItem?.description
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
    
    private lazy var itemImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
        setUpImageConstraints()
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
    
    private func setUpImageConstraints() {
        mainBackground.addSubview(itemImage)
        NSLayoutConstraint.activating([
            itemImage.relativeTo(mainBackground, positioned: .top(margin: DimensKeys.marginBig) + .left(margin: DimensKeys.margin) + .bottom(margin: DimensKeys.marginBig)),
            itemImage.constrainedBy(.constantHeight(38) + .constantWidth(38))
        ])
    }
    
    private func setUpTitleLabelConstraints() {
        mainBackground.addSubview(itemTitleLabel)
        NSLayoutConstraint.activating([
            itemTitleLabel.relativeTo(itemImage, positioned: .toRight(spacing: DimensKeys.margin)),
            itemTitleLabel.relativeTo(mainBackground, positioned: .top(margin: DimensKeys.margin))
        ])
    }
    
    private func setUpDescriptionLabelConstraints() {
        mainBackground.addSubview(itemDescriptionLabel)
        NSLayoutConstraint.activating([
            itemDescriptionLabel.relativeTo(itemTitleLabel, positioned: .left() + .below(spacing: DimensKeys.marginSmall))
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
