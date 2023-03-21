import Foundation
import UIKit

extension UITextField {

    func loadDropDownData(_ data: [String], onSelectItem: ((String) -> Void)? = nil) {
        self.inputView = DropDown(pickerData: data, dropdownField: self, onSelect: onSelectItem)
    }

    func loadDate(_ date: Date = Date()) {
        self.inputView = DatePicker(dropdownField: self, inputDate: date)
    }
}
