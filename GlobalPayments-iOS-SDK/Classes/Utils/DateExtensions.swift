import Foundation

extension Date {

    static var tomorrow: Date {
        return Date().dayAfter
    }
    private var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    private var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
}
