import UIKit

enum NavigationItems {

    case cancel(Any, Selector)
    case settings(Any, Selector)

    var button: UIBarButtonItem {
        switch self {
        case .cancel(let target, let selector):
            let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: selector)
            button.style = .done
            return button
        case .settings(let target, let selector):
            return UIBarButtonItem(image: UIImage(named: "settings_icon"), style: .done, target: target, action: selector)
        }
    }
}
