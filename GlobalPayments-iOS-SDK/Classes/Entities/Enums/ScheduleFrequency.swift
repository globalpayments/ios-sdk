import Foundation

/// Indicates the frequency of a recurring schedule.
@objcMembers public class ScheduleFrequency: NSObject {
    /// Indicates a schedule should process payments weekly.
    public static let weekly: String = "Weekly"
    /// Indicates a schedule should process payments bi-weekly (every other week).
    public static let biWeekly: String = "Bi-Weekly"
    /// Indicates a schedule should process payments bi-monthly (twice a month).
    public static let biMonthly: String = "Bi-Monthly"
    /// Indicates a schedule should process payments semi-monthly (every other month).
    public static let semiMonthly: String = "Semi-Monthly"
    /// Indicates a schedule should process payments monthly.
    public static let monthly: String = "Monthly"
    /// Indicates a schedule should process payments quarterly.
    public static let quarterly: String = "Quarterly"
    /// Indicates a schedule should process payments semi-annually (twice a year).
    public static let semiAnnually: String = "Semi-Annually"
    /// Indicates a schedule should process payments annually.
    public static let annually: String = "Annually"
}
