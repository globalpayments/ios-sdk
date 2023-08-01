import Foundation
import GlobalPayments_iOS_SDK

protocol ProductsViewInput: AnyObject {
    var products: [Product] { get set }
    func defaultProductsSelected(_ selectedList: [Product])
    func initDataMock()
    func addRemoveProducts(product: Product, state: Bool)
    func onSubmitProducts()
}

protocol ProductsViewOutput: AnyObject {
    func reloadProductsData()
    func onSubmitProducts(_ data: [Product])
}

final class ProductsViewModel: ProductsViewInput {
    
    var products: [Product] = []
    var selectedProducts: [Product]? = []
    
    weak var view: ProductsViewOutput?
    private let CURRENCY = "USD"
    
    func defaultProductsSelected(_ selectedList: [Product]) {
        
    }
    
    func initDataMock() {
        for _ in 0...10 {
            let product = Product()
            product.productId = UUID().uuidString
            product.productName = "iPhone 13"
            product.descriptionProduct = "iPhone 13"
            product.quantity = 1
            product.unitPrice = NSDecimalNumber(decimal: 550)
            product.taxAmount = NSDecimalNumber(decimal: 1)
            product.discountAmount = NSDecimalNumber(decimal: 0)
            product.taxPercentage = NSDecimalNumber(decimal: 0)
            product.netUnitAmount = NSDecimalNumber(decimal: 550)
            product.giftCardCurrency = CURRENCY
            product.url = "https://www.example.com/iphone.html"
            product.imageUrl = "https://www.example.com/iphone.png"
            products.append(product)
        }

        view?.reloadProductsData()
    }
    
    func addRemoveProducts(product: Product, state: Bool) {
        if state {
            if let index = selectedProducts?.firstIndex(where: { $0.productId == product.productId }) {
                selectedProducts?.remove(at: index)
            }
        } else {
            selectedProducts?.append(product)
        }
    }
    
    func onSubmitProducts() {
        view?.onSubmitProducts(selectedProducts ?? [])
    }
}
