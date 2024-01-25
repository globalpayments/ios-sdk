import UIKit

protocol GpTextFieldDelegate: AnyObject {
    func textChanged(value: String, type: GpFieldsEnum)
}

class GpTextFieldView: View {
    
    private struct DimensKeys {
        static let margin: CGFloat = 10
        static let minimalMargin: CGFloat = 2
        static let heightInputView: CGFloat = 48
    }
    
    weak var delegate: GpTextFieldDelegate?
    
    var title: String? {
        didSet {
            titleLabelView.text = title
        }
    }
    
    var titleMandatory: String? {
        didSet {
            titleLabelView.attributedText = labelMandatory(titleMandatory)
        }
    }
    
    var text: String? {
        didSet{
            inputFieldView.text = text
            inputFieldView.sendActions(for: .editingChanged)
        }
    }
    
    var inputMode: UIKeyboardType = .alphabet {
        didSet{
            inputFieldView.keyboardType = inputMode
        }
    }
    
    var inputPickerView: UIView? {
        didSet{
            inputFieldView.inputView = inputPickerView
        }
    }
    
    var tagField: GpFieldsEnum = .none {
        didSet{
            inputFieldView.tag = tagField.rawValue
        }
    }
    
    var currency: String? {
        didSet{
            let prefix = UILabel()
            prefix.text = "  " + (currency ?? "")
            prefix.textAlignment = .right
            inputFieldView.leftView = prefix
            inputFieldView.leftViewMode = .always
        }
    }
    
    private lazy var titleLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.2368322909, green: 0.2476202846, blue: 0.2835682631, alpha: 1)
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var inputFieldView: UITextField = {
        let input = UITextField()
        let borderColor = #colorLiteral(red: 0.8235294118, green: 0.8470588235, blue: 0.8823529412, alpha: 1)
        input.roundedCorners(borderColor)
        input.setPadding(10)
        input.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()
    
    override init() {
        super.init()
        setUpTitleLabelConstraints()
        setUpInputFieldViewConstraints()
    }
    
    private func setUpTitleLabelConstraints() {
        addSubview(titleLabelView)
        NSLayoutConstraint.activating([
            titleLabelView.relativeTo(self, positioned: .top() + .left(margin: DimensKeys.minimalMargin))
        ])
    }
    
    private func setUpInputFieldViewConstraints() {
        addSubview(inputFieldView)
        NSLayoutConstraint.activating([
            inputFieldView.relativeTo(titleLabelView, positioned: .below(spacing: DimensKeys.margin)),
            inputFieldView.relativeTo(self, positioned: .bottom() + .width() + .constantHeight(DimensKeys.heightInputView))
        ])
    }
    
    func setDropDown(_ data: [String], onSelectItem: ((String) -> Void)? = nil, defaultValue: Int = -1) {
        inputFieldView.loadDropDownData(data, onSelectItem: onSelectItem, defaultValue: defaultValue)
        inputFieldView.tintColor = UIColor.clear
        inputFieldView.delegate = self
    }
    
    func setDateDropDown(format: String? = nil) {
        inputFieldView.loadDate(format: format)
        inputFieldView.tintColor = UIColor.clear
        inputFieldView.delegate = self
    }
    
    @objc final private func textChanged(textField: UITextField) {
        guard let value = textField.text else { return }
        delegate?.textChanged(value: value, type: .init(value: textField.tag) ?? .none)
    }
    
    private func labelMandatory(_ value: String?) -> NSAttributedString {
        let firstAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 16)]
        let secondAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.red]

        let firstString = NSMutableAttributedString(string: value ?? "", attributes: firstAttributes)
        let secondString = NSAttributedString(string: " *", attributes: secondAttributes)
        firstString.append(secondString)
        return firstString
    }
    
    func onFieldClicked(action: @escaping () -> Void) {
        inputFieldView.addDropArrow()
        inputFieldView.setOnClickListener(action: action)
    }
}

extension GpTextFieldView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
