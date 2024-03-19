import UIKit
import MobileCoreServices

final class UploadFileViewController: BaseViewController<UploadFileViewModel> {
    
    private lazy var customView = {
        let view = UploadFileView()
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
    }
    
    func selectFiles() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true)
    }
}

extension UploadFileViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        viewModel?.selectedFileToUpload(urls: urls)
    }
    
}

extension UploadFileViewController: UploadFileViewDelegate {
    
    func onAddDocumentButtonPressed() {
        selectFiles()
    }
    
    func onUploadFileButtonPressed() {
        viewModel?.uploadFile()
    }
}
