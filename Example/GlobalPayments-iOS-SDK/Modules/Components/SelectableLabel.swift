import UIKit

final class SelectableLabel: UILabel {

    lazy var gestureRecognizer: UILongPressGestureRecognizer = {
        UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
    }()

    init() {
        super.init(frame: .zero)

        addGestureRecognizer()
    }

    deinit {
        removeGestureRecognizer(gestureRecognizer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        addGestureRecognizer()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        addGestureRecognizer()
    }

    private func addGestureRecognizer() {
        isUserInteractionEnabled = true
        addGestureRecognizer(gestureRecognizer)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    // MARK: - UIResponderStandardEditActions

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }

    // MARK: - Long-press Handler

    @objc private func handleLongPress(_ recognizer: UIGestureRecognizer) {
        if recognizer.state == .began,
           let recognizerView = recognizer.view,
           let recognizerSuperview = recognizerView.superview {
            recognizerView.becomeFirstResponder()
            UIMenuController.shared.setTargetRect(recognizerView.frame, in: recognizerSuperview)
            UIMenuController.shared.setMenuVisible(true, animated: true)
        }
    }
}
