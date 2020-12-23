import UIKit

struct TransactionsBuilder {

    static func build() -> UIViewController {
        TransactionsViewController.instantiate()
    }
}
