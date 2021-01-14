import Foundation

extension String {

    func format(_ format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
