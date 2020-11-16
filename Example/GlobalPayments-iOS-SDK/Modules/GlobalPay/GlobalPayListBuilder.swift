import UIKit

struct GlobalPayListBuilder {

    static func build() -> UIViewController {
        GlobalPayViewController.instantiate()
    }
}
