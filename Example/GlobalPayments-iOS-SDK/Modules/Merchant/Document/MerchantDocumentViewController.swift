import UIKit
import MobileCoreServices

final class MerchantDocumentViewController: BaseViewController<MerchantDocumentViewModel> {
    
    private lazy var customView = {
        let view = MerchantDocumentView()
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        view = customView
    }
    
    override func fillUI() {
        super.fillUI()
        
        viewModel?.validateUploadFileButton.bind { [weak self] enable in
            self?.customView.enableUploadFileButton(enable)
        }
        
        viewModel?.showLoading.bind { [weak self] in
            self?.customView.showLoading(true)
        }
        
        viewModel?.hideLoading.bind { [weak self] in
            self?.customView.showLoading(false)
        }
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.viewModel?.hideLoading.executer()
        }
        
        customView.defaultValues()
    }
    
    func selectFiles() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true)
    }
}

extension MerchantDocumentViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        viewModel?.selectedFileToUpload(urls: urls)
    }
    
}

extension MerchantDocumentViewController: MerchantDocumentViewDelegate {
    
    func onAddDocumentButtonPressed() {
        selectFiles()
    }
    
    func onUploadFileButtonPressed() {
        viewModel?.uploadDocument()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}

