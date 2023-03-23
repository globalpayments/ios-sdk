import UIKit
import GlobalPayments_iOS_SDK

protocol MerchantProductsDelegate: AnyObject {
    func onSubmitProducts(products: [Product])
}

final class MerchantProductsViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Merchant"
    weak var delegate: MerchantProductsDelegate?
    
    @IBOutlet weak var textFieldProductId: UITextField!
    @IBOutlet weak var buttonAddSingleProduct: UIButton!
    @IBOutlet weak var textFieldQuantity: UITextField!
    @IBOutlet weak var tableViewProducts: UITableView!
    @IBOutlet weak var buttonCreate: UIButton!
    @IBOutlet weak var buttonAddProduct: UIButton!
    
    
    var products = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        buttonCreate.apply(style: .globalPayStyle, title: "merchant.create.payment.products.label".localized())
        buttonAddProduct.apply(style: .globalPayStyle, title: "merchant.create.payment.products.add.label".localized())
    }

    private func setupUI() {
        title = "merchant.create.payment.statistics.title".localized()
        tableViewProducts.delegate = self
        tableViewProducts.dataSource = self
        tableViewProducts.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        hideKeyboardWhenTappedAround()
        
        buttonAddProduct.addTarget(self, action: #selector(addProductAction), for: .touchDown)
        addMockData()
    }
    
    private func addMockData() {
        textFieldProductId.text = "PRO_FMA_PUSH-FUNDS_PP"
        textFieldQuantity.text = "1"
        let product = Product()
        product.productId = "PRO_TRA_CP-US-CARD-A920_SP"
        product.quantity = 1
        products.append(product)
        tableViewProducts.reloadData()
    }
    
    @objc func addProductAction(textField: UITextField) {
        guard let productId = textFieldProductId.text, !productId.isEmpty, let quantity = textFieldQuantity.text, !quantity.isEmpty else { return }
        let product = Product()
        product.productId = productId
        product.quantity = Int(quantity)
        products.append(product)
        tableViewProducts.reloadData()
        textFieldProductId.text = ""
        textFieldQuantity.text = ""
    }
    
    @IBAction func createProductsAction(_ sender: Any) {
        delegate?.onSubmitProducts(products: products)
        dismiss(animated: true)
    }
}

extension MerchantProductsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        cell.textLabel?.text = products[indexPath.row].productId
        return cell
    }
}
