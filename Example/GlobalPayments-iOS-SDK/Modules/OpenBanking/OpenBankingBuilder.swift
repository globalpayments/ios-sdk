import UIKit

struct OpenBankingBuilder {

    static func build() -> UIViewController {
        let module = OpenBankingViewController.instantiate()
        return module
    }
}
