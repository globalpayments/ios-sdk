import Foundation

extension String {

    static let empty: String = ""

    func localized(tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = .empty, comment: String? = nil) -> String {
        NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: comment ?? "Lozalized string: \(self)")
    }
}
