import UIKit

struct GlobalPayListBuilder: ModuleBuilder {

    static func build() -> UIViewController {
        GlobalPayViewController.instantiate()
    }
}
