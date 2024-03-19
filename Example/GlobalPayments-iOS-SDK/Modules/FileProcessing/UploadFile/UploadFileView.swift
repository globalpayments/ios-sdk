import UIKit
import GlobalPayments_iOS_SDK

protocol UploadFileViewDelegate: AnyObject {
    func onAddDocumentButtonPressed()
    func onUploadFileButtonPressed()
}

final class UploadFileView: GpBaseSingleView {
    
    weak var delegate: UploadFileViewDelegate?
    
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
    
    private lazy var addDocumentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyFlat(style: .redesignStyle, title: "file.proccessing.add.document.button".localized().uppercased())
        button.addTarget(self, action: #selector(addDocumentButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var uploadFileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "file.proccessing.initiate.file.processing.button".localized().uppercased())
        button.addTarget(self, action: #selector(uploadFileButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        separatorLineView.backgroundColor = .clear
        setUpScrollContainerViewConstraints()
        setUpAddDocumentButtonConstraints()
        setUpUploadFileButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: uploadFileButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/FileProcessing/UploadFile"
        codeResponseView.fileLabel = "UploadFileViewModel.swift"
        codeResponseView.titleResponseDataView = "UploadFile"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "file_processing_upload_code")
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
    
    private func setUpAddDocumentButtonConstraints() {
        containerView.addSubview(addDocumentButton)
        NSLayoutConstraint.activating([
            addDocumentButton.relativeTo(containerView, positioned: .top() + .width(DimensKeys.marginMedium)),
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
}

