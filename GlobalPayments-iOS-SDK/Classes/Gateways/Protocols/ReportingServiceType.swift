import Foundation

protocol ReportingServiceType {
    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?, Error?) -> Void)?)
}
