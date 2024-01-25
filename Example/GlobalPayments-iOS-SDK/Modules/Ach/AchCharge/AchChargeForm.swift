import Foundation
import GlobalPayments_iOS_SDK

struct AchChargeForm {
    var amount: NSDecimalNumber = 0
    var currency: String = ""
    var bankDetails = AchBankDetailsForm()
    var customerDetails = AchCustomerDetailsForm()
    var billingAddress = AchBillingAddressForm()
}

struct AchBankDetailsForm {
    var accountHolderName: String = ""
    var accountType: String = ""
    var secCode: String = ""
    var routingNumber: String = ""
    var accountNumber: String = ""
}

struct AchCustomerDetailsForm {
    var firstName: String = ""
    var lastName: String = ""
    var birthDate: String = ""
    var mobilePhone: String = ""
    var homePhone: String = ""
}

struct AchBillingAddressForm {
    var line1: String = ""
    var line2: String = ""
    var city: String = ""
    var state: String = ""
    var postalCode: String = ""
    var country: String = ""
}
