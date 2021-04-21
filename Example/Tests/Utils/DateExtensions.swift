import Foundation

extension Date {

    var currentMonth: Int {
        Calendar.current.component(.month, from: self)
    }

    var currentYear: Int {
        Calendar.current.component(.year, from: self)
    }

    var currentDay: Int {
        Calendar.current.component(.day, from: self)
    }

    func addYears(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: value, to: self)!
    }

    func addMonths(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: value, to: self)!
    }

    func addDays(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: value, to: self)!
    }
}
