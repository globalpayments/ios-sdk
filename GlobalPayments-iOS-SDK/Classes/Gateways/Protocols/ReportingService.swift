import Foundation

protocol ReportingService {
    func processReport<T>(builder: ReportBuilder<T>,
                                     completion: ((T?) -> Void)?)
}
