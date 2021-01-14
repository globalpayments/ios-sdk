import UIKit

final class SelectableTableViewCell: UITableViewCell, CellIdentifiable {

    @IBOutlet private weak var titleLabel: UILabel!

    func setupTitle(_ title: String) {
        titleLabel.text = title
    }
}
