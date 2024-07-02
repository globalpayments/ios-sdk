import Foundation

import UIKit
import GlobalPayments_iOS_SDK

protocol MerchantDocumentViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onAddDocumentButtonPressed()
    func onUploadFileButtonPressed()
}

final class MerchantDocumentView: GpBaseSingleView {
    
    private let idDefault = "MER_98f60f1a397c4dd7b7167bda61520292"
    
    weak var delegate: MerchantDocumentViewDelegate?
    
    private lazy var scrollContainerView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var idFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "deposits.mid".localized()
        field.delegate = self
        field.tagField = .merchantId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var documentTypeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "document.picker.view.type".localized()
        field.setDropDown(MerchantDocumentType.allCases.map { $0.rawValue.uppercased() }, defaultValue: 0)
        field.delegate = self
        field.tagField = .merchantDocumentType
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var documentCategoryFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "document.picker.view.category".localized()
        field.setDropDown(MerchantDocumentCategory.allCases.map { $0.rawValue.uppercased() }, defaultValue: 0)
        field.delegate = self
        field.tagField = .merchantDocumentCategory
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var addDocumentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyFlat(style: .redesignStyle, title: "file.proccessing.select.document.button".localized().uppercased())
        button.addTarget(self, action: #selector(addDocumentButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var uploadFileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "file.proccessing.upload.document.button".localized().uppercased())
        button.addTarget(self, action: #selector(uploadFileButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        setUpScrollContainerViewConstraints()
        setUpIdFieldConstraints()
        setUpAddDocumentTypeFieldConstraints()
        setUpAddDocumentCategoryFieldConstraints()
        setUpAddDocumentButtonConstraints()
        setUpUploadFileButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: uploadFileButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Merchant/Document"
        codeResponseView.fileLabel = "MerchantDocumentViewModel.swift"
        codeResponseView.titleResponseDataView = "MerchantDocument"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "merchant_upload_document")
    }
    
    private func setUpScrollContainerViewConstraints() {
        addSubview(scrollContainerView)
        scrollContainerView.addSubview(containerView)
        NSLayoutConstraint.activating([
            scrollContainerView.relativeTo(separatorLineView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            scrollContainerView.relativeTo(self, positioned: .safeBottom()),
            containerView.relativeTo(scrollContainerView, positioned: .width() + .top() + .centerX() + .bottom())
        ])
    }
    
    private func setUpIdFieldConstraints() {
        containerView.addSubview(idFieldView)
        NSLayoutConstraint.activating([
            idFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpAddDocumentTypeFieldConstraints() {
        containerView.addSubview(documentTypeFieldView)
        NSLayoutConstraint.activating([
            documentTypeFieldView.relativeTo(idFieldView, positioned: .belowWidth(spacing: DimensKeys.marginSmall))
        ])
    }
    
    private func setUpAddDocumentCategoryFieldConstraints() {
        containerView.addSubview(documentCategoryFieldView)
        NSLayoutConstraint.activating([
            documentCategoryFieldView.relativeTo(documentTypeFieldView, positioned: .belowWidth(spacing: DimensKeys.marginSmall))
        ])
    }
    
    private func setUpAddDocumentButtonConstraints() {
        containerView.addSubview(addDocumentButton)
        NSLayoutConstraint.activating([
            addDocumentButton.relativeTo(documentCategoryFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            addDocumentButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    private func setUpUploadFileButtonConstraints() {
        containerView.addSubview(uploadFileButton)
        enableUploadFileButton(false)
        NSLayoutConstraint.activating([
            uploadFileButton.relativeTo(addDocumentButton, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            uploadFileButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func enableUploadFileButton(_ enable: Bool) {
        uploadFileButton.isEnabled = enable
        uploadFileButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
    }
    
    @objc func addDocumentButtonPressed() {
        delegate?.onAddDocumentButtonPressed()
    }
    
    @objc func uploadFileButtonPressed() {
        delegate?.onUploadFileButtonPressed()
    }
    
    func defaultValues() {
        idFieldView.text = idDefault
    }
}

extension MerchantDocumentView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
