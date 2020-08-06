import Foundation

public class Schedule: RecurringEntity<Schedule> {
    /// The schedule's amount
    public var amount: NSDecimalNumber?
    /// The date/time the schedule was cancelled.
    public var cancellationDate: Date?
    /// The schedule's currency.
    public var currency: String?
    /// The identifier of the customer associated with the schedule.
    public var customerKey: String?
    /// The description of the schedule.
    public var scheduleDescription: String?
    /// The device ID associated with a schedule's transactions.
    public var deviceId: Int?
    /// Indicates if email notifications should be sent.
    public var emailNotification: Bool?
    /// Indicates when email notifications should be sent.
    public var emailReceipt: EmailReceipt = .never
    /// The end date of a schedule, if any.
    public var endDate: Date?
    /// The schedule's frequency.
    public var frequency: ScheduleFrequency?
    /// Indicates if the schedule has started processing.
    public var hasStarted: Bool?
    /// The invoice number associated with the schedule.
    public var invoiceNumber: String?
    /// The schedule's name.
    public var name: String?
    /// The date/time when the schedule should process next.
    public var nextProcessingDate: Date?
    /// The number of payments made to date on the schedule.
    public var numberOfPayments: Int?
    /// The purchase order (PO) number associated with the schedule.
    public var poNumber: String?
    /// The identifier of the payment method associated with the schedule.
    public var paymentKey: String?
    /// Indicates when in the month a recurring schedule should run.
    public var paymentSchedule: PaymentSchedule?
    /// The number of times a failed schedule payment should be reprocessed.
    public var reprocessingCount: Int?
    /// The start date of a schedule.
    public var startDate: Date?
    /// The schedule's status.
    public var status: String?
    /// The schedule's tax amount.
    public var taxAmount: NSDecimalNumber?

    public required init(customerKey: String? = nil, paymentKey: String? = nil) {
        self.customerKey = customerKey
        self.paymentKey = paymentKey
    }

    /// The total amount for the schedule (`amount` and `taxAmount`).
    public func getTotalAmount() -> NSDecimalNumber? {
        return .sum(amount, taxAmount)
    }

    /// Sets the schedule's amount.
    /// - Parameter amount: The amount
    /// - Returns: Schedule
    public func withAmount(_ amount: NSDecimalNumber?) -> Schedule {
        self.amount = amount
        return self
    }

    /// Sets the schedule's currency.
    /// - Parameter currency: The currency
    /// - Returns: Schedule
    public func withCurrency(_ currency: String?) -> Schedule {
        self.currency = currency
        return self
    }

    /// Sets the schedule's customer.
    /// - Parameter customerKey: The customer's key
    /// - Returns: Schedule
    public func withCustomerKey(_ customerKey: String?) -> Schedule {
        self.customerKey = customerKey
        return self
    }

    /// Sets the schedule's description..
    /// - Parameter description: The description
    /// - Returns: Schedule
    public func withDescription(_ description: String?) -> Schedule {
        self.scheduleDescription = description
        return self
    }

    /// Sets the schedule's device ID.
    /// - Parameter deviceId: The device ID
    /// - Returns: Schedule
    public func withDeviceId(_ deviceId: Int?) -> Schedule {
        self.deviceId = deviceId
        return self
    }

    /// Sets whether the schedule should send email notifications.
    /// - Parameter EmailNotification: The email notification flag
    /// - Returns: Schedule
    public func withEmailNotification(_ emailNotification: Bool?) -> Schedule {
        self.emailNotification = emailNotification
        return self
    }

    /// Sets when the schedule should email receipts.
    /// - Parameter emailReceipt: When the schedule should email receipts
    /// - Returns: Schedule
    public func withEmailReceipt(_ emailReceipt: EmailReceipt) -> Schedule {
        self.emailReceipt = emailReceipt
        return self
    }

    /// Sets the schedule's end date.
    /// - Parameter endDate: The end date
    /// - Returns: Schedule
    public func withEndDate(_ endDate: Date?) -> Schedule {
        self.endDate = endDate
        return self
    }

    /// Sets the schedule's frequency.
    /// - Parameter frequency: The frequency
    /// - Returns: Schedule
    public func withFrequency(_ frequency: ScheduleFrequency?) -> Schedule {
        self.frequency = frequency
        return self
    }

    /// Sets the schedule's invoice number.
    /// - Parameter invoiceNumber: The invoice number
    /// - Returns: Schedule
    public func withInvoiceNumber(_ invoiceNumber: String) -> Schedule {
        self.invoiceNumber = invoiceNumber
        return self
    }

    /// Sets the schedule's name.
    /// - Parameter name: The name
    /// - Returns: Schedule
    public func withName(_ name: String?) -> Schedule {
        self.name = name
        return self
    }

    /// Sets the schedule's number of payments.
    /// - Parameter numberOfPayments: The number of payments
    /// - Returns: Schedule
    public func withNumberOfPayments(_ numberOfPayments: Int?) -> Schedule {
        self.numberOfPayments = numberOfPayments
        return self
    }

    /// Sets the schedule's purchase order (PO) number.
    /// - Parameter poNumber: The purchase order (PO) number
    /// - Returns: Schedule
    public func withPoNumber(_ poNumber: String?) -> Schedule {
        self.poNumber = poNumber
        return self
    }

    /// Sets the schedule's payment method.
    /// - Parameter paymentKey: The payment method's key
    /// - Returns: Schedule
    public func withPaymentKey(_ paymentKey: String?) -> Schedule {
        self.paymentKey = paymentKey
        return self
    }

    /// Sets the schedule's recurring schedule.
    /// - Parameter paymentSchedule: The recurring schedule
    /// - Returns: Schedule
    public func withPaymentSchedule(_ paymentSchedule: PaymentSchedule?) -> Schedule {
        self.paymentSchedule = paymentSchedule
        return self
    }

    /// Sets the schedule's reprocessing count.
    /// - Parameter reprocessingCount: The reprocessing count
    /// - Returns: Schedule
    public func withReprocessingCount(_ reprocessingCount: Int?) -> Schedule {
        self.reprocessingCount = reprocessingCount
        return self
    }

    /// Sets the schedule's start date.
    /// - Parameter startDate: The start date
    /// - Returns: Schedule
    public func withStartDate(_ startDate: Date?) -> Schedule {
        self.startDate = startDate
        return self
    }

    /// Sets the schedule's status.
    /// - Parameter status: The new status
    /// - Returns: Schedule
    public func withStatus(_ status: String?) -> Schedule {
        self.status = status
        return self
    }

    /// Sets the schedule's tax amount.
    /// - Parameter taxAmount: The tax amount
    /// - Returns: Schedule
    public func withTaxAmount(_ taxAmount: NSDecimalNumber?) -> Schedule {
        self.taxAmount = taxAmount
        return self
    }
}
