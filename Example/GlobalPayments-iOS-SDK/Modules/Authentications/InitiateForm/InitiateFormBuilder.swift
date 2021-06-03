import UIKit

enum FlowType {
    case initiate
    case full
}

struct InitiateFormBuilder {

    static func build(with delegate: InitiateFormDelegate, flowType: FlowType) -> UIViewController {
        let module = InitiateFormViewController.instantiate()
        module.delegate = delegate
        module.flowType = flowType

        return UINavigationController(rootViewController: module)
    }
}
