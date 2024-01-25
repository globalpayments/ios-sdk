import Foundation

class AchChargeUseCase {
    
    lazy var form: AchChargeForm = AchChargeForm()

    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .amount:
            form.amount = NSDecimalNumber(string: value)
        case .accountHolderName:
            form.bankDetails.accountHolderName = value
        case .accountType:
            form.bankDetails.accountType = value
        case .secCode:
            form.bankDetails.secCode = value
        case .routingNumber:
            form.bankDetails.routingNumber = value
        case .accountNumber:
            form.bankDetails.accountNumber = value
        case .firstName:
            form.customerDetails.firstName = value
        case .lastName:
            form.customerDetails.lastName = value
        case .dateOfBirth:
            form.customerDetails.birthDate = value
        case .mobilePhone:
            form.customerDetails.mobilePhone = value
        case .homePhone:
            form.customerDetails.homePhone = value
        case .line1:
            form.billingAddress.line1 = value
        case .line2:
            form.billingAddress.line2 = value
        case .city:
            form.billingAddress.city = value
        case .state:
            form.billingAddress.state = value
        case .postalCode:
            form.billingAddress.postalCode = value
        case .country:
            form.billingAddress.country = value
        default:
            break
        }
    }
    
    func validateFields() -> Bool {
        guard form.amount.doubleValue > 0.0 else {
            return false
        }
        return true
    }
}
