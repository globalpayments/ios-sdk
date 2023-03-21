import UIKit
import GlobalPayments_iOS_SDK

final class ThreeDSecureView: UIView {

    @IBOutlet private weak var rootStackView: UIStackView!

    class func instantiateFromNib() -> ThreeDSecureView {
        let nib = UINib(nibName: "ThreeDSecureView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! ThreeDSecureView

        return nib
    }

    func display(_ threeDSecure: ThreeDSecure) {
        let mirror = Mirror(reflecting: threeDSecure)
        for child in mirror.children {
            let titleLabel = UILabel()
            titleLabel.text = child.label
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .left
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

            let descriptionLabel = SelectableLabel()
            if let value = child.value as? String {
                descriptionLabel.text = value
            } else if let value = child.value as? [String] {
                descriptionLabel.text = "\(value)"
            } else if let value = child.value as? Int {
                descriptionLabel.text = "\(value)"
            } else if let value = child.value as? NSDecimalNumber {
                descriptionLabel.text = "\(value)"
            } else if let value = child.value as? Bool {
                descriptionLabel.text = "\(value)"
            } else if let value = child.value as? Secure3dVersion {
                descriptionLabel.text = "\(value)"
            } else if let value = child.value as? ExemptStatus {
                descriptionLabel.text = "\(value)"
            } else if let value = child.value as? ExemptReason {
                descriptionLabel.text = "\(value)"
            } else {
                continue
            }
            descriptionLabel.numberOfLines = 0
            descriptionLabel.textAlignment = .right
            descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)

            let hStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
            if (descriptionLabel.text?.count ?? .zero) > 30 {
                hStackView.axis = .vertical
                descriptionLabel.textAlignment = .left
            } else {
                hStackView.axis = .horizontal
            }
            hStackView.alignment = .fill
            hStackView.distribution = .fill
            hStackView.spacing = 4

            rootStackView.addArrangedSubview(hStackView)
        }
    }
}

extension Dictionary {

    func compactMapValues<U>(_ transform: (Value) throws -> U?) rethrows -> [Key: U] {
        var result = [Key: U]()
        for (key, value) in self {
            result[key] = try transform(value)
        }
        return result
    }
}
