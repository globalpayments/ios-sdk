import Foundation

@objcMembers public class ReportBuilder: BaseBuilder {
    var reportType: ReportType
    var timeZoneConversion: TimeZoneConversion?

    public init(reportType: ReportType) {
        self.reportType = reportType
    }

    public override func execute() -> Any? {
        super.execute()

        return nil
    }
}
