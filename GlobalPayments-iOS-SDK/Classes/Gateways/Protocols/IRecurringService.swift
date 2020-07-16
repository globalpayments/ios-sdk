import Foundation

public protocol IRecurringService {
    var supportsRetrieval: Bool { get }
    var supportsUpdatePaymentDetails: Bool { get }
    func processRecurring<T>(builder: RecurringBuilder<T>,
                             completion: ((T) -> Void)?)
}
