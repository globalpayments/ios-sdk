import UIKit
import GlobalPayments_iOS_SDK

protocol ProductsDelegate: AnyObject {
    func onSubmitProducts(_ data: [Product])
}

final class ProductsViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Products"
    
    var viewModel: ProductsViewInput!
    var products = [Product]()
    var delegate: ProductsDelegate?
    
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var selectProductsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        selectProductsButton.apply(style: .globalPayStyle, title: "products.select.title.button".localized())
        setupTable()
        viewModel.initDataMock()
    }
    
    private func setupTable() {
        productsTableView.dataSource = self
        productsTableView.delegate = self
        productsTableView.register(UINib(nibName: ProductTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: ProductTableViewCell.identifier)
    }
    
    @IBAction func onProductsSelectedAction(_ sender: Any) {
        viewModel.onSubmitProducts()
    }
}

extension ProductsViewController: ProductsViewOutput {
    func onSubmitProducts(_ data: [Product]) {
        delegate?.onSubmitProducts(data)
        dismiss(animated: true)
    }
    
    func reloadProductsData() {
        productsTableView.reloadData()
    }
}

extension ProductsViewController: UITableViewDelegate, UITableViewDataSource, ProductCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        cell.delegate = self
        cell.setup(self.viewModel.products[indexPath.row])
        return cell
    }
    
    func radioStateChanged(product: Product, state: Bool) {
        viewModel.addRemoveProducts(product: product, state: state)
    }
}
