import UIKit
import GlobalPayments_iOS_SDK

protocol DocumentPickerViewDelegate: class {
    func onSelectDocument(_ document: DocumentInfo)
    func imageNotSelected()
}

final class DocumentPickerView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var fileLabel: UILabel!
    @IBOutlet private weak var selectButton: UIButton!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var typeTextField: UITextField!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var addDocumentButton: UIButton!
    @IBOutlet private weak var clearAndCloseButton: UIButton!
    @IBOutlet private weak var inputStackView: UIStackView!
    @IBOutlet private weak var documentImageView: UIImageView!

    private lazy var imagePicker: ImagePicker = {
        ImagePicker(delegate: self)
    }()

    weak var delegate: DocumentPickerViewDelegate?

    class func instantiateFromNib() -> DocumentPickerView {
        let nib = UINib(nibName: "DocumentPickerView", bundle: .main)
            .instantiate(withOwner: self, options: nil)
            .first as! DocumentPickerView
        nib.setupUI()

        return nib
    }

    private func setupUI() {
        titleLabel?.text = "document.picker.view.title".localized()
        fileLabel?.text = "document.picker.view.file".localized()
        selectButton?.setTitle("document.picker.view.select".localized(), for: .normal)
        typeLabel?.text = "document.picker.view.type".localized()
        typeTextField?.loadDropDownData(DocumentType.allCases.map { $0.rawValue.uppercased() })
        addButton?.apply(style: .globalPayStyle, title: "document.picker.view.add".localized())
        addDocumentButton?.apply(style: .globalPayStyle, title: "document.picker.view.add.document".localized())
        clearAndCloseButton?.apply(style: .globalPayStyle, title: "document.picker.view.clear".localized())
        clearAndCloseButton?.backgroundColor = Theme.cancelButtonFillColor
    }

    private func setSelectState() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [],
                       animations: { [weak self] in
                        self?.inputStackView?.isHidden = false
                        self?.addButton?.isHidden = true
                        self?.addDocumentButton?.isHidden = false
                        self?.clearAndCloseButton?.isHidden = false
                       }
        )
    }

    func setInitialState() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [],
                       animations: { [weak self] in
                        self?.inputStackView?.isHidden = true
                        self?.addButton?.isHidden = false
                        self?.addDocumentButton?.isHidden = true
                        self?.clearAndCloseButton?.isHidden = true
                        self?.documentImageView?.isHidden = true
                        self?.documentImageView.image = nil
                       }
        )
    }

    // MARK: - Actions

    @IBAction private func onSelectFile(_ sender: UIButton) {
        imagePicker.present(from: sender)
    }

    @IBAction private func onAddButtonAction() {
        setSelectState()
    }

    @IBAction private func onAddDocumentAction() {
        guard let type = DocumentType(value: typeTextField.text) else { return }
        guard let content = documentImageView?.image?.pngData() else {
            delegate?.imageNotSelected()
            return
        }
        let document = DocumentInfo(type: type, b64Content: content)
        delegate?.onSelectDocument(document)
    }

    @IBAction private func onClearAndCloseAction() {
        setInitialState()
    }
}

// MARK: - ImagePickerDelegate

extension DocumentPickerView: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        documentImageView?.image = image
        documentImageView?.isHidden = false
    }
}
