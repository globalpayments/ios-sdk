import Foundation

extension String {

    static let empty: String = ""

    func localized(tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = .empty, comment: String? = nil) -> String {
        NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: comment ?? "Lozalized string: \(self)")
    }

    func formattedDate(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss ZZZZ") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)
    }
    
    func toInt() -> Int {
        return Int(self) ?? 0
    }
}
