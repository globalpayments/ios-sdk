import UIKit

class View: UIView {
    
    init() {
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder){
        fatalError("Custom class: View init(coder:) has not been implemented")
    }
}
