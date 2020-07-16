import Foundation

/// Indicates the frequency of a recurring schedule.
public enum ScheduleFrequency: String {
    /// Indicates a schedule should process payments weekly.
    case weekly = "Weekly"
    /// Indicates a schedule should process payments bi-weekly (every other week).
    case biWeekly = "Bi-Weekly"
    /// Indicates a schedule should process payments bi-monthly (twice a month).
    case biMonthly = "Bi-Monthly"
    /// Indicates a schedule should process payments semi-monthly (every other month).
    case semiMonthly = "Semi-Monthly"
    /// Indicates a schedule should process payments monthly.
    case monthly = "Monthly"
    /// Indicates a schedule should process payments quarterly.
    case quarterly = "Quarterly"
    /// Indicates a schedule should process payments semi-annually (twice a year).
    case semiAnnually = "Semi-Annually"
    /// Indicates a schedule should process payments annually.
    case annually = "Annually"
}
