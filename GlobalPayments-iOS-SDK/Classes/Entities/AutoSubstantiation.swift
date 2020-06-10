import Foundation

@objcMembers public class AutoSubstantiation: NSObject {
    private var amounts: [String: Decimal]

    public var clinicSubTotal: Decimal {
        get {
            return amounts["SUBTOTAL_CLINIC_OR_OTHER_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_CLINIC_OR_OTHER_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount + newValue
        }
    }

    public var copaySubTotal: Decimal {
        get {
            return amounts["SUBTOTAL_COPAY_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_COPAY_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount + newValue
        }
    }

    public var dentalSubTotal: Decimal {
        get {
            return amounts["SUBTOTAL_DENTAL_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_DENTAL_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount + newValue
        }
    }

    public var merchantVerificationValue: String = .empty

    public var prescriptionSubTotal: Decimal {
        get {
            return amounts["SUBTOTAL_PRESCRIPTION_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_PRESCRIPTION_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount + newValue
        }
    }

    public var realTimeSubstantiation: Bool = false

    public var totalHealthcareAmount: Decimal {
        get {
            return amounts["TOTAL_HEALTHCARE_AMT"] ?? .zero
        }
    }

    public var visionSubTotal: Decimal {
        get {
            return amounts["SUBTOTAL_VISION__OPTICAL_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_VISION__OPTICAL_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount + newValue
        }
    }

    public required override init() {
        self.amounts = [
            "TOTAL_HEALTHCARE_AMT": 0,
            "SUBTOTAL_PRESCRIPTION_AMT": 0,
            "SUBTOTAL_VISION__OPTICAL_AMT": 0,
            "SUBTOTAL_CLINIC_OR_OTHER_AMT": 0,
            "SUBTOTAL_DENTAL_AMT": 0,
            "SUBTOTAL_COPAY_AMT": 0
        ]
    }
}
