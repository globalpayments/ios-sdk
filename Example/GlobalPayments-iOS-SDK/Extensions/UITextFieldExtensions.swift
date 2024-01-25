import Foundation
import UIKit

extension UITextField {

    func loadDropDownData(_ data: [String], onSelectItem: ((String) -> Void)? = nil, defaultValue: Int = 0) {
        self.inputView = DropDown(pickerData: data, dropdownField: self, onSelect: onSelectItem, defaultValue: defaultValue)
    }

    func loadDate(_ date: Date = Date(), format: String? = nil) {
        self.inputView = DatePicker(dropdownField: self, inputDate: date, format: format)
    }
    
    func roundedCorners(_ borderColor: UIColor){
        layer.cornerRadius = 4
        layer.masksToBounds = true
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = 1
    }
    
    func setPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        leftView = paddingView
        leftViewMode = .always
        rightView = paddingView
        rightViewMode = .always
    }
    
    func setRightPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
    
    func addDropArrow() {
        let downArrow = UIImageView(image: UIImage(named: "triangle.down"))
        downArrow.tintColor = .gray
        downArrow.contentMode = .scaleAspectFit
        downArrow.translatesAutoresizingMaskIntoConstraints = false
        downArrow.heightAnchor.constraint(equalToConstant: 10).isActive = true
        downArrow.widthAnchor.constraint(equalToConstant: 30).isActive = true
        rightView = downArrow
        rightViewMode = .always
    }
}
