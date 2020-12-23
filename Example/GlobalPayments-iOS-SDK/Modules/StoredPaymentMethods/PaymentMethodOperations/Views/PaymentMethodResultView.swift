import UIKit

final class PaymentMethodResultView: UIView {

    @IBOutlet private weak var stackView: UIStackView!

    class func instantiateFromNib() -> PaymentMethodResultView {
        let nib = UINib(nibName: "PaymentMethodResultView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! PaymentMethodResultView
        return nib
    }

    func display(_ models: [PaymentMethodResultModel]) {
        for model in models {

            let titleLabel = UILabel()
            titleLabel.text = model.title
            titleLabel.textAlignment = .left
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

            let descriptionLabel = SelectableLabel()
            descriptionLabel.text = model.description
            descriptionLabel.numberOfLines = 0
            descriptionLabel.textAlignment = .right
            descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)

            let horizontalStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
            horizontalStackView.alignment = .top
            horizontalStackView.distribution = .fill
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = 8

            stackView.addArrangedSubview(horizontalStackView)
        }
    }
}
