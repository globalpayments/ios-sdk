import Foundation

/// Indicates the transaction type.
public struct ReportType: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    /// Indicates a FindTransactions report.
    public static let findTransactions  = ReportType(rawValue: 1 << 0)
    /// Indicates an Activity report.
    public static let activity          = ReportType(rawValue: 1 << 1)
    /// Indicates a BatchDetail report.
    public static let batchDetail       = ReportType(rawValue: 1 << 2)
    /// Indicates a BatchHistory report.
    public static let batchHistory      = ReportType(rawValue: 1 << 3)
    /// Indicates a BatchSummary report.
    public static let batchSummary      = ReportType(rawValue: 1 << 4)
    /// Indicates an OpenAuths report.
    public static let openAuths         = ReportType(rawValue: 1 << 5)
    /// Indicates a Search report.
    public static let search            = ReportType(rawValue: 1 << 6)
    /// Indicates a TransactionDetail report.
    public static let transactionDetail = ReportType(rawValue: 1 << 7)
    /// Indicates a deposit report
    public static let findDepoits       = ReportType(rawValue: 1 << 8)
    /// Indicates a dispute report
    public static let findDisputes      = ReportType(rawValue: 1 << 9)
}
