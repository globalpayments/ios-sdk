import UIKit

protocol DoubleFieldViewDelegate: AnyObject {
    func onFirstFieldItemSelected(_ value: String)
    func onSecondFieldItemSelected(_ value: String)
}

class GpDoubleFieldView : View {
    
    private struct DimensKeys {
        static let margin: CGFloat = 10
        static let minimalMargin: CGFloat = 2
        static let heightInputView: CGFloat = 48
    }
    
    weak var delegate: DoubleFieldViewDelegate?
    
    var firstTitle: String? {
        didSet {
            firstFieldView.title = firstTitle
        }
    }
    
    var firstMandatory: String? {
        didSet{
            firstFieldView.titleMandatory = firstMandatory
        }
    }
    
    var secondTitle: String? {
        didSet {
            secondFieldView.title = secondTitle
        }
    }
    
    var secondMandatory: String? {
        didSet{
            secondFieldView.titleMandatory = secondMandatory
        }
    }
    
    var firstText: String? {
        didSet {
            firstFieldView.text = firstText
        }
    }
    
    var secondText: String? {
        didSet {
            secondFieldView.text = secondText
        }
    }
    
    private lazy var firstFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var secondFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    var firstInputPickerView: UIView? {
        didSet{
            firstFieldView.inputPickerView = firstInputPickerView
        }
    }
    
    var secondInputPickerView: UIView? {
        didSet{
            secondFieldView.inputPickerView = secondInputPickerView
        }
    }
    
    private lazy var containerFieldsView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init() {
        super.init()
        setUpContainerFieldsConstraints()
    }
    
    private func setUpContainerFieldsConstraints() {
        addSubview(containerFieldsView)
        containerFieldsView.addArrangedSubview(firstFieldView)
        containerFieldsView.addArrangedSubview(secondFieldView)
        NSLayoutConstraint.activating([
            containerFieldsView.relativeTo(self, positioned: .allAnchors())
        ])
    }
    
    func setDropDownBoth(_ firstData: [String] = [], secondData: [String] = [], defaultFirstValue: Int = -1, defaultSecondValue: Int = -1) {
        
        if !firstData.isEmpty {
            firstFieldView.setDropDown(firstData, onSelectItem: onFirstFieldDidChange(value:), defaultValue: defaultFirstValue)
        }
        
        if !secondData.isEmpty {
            secondFieldView.setDropDown(secondData, onSelectItem: onSecondFieldDidChange(value:), defaultValue: defaultSecondValue)
        }
    }
    
    func setFirstTagField(_ type: GpFieldsEnum, delegate: GpTextFieldDelegate) {
        firstFieldView.tagField = type
        firstFieldView.delegate = delegate
    }
    
    func setSecondTagField(_ type: GpFieldsEnum, delegate: GpTextFieldDelegate) {
        secondFieldView.tagField = type
        secondFieldView.delegate = delegate
    }
    
    private func onFirstFieldDidChange(value: String) {
        firstFieldView.text = value
        delegate?.onFirstFieldItemSelected(value)
    }
    
    private func onSecondFieldDidChange(value: String) {
        secondFieldView.text = value
        delegate?.onSecondFieldItemSelected(value)
    }
    
    var enableInputSecondField: Bool = true {
        didSet {
            secondFieldView.isUserInteractionEnabled = enableInputSecondField
        }
    }
}

extension DoubleFieldViewDelegate {
    func onFirstFieldItemSelected(_ value: String){}
    func onSecondFieldItemSelected(_ value: String){}
}
