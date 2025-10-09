import Foundation

public class InstallmentData {
    
    //Indicates the installment payment plan program.
    public var program: String?
    
    //Indicates the mode of the Installment plan choosen
    public var mode: String?
    
    //Indicates the total number of payments to be made over the course of the installment payment plan.
    public var count: String?
    
    //Indicates the grace period before the first payment.
    public var gracePeriodCount: String?
    
    public init(program: String? = nil, mode: String? = nil, count: String? = nil, gracePeriodCount: String? = nil) {
        self.program = program
        self.mode = mode
        self.count = count
        self.gracePeriodCount = gracePeriodCount
    }
    
    init(json: JsonDoc) {
        self.program = json.getValue(key: "program")
        self.mode = json.getValue(key: "mode")
        self.count = json.getValue(key: "count")
        self.gracePeriodCount = json.getValue(key: "grace_period_count")
    }
}
