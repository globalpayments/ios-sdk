import Foundation
import GlobalPayments_iOS_SDK

struct AchChargeForm {
    let amount: NSDecimalNumber
    let currency: String
    let bankDetails: AchBankDetailsForm
    let customerDetails: AchCustomerDetailsForm
    let billingAddress: AchBillingAddressForm
}

struct AchBankDetailsForm {
    let accountHolderName: String
    let accountType: String
    let secCode: String
    let routingNumber: String
    let accountNumber: String
}

struct AchCustomerDetailsForm {
    let firstName: String
    let lastName: String
    let birthDate: String
    let mobilePhone: String
    let homePhone: String
}

struct AchBillingAddressForm {
    let line1: String
    let line2: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
}
