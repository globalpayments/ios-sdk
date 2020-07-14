import Foundation

public class ReportBuilder<TResult: AnyObject>: BaseBuilder<TResult> {
    var reportType: ReportType
    var timeZoneConversion: TimeZoneConversion?

    public init(reportType: ReportType) {
        self.reportType = reportType
    }

    public override func execute(completion: ((TResult?) -> Void)?) {
        super.execute(completion: completion)
        let client = ServicesContainer.shared.getReportingService()
        client?.processReport(builder: self, completion: completion)
    }
}
