import Foundation
import GlobalPayments_iOS_SDK

protocol MerchantDataViewInput: AnyObject {
    func setAddress(_ address: Address, path: MerchantAddressPath)
    func setMailingAndUserAddress(_ user: UserPersonalData)
}

protocol MerchantDataViewOutput: AnyObject {
    func setShippingAddress(_ value: String)
    func setBusinessAddress(_ value: String)
    func onSubmitCreateMerchant(_ user: UserPersonalData)
}

final class MerchantDataViewModel: MerchantDataViewInput {
    
    weak var view: MerchantDataViewOutput?
    
    private var shippingAddress: Address?
    private var businessAddress: Address?
    
    func setAddress(_ address: Address, path: MerchantAddressPath) {
        let value = "\(address.streetAddress1 ?? "")|\(address.city ?? "")|\(address.state ?? "")"
        switch path {
        case .business:
            businessAddress = address
            view?.setBusinessAddress(value)
        case .shipping:
            shippingAddress = address
            view?.setShippingAddress(value)
        }
    }
    
    func setMailingAndUserAddress(_ user: UserPersonalData) {
        user.userAddress = businessAddress
        user.mailingAddress = shippingAddress
        view?.onSubmitCreateMerchant(user)
    }
}
