import Foundation

protocol ReportingService {
    func processReport<T: AnyObject>(builder: ReportBuilder<T>,
                                     completion: ((T?) -> Void)?)
}
