import UIKit

struct UploadFileBuilder {

    static func build() -> UIViewController {
        let module = UploadFileViewController()
        module.viewModel = UploadFileViewModel()
        return module
    }
}
