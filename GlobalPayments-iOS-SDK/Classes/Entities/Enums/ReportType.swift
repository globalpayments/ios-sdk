import Foundation

/// Indicates the transaction type.
public struct ReportType: OptionSet, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    /// Indicates a FindTransactions report.
    public static let findTransactions                = ReportType(rawValue: 1 << 0)
    /// Indicates an Activity report.
    public static let activity                        = ReportType(rawValue: 1 << 1)
    /// Indicates a BatchDetail report.
    public static let batchDetail                     = ReportType(rawValue: 1 << 2)
    /// Indicates a BatchHistory report.
    public static let batchHistory                    = ReportType(rawValue: 1 << 3)
    /// Indicates a BatchSummary report.
    public static let batchSummary                    = ReportType(rawValue: 1 << 4)
    /// Indicates an OpenAuths report.
    public static let openAuths                       = ReportType(rawValue: 1 << 5)
    /// Indicates a Search report.
    public static let search                          = ReportType(rawValue: 1 << 6)
    /// Indicates a TransactionDetail report.
    public static let transactionDetail               = ReportType(rawValue: 1 << 7)
    /// Indicates a deposits report
    public static let findDeposits                    = ReportType(rawValue: 1 << 8)
    /// Indicates a deposit report
    public static let depositDetail                   = ReportType(rawValue: 1 << 9)
    /// Indicates a disputes report
    public static let findDisputes                    = ReportType(rawValue: 1 << 10)
    /// Indicates a disputes report
    public static let findSettlementDisputes          = ReportType(rawValue: 1 << 11)
    /// Indicates a dispute report
    public static let disputeDetail                   = ReportType(rawValue: 1 << 12)
    /// Indicates a dispute report
    public static let acceptDispute                   = ReportType(rawValue: 1 << 13)
    /// Indicates a dispute report
    public static let challangeDispute                = ReportType(rawValue: 1 << 14)
    /// Get a Document associated with a Dispute
    public static let disputeDocument                 = ReportType(rawValue: 1 << 15)
    /// Indicates a SettlementFindTransactions report.
    public static let findSettlementTransactions      = ReportType(rawValue: 1 << 16)
    /// Indicates a Settlement Dispute Details report.
    public static let settlementDisputeDetail         = ReportType(rawValue: 1 << 17)
    /// Indicates paged Transactions report
    public static let findTransactionsPaged           = ReportType(rawValue: 1 << 18)
    /// Indicates paged Transactions report
    public static let findSettlementTransactionsPaged = ReportType(rawValue: 1 << 19)
    /// Indicates paged Deposit report
    public static let findDepositsPaged               = ReportType(rawValue: 1 << 20)
    /// Indicates paged Dispute report
    public static let findDisputesPaged               = ReportType(rawValue: 1 << 21)
    /// Indicates paged Settlement Dispute report
    public static let findSettlementDisputesPaged     = ReportType(rawValue: 1 << 22)
    /// Indicates a Stored Payment Method details report
    public static let storedPaymentMethodDetail       = ReportType(rawValue: 1 << 23)
    /// Indicates a Stored Payment Methods report paged
    public static let findStoredPaymentMethodsPaged   = ReportType(rawValue: 1 << 24)
    /// Indcates an action details report
    public static let actionDetail                    = ReportType(rawValue: 1 << 25)
    /// Indicates an actions report paged
    public static let findActionsPaged                = ReportType(rawValue: 1 << 26)
    /// Indicates a Dispute Document Details report.
    public static let documentDisputeDetail           = ReportType(rawValue: 1 << 27)
    ///
    public static let findMerchantsPaged              = ReportType(rawValue: 1 << 28)
}
