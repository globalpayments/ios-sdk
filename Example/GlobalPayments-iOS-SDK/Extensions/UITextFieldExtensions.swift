import Foundation
import UIKit

extension UITextField {

    func loadDropDownData(_ data: [String], onSelectItem: ((String) -> Void)? = nil, defaultValue: Int = 0) {
        self.inputView = DropDown(pickerData: data, dropdownField: self, onSelect: onSelectItem, defaultValue: defaultValue)
    }

    func loadDate(_ date: Date = Date()) {
        self.inputView = DatePicker(dropdownField: self, inputDate: date)
    }
}
