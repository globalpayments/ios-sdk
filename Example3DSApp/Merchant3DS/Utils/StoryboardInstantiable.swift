import UIKit

protocol StoryboardInstantiable {
    static var storyboardName: String { get }
}

extension StoryboardInstantiable {

    static func instantiate() -> Self {
        guard let controller = storyBoard.instantiateViewController(withIdentifier: identifier) as? Self else {
            fatalError("Could not instantiate \(self) from storyboard file.")
        }
        return controller
    }

    private static var identifier: String {
        return String(describing: self)
    }

    private static var storyBoard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
}
