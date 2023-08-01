import UIKit
import GlobalPayments_iOS_SDK

protocol ProductCellDelegate: AnyObject {
    func radioStateChanged(product: Product, state: Bool)
}

final class ProductTableViewCell: UITableViewCell, CellIdentifiable {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var selectedButton: RadioButton!
    private var product: Product?
    var delegate: ProductCellDelegate?
    
    func setup(_ product: Product) {
        self.product = product
        nameLabel.text = product.productName
        priceLabel.text = "\(product.unitPrice ?? 0)"
        selectedButton.addTarget(self, action: #selector(radioStateChanged), for: .valueChanged)
    }
    
    @objc private func radioStateChanged(radioButton: RadioButton) {
        if let product = product {
            delegate?.radioStateChanged(product: product, state: radioButton.isOn)
        }
    }
}
