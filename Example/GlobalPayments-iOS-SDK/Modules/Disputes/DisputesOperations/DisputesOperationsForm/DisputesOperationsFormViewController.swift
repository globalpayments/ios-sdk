import UIKit
import GlobalPayments_iOS_SDK

final class DisputesOperationsFormViewController: BaseViewController<DisputesOperationsFormViewModel> {

    private lazy var customView = {
        let view = DisputesOperationsFormView()
        view.delegateView = self
        view.delegate = self
        return view
    }()
    
    private lazy var imagePicker: ImagePicker = {
        ImagePicker(delegate: self)
    }()
    
    override func loadView() {
        view = customView
    }
    
    override func fillUI() {
        super.fillUI()
        
        viewModel?.addDocument.bind { [weak self] doc in
            self?.customView.addDocument(doc)
        }
        
        viewModel?.showLoading.bind { [weak self] in
            self?.customView.showLoading(true)
        }
        
        viewModel?.hideLoading.bind { [weak self] in
            self?.customView.showLoading(false)
        }
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.customView.toBottomView()
            self?.viewModel?.hideLoading.executer()
        }
        
        customView.defaultValues()
    }
}

extension DisputesOperationsFormViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        viewModel?.validateDocument(image)
    }
}


extension DisputesOperationsFormViewController: DisputesOperationsFormViewDelegate {
    
    func onSubmitPressed(_ documents: [DocumentInfo]) {
        viewModel?.onSubmitPressed(documents)
    }
    
    func onDocumentPressed() {
        imagePicker.present(from: customView)
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}
