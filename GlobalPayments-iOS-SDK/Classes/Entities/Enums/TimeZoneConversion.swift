import Foundation

/// Indicates how timezones should be handled.
@objc public enum TimeZoneConversion: Int {
    /// Indicates time is in coordinated universal time (UTC).
    case utc
    /// Indicates the merchant is responsible for timezone conversions.
    case merchant
    /// Indicates the datacenter, gateway, or processor is responsible for timezone conversions.
    case datacenter
}
