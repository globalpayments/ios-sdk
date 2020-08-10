import Foundation

protocol IReportingService {
    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?, Error?) -> Void)?)
}
