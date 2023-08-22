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
    
    func startDayTime() -> Date{
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let startOfDate = calendar.startOfDay(for: self)
        return startOfDate
    }
    
    func convertToLocalTime(fromTimeZone timeZoneAbbreviation: String) -> Date {
        if let timeZone = TimeZone(abbreviation: timeZoneAbbreviation) {
            let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
            let localOffeset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))
            
            return self.addingTimeInterval(targetOffset - localOffeset)
        }
        
        return Date()
    }

    func format(_ format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
