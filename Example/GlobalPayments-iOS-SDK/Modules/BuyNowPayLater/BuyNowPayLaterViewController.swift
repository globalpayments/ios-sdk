import UIKit
import GlobalPayments_iOS_SDK

final class BuyNowPayLaterViewController: BaseViewController<BuyNowPayLaterViewModel> {
    
    private lazy var customView = {
        let view = BuyNowPayLaterView()
        view.delegateView = self
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        view = customView
    }
    
    override func fillUI() {
        super.fillUI()
        
        viewModel?.showProductsScreen.bind { [weak self] products in
            let viewController = ProductsBuilder.build(self, selectedProducts: products)
            self?.navigationController?.present(viewController, animated: true, completion: nil)
        }
        
        viewModel?.setProductLabel.bind { [weak self] label in
            self?.customView.setProductsLabel(value: label)
        }
        
        viewModel?.setBillingLabel.bind { [weak self] label in
            self?.customView.setBillingLabel(value: label)
        }
        
        viewModel?.setShippingLabel.bind { [weak self] label in
            self?.customView.setShippingLabel(value: label)
        }
        
        viewModel?.setCustomerLabel.bind { [weak self] label in
            self?.customView.setCustomerLabel(value: label)
        }
        
        viewModel?.showAddressScreen.bind { type in
            let viewController = MerchantAddressBuilder.build(delegate: self, path: type)
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }
        
        viewModel?.showCustomerScreen.bind { [weak self] customerData in
            let viewController = CustomerBuilder.build(delegate: self, defaultData: customerData)
            self?.navigationController?.present(viewController, animated: true, completion: nil)
        }
        
        viewModel?.openUrl.bind { [weak self] url, transactionId in
            self?.viewModel?.hideLoading.executer()
            let viewController = CaptureBnplBuilder.build(transactionId)
            self?.navigationController?.present(viewController, animated: true, completion: nil)
            UIApplication.shared.open(url)
        }
        
        viewModel?.showLoading.bind { [weak self] in
            self?.customView.showLoading(true)
        }
        
        viewModel?.hideLoading.bind { [weak self] in
            self?.customView.showLoading(false)
        }
        
        viewModel?.enableButton.bind { [weak self] enable in
            self?.customView.enableButton(enable)
        }
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.viewModel?.hideLoading.executer()
            self?.customView.toBottomView()
        }
        
        customView.defaultValues()
        viewModel?.setMockData()
    }
}

extension BuyNowPayLaterViewController: BuyNowPayLaterViewDelegate {
    
    func onBillingPressed() {
        viewModel?.onBillingAddressPressed()
    }
    
    func onShippingPressed() {
        viewModel?.onShippingAddressPressed()
    }
    
    func onProductsPressed() {
        viewModel?.onProductsPressed()
    }
    
    func onBnplPressed() {
        viewModel?.onBnplAction()
    }
    
    func onCustomerPressed() {
        viewModel?.onCustomerPressed()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}

extension BuyNowPayLaterViewController: MerchantAddressDelegate {
    
    func onSubmitAddress(address: Address, path: MerchantAddressPath) {
        viewModel?.setAddress(address, path: path)
    }
}

extension BuyNowPayLaterViewController: CustomerDelegate {
    
    func onSubmitCustomer(_ data: Customer) {
        viewModel?.setCustomerData(data)
    }
}

extension BuyNowPayLaterViewController: ProductsDelegate {
    
    func onSubmitProducts(_ data: [Product]) {
        viewModel?.setProducts(data)
    }
}
