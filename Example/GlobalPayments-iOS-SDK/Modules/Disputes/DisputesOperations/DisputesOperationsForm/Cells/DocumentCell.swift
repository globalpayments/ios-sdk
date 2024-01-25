import UIKit
import GlobalPayments_iOS_SDK

protocol DocumentDelegate: AnyObject {
    func onTrashDocumentPressed(_ row: Int)
    func onDocumentTypeChanged(_ type: DocumentType, row: Int)
}

class DocumentCell: UITableViewCell {
    
    var row: Int = 0
    
    var image: UIImage? = nil {
        didSet{
            documentImage.image = image
        }
    }
    
    weak var delegate: DocumentDelegate?
    
    private struct DimensKeys {
        static let margin: CGFloat = 20
        static let marginBig: CGFloat = 30
        static let marginMedium: CGFloat = 10
        static let marginSmall: CGFloat = 5
    }
    
    private lazy var fileLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.2368322909, green: 0.2476202846, blue: 0.2835682631, alpha: 1)
        label.text = "File Name"
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var documentImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var documentTypeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "transaction.report.by.id.type".localized()
        field.setDropDown(DocumentType.allCases.map { $0.rawValue.uppercased() }, onSelectItem: onDocumentType, defaultValue: 0)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    
    private lazy var trashImage: UIImageView = {
        let image = UIImageView()
        if #available(iOS 13.0, *) {
            image.image = UIImage(systemName: "trash")
        }
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpfileLabelConstraints()
        setUpDocumentImageConstraints()
        setUpTrashImageConstraints()
        setUpDocumentTypeConstraints()
    }
    
    private func setUpfileLabelConstraints() {
        contentView.addSubview(fileLabelView)
        NSLayoutConstraint.activating([
            fileLabelView.relativeTo(contentView, positioned: .top(margin: DimensKeys.marginMedium) + .left(margin: DimensKeys.marginSmall) + .constantWidth(80))
        ])
    }
    
    private func setUpDocumentImageConstraints() {
        contentView.addSubview(documentImage)
        NSLayoutConstraint.activating([
            documentImage.relativeTo(contentView, positioned: .bottom(margin: DimensKeys.marginMedium)),
            documentImage.relativeTo(fileLabelView, positioned: .left() + .below(spacing: DimensKeys.marginSmall) + .constantHeight(60) + .constantWidth(60))
        ])
    }
    
    private func setUpDocumentTypeConstraints() {
        contentView.addSubview(documentTypeFieldView)
        NSLayoutConstraint.activating([
            documentTypeFieldView.relativeTo(contentView, positioned: .top(margin: DimensKeys.marginSmall)),
            documentTypeFieldView.relativeTo(fileLabelView, positioned: .toRight(spacing: DimensKeys.marginSmall)),
            documentTypeFieldView.relativeTo(trashImage, positioned: .toLeft(spacing: DimensKeys.marginBig)),
            documentTypeFieldView.relativeTo(documentImage, positioned: .bottom())
        ])
    }
    
    private func setUpTrashImageConstraints() {
        contentView.addSubview(trashImage)
        
        trashImage.setOnClickListener {
            self.delegate?.onTrashDocumentPressed(self.row)
        }
        NSLayoutConstraint.activating([
            trashImage.relativeTo(contentView, positioned: .right(margin: DimensKeys.marginSmall) + .centerY(offset: 10) + .constantHeight(35) + .constantWidth(30))
        ])
    }
    
    private func onDocumentType(_ value: String) {
        let type = DocumentType(value: value) ?? .salesReceipt
        delegate?.onDocumentTypeChanged(type, row: row)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
