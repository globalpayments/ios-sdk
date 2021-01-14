import Foundation

public class AutoSubstantiation: NSObject {
    private var amounts: [String: NSDecimalNumber]

    public var clinicSubTotal: NSDecimalNumber {
        get {
            return amounts["SUBTOTAL_CLINIC_OR_OTHER_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_CLINIC_OR_OTHER_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount.adding(newValue)
        }
    }

    public var copaySubTotal: NSDecimalNumber {
        get {
            return amounts["SUBTOTAL_COPAY_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_COPAY_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount.adding(newValue)
        }
    }

    public var dentalSubTotal: NSDecimalNumber {
        get {
            return amounts["SUBTOTAL_DENTAL_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_DENTAL_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount.adding(newValue)
        }
    }

    public var merchantVerificationValue: String = .empty

    public var prescriptionSubTotal: NSDecimalNumber {
        get {
            return amounts["SUBTOTAL_PRESCRIPTION_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_PRESCRIPTION_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount.adding(newValue)
        }
    }

    public var realTimeSubstantiation: Bool = false

    public var totalHealthcareAmount: NSDecimalNumber {
        get {
            return amounts["TOTAL_HEALTHCARE_AMT"] ?? .zero
        }
    }

    public var visionSubTotal: NSDecimalNumber {
        get {
            return amounts["SUBTOTAL_VISION__OPTICAL_AMT"] ?? .zero
        }
        set {
            amounts["SUBTOTAL_VISION__OPTICAL_AMT"] = newValue
            amounts["TOTAL_HEALTHCARE_AMT"] = totalHealthcareAmount.adding(newValue)
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
