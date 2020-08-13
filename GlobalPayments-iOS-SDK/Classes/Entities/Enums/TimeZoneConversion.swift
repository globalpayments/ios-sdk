import Foundation

/// Indicates how timezones should be handled.
public enum TimeZoneConversion {
    /// Indicates time is in coordinated universal time (UTC).
    case utc
    /// Indicates the merchant is responsible for timezone conversions.
    case merchant
    /// Indicates the datacenter, gateway, or processor is responsible for timezone conversions.
    case datacenter
}
