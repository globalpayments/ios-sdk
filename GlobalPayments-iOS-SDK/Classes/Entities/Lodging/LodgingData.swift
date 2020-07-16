import Foundation

public class LodgingData: NSObject {
    public var checkInDate: Date?
    public var checkOutDate: Date?
    public var extraCharges: [ExtraChargeType: Decimal]
    public var folioNumber: String?
    public var rate: Decimal?
    public var stayDuration: Int?
    public var prestigiousPropertyLimit: PrestigiousPropertyLimit?
    public var noShow: Bool?
    public var advancedDepositType: AdvancedDepositType?
    public var lodgingDataEdit: String?
    public var preferredCustomer: Bool?
    public var extraChargeAmount: Decimal? {
        get {
            return extraCharges.values.reduce(.zero) { $0 + $1 }
        }
    }

    public required init(extraChargeType: ExtraChargeType,
                         amount: Decimal = .zero) {

        self.extraCharges = [ExtraChargeType: Decimal]()

        if !extraCharges.keys.contains(extraChargeType) {
            extraCharges[extraChargeType] = .zero
        }
        if let value = extraCharges[extraChargeType] {
            extraCharges[extraChargeType] = value + amount
        }
    }
}
