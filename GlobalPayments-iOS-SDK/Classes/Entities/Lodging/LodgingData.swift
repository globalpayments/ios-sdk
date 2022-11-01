import Foundation

public class LodgingData: NSObject {
    public var checkInDate: Date?
    public var checkOutDate: Date?
    public var extraCharges: [ExtraChargeType: NSDecimalNumber]
    public var folioNumber: String?
    public var rate: NSDecimalNumber?
    public var stayDuration: Int?
    public var prestigiousPropertyLimit: PrestigiousPropertyLimit?
    public var noShow: Bool?
    public var advancedDepositType: AdvancedDepositType?
    public var lodgingDataEdit: String?
    public var preferredCustomer: Bool?
    public var bookingReference: String?
    public var items: [LodgingItem]?
    public var extraChargeAmount: NSDecimalNumber? {
        return extraCharges.values.reduce(.zero) { $0?.adding($1) }
    }

    public required init(extraChargeType: ExtraChargeType,
                         amount: NSDecimalNumber = .zero) {

        self.extraCharges = [ExtraChargeType: NSDecimalNumber]()

        if !extraCharges.keys.contains(extraChargeType) {
            extraCharges[extraChargeType] = .zero
        }
        if let value = extraCharges[extraChargeType] {
            extraCharges[extraChargeType] = value.adding(amount)
        }
    }
    
    public override init() {
        self.extraCharges = [ExtraChargeType: NSDecimalNumber]()
    }
}
