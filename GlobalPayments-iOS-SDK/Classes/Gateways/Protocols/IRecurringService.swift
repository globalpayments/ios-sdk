import Foundation

@objc public protocol IRecurringService {
    var supportsRetrieval: Bool { get }

    func processRecurring(builder: RecurringBuilder) -> Any?
}
