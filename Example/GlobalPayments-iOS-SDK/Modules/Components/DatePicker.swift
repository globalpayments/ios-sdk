import UIKit

final class DatePicker: UIDatePicker {

    private var pickerTextField: UITextField
    private var selectionHandler: ((String) -> Void)?

    init(dropdownField: UITextField, inputDate: Date) {
        self.pickerTextField = dropdownField
        super.init(frame: .zero)
        datePickerMode = .date
        addTarget(self, action: #selector(self.onDateChanged), for: .allEvents)
        setDate(inputDate, animated: true)
        if #available(iOS 14, *) {
            preferredDatePickerStyle = .wheels
        }

        if let text = pickerTextField.text, let handler = selectionHandler {
            handler(text)
        }

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolBar.setItems(
            [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(self.onClearAction)),
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.onCancelAction)),
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.onDoneAction))
            ],
            animated: true
        )
        pickerTextField.inputAccessoryView = toolBar
    }

    convenience init(dropdownField: UITextField, inputDate: Date, onSelect: ((String) -> Void)?) {
        self.init(dropdownField: dropdownField, inputDate: inputDate)
        self.selectionHandler = onSelect
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onDoneAction() {
        pickerTextField.text = "\(self.date)"
        pickerTextField.resignFirstResponder()
    }

    @objc private func onCancelAction() {
        pickerTextField.resignFirstResponder()
    }

    @objc private func onClearAction() {
        pickerTextField.text = nil
        pickerTextField.resignFirstResponder()
    }

    @objc private func onDateChanged() {
        pickerTextField.text = "\(self.date)"
    }
}
