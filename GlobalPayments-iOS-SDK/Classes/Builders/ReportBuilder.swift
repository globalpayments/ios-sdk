import Foundation

@objcMembers public class ReportBuilder<TResult>: BaseBuilder<TResult> {
    var reportType: ReportType
    var timeZoneConversion: TimeZoneConversion?

    public init(reportType: ReportType) {
        self.reportType = reportType
    }

    public override func execute(configName: String = "default",
                                 completion: ((TResult?, Error?) -> Void)?) {
        super.execute(configName: configName, completion: nil)
        do {
            let client = try ServicesContainer.shared.reportingClient(configName: configName)
            client.processReport(builder: self, completion: completion)
        } catch {
            completion?(nil, error)
        }
    }
}
