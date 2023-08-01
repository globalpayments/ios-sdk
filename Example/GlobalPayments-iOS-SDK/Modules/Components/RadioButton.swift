import UIKit

class RadioButton: UIControl {
    
    var unselectedBackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = unselectedBackgroundColor
        }
    }
    
    var borderColor: UIColor = .black {
        didSet {
            layer.borderColor = (isOn ? selectedColor : borderColor).cgColor
        }
    }
    
    var selectedColor: UIColor = .blue {
        didSet {
            checkedView.backgroundColor = selectedColor
            layer.borderColor = (isOn ? selectedColor : borderColor).cgColor
        }
    }
    
    var isOn: Bool = false {
        didSet {
            updateState()
        }
    }
    
    private let checkedView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(checkedView)
        layer.borderWidth = 1.2
        updateState()
        NSLayoutConstraint.activate([
            checkedView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkedView.centerXAnchor.constraint(equalTo: centerXAnchor),
            checkedView.widthAnchor.constraint(equalTo: widthAnchor, constant: -(self.bounds.height / 2)),
            checkedView.heightAnchor.constraint(equalTo: widthAnchor, constant: -(self.bounds.height / 2))
        ])
    }
    
    private func updateState() {
        backgroundColor = unselectedBackgroundColor
        checkedView.backgroundColor = selectedColor
        layer.borderColor = (isOn ? selectedColor : borderColor).cgColor
        checkedView.isHidden = !isOn
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        sendActions(for: .valueChanged)
        isOn.toggle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = (self.bounds.height) / 2
        checkedView.layer.cornerRadius = (self.bounds.height) / 4
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.inset(by: UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)).contains(point)
    }
}
