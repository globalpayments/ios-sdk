import UIKit
import GlobalPayments_iOS_SDK

final class DocumentTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: SelectableLabel!

    func setup(viewModel: DisputeDocument) {
        titleLabel.text = viewModel.type?.mapped(for: .gpApi)
        descriptionLabel.text = viewModel.id
    }
}
