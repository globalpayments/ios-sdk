import UIKit

class PermissionItemViewCell : UICollectionViewCell {
    
    private struct DimensKeys {
        static let margin: CGFloat = 20
        static let marginBig: CGFloat = 30
        static let marginMedium: CGFloat = 10
        static let marginSmall: CGFloat = 5
    }
    
    var title : String? {
        didSet {
            itemTitleLabel.text = title
        }
    }
    
    private let itemTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.1803921569, green: 0.1882352941, blue: 0.2196078431, alpha: 1)
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkBoxView: CheckBox = {
        let checkBox = CheckBox()
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        return checkBox
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpCheckBoxConstraints()
        setUpTitleLabelConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder){
        fatalError("Custom class: View init(coder:) has not been implemented")
    }
    
    private func setUpCheckBoxConstraints() {
        addSubview(checkBoxView)
        NSLayoutConstraint.activating([
            checkBoxView.relativeTo(self, positioned: .left() + .top(margin: DimensKeys.marginSmall) + .bottom(margin: DimensKeys.marginSmall)),
            checkBoxView.constrainedBy(.constantHeight(20) + .constantWidth(20))
        ])
    }
    
    private func setUpTitleLabelConstraints() {
        addSubview(itemTitleLabel)
        NSLayoutConstraint.activating([
            itemTitleLabel.relativeTo(checkBoxView, positioned: .toRight(spacing: DimensKeys.marginMedium) + .centerY()),
            itemTitleLabel.relativeTo(self, positioned: .right(margin: DimensKeys.marginSmall))
        ])
    }
}

