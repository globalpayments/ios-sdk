import UIKit
import GlobalPayments_iOS_SDK

final class DisputeDocumentTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet private weak var documentImageView: UIImageView!
    @IBOutlet private weak var documentLabel: UILabel!

    func setup(viewModel: DocumentInfo) {
        documentLabel.text = viewModel.type.mapped(for: .gpApi)
        if let imageData = viewModel.b64Content, let image = UIImage(data: imageData) {
            documentImageView.image = image
        }
    }
}
