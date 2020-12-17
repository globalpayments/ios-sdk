import UIKit

enum NavigationItems {

    case cancel(Any, Selector)

    var button: UIBarButtonItem {
        switch self {
        case .cancel(let target, let selector):
            let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: selector)
            button.style = .done
            return button
        }
    }
}
