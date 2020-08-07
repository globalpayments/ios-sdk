#ifndef ReportType_h
#define ReportType_h

/// Indicates Report Type
typedef NS_OPTIONS(NSInteger, ReportType) {
    /// Indicates a FindTransactions report.
    ReportTypeFindTransactions  = 1 << 0,
    /// Indicates an Activity report.
    ReportTypeActivity          = 1 << 1,
    /// Indicates a BatchDetail report.
    ReportTypeBatchDetail       = 1 << 2,
    /// Indicates a BatchHistory report.
    ReportTypeBatchHistory      = 1 << 3,
    /// Indicates a BatchSummary report.
    ReportTypeBatchSummary      = 1 << 4,
    /// Indicates an OpenAuths report.
    ReportTypeOpenAuths         = 1 << 5,
    /// Indicates a Search report.
    ReportTypeSearch            = 1 << 6,
    /// Indicates a TransactionDetail report.
    ReportTypeTransactionDetail = 1 << 7,
    /// Indicates a deposit report
    ReportTypeFindDeposits      = 1 << 8,
    /// Indicates a dispute report
    ReportTypeFindDisputes      = 1 << 9
};

#endif /* ReportType_h */
