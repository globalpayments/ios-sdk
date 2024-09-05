import Foundation

public protocol RecurringServiceType {
    var supportsRetrieval: Bool { get }
    var supportsUpdatePaymentDetails: Bool { get }
    func processRecurring<T>(builder: RecurringBuilder<T>,
                             completion: ((T?, Error?) -> Void)?)
}
