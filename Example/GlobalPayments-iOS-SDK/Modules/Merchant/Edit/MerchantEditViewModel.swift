import Foundation
import GlobalPayments_iOS_SDK

final class MerchantEditViewModel: BaseViewModel {
    
    var setBillingLabel: Dynamic<String> = Dynamic("")
    var showAddressScreen: Dynamic<Void> = Dynamic(())
    
    private var cardNumber: String = ""
    private var cardExpiration: String = ""
    private var cvv: String = ""
    private var cardHolderName: String = ""
    private var businessAddress: Address?
    
    private var fromTimeCreated: String = ""
    private var toTimeCreated: String = ""

    func editMerchant() {
        showLoading.executer()
        
        let dateExpSplit = cardExpiration.split(separator: "/")
        let month = Int(dateExpSplit[0]) ?? 0
        let year = Int(dateExpSplit[1]) ?? 0
        
        let creditCardInformation = CreditCardData()
        creditCardInformation.number = cardNumber
        creditCardInformation.expMonth = month
        creditCardInformation.expYear = year
        creditCardInformation.cvn = cvv
        creditCardInformation.cardHolderName = cardHolderName
        
        let userReportService = ReportingService.findMerchants(1, pageSize: 10)
        userReportService.orderBy(transactionSortProperty: .timeCreated)
            .withMerchantStatus(.ACTIVE)
            .execute(completion: showOutput)
    }
    
    func setMockData() {
        let address = createEmptyAddress()
        setAddress(address)
    }
    
    func setAddress(_ address: Address) {
        let value = "\(address.streetAddress1 ?? "")"
        businessAddress = address
        setBillingLabel.value = value
    }

    private func showOutput(merchantSummary: PagedResult<MerchantSummary>?, error: Error?) {
        UI {
            guard let merchantSummary = merchantSummary else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            
            if merchantSummary.results.count > 0, let data = merchantSummary.results.first {
                self.showDataResponse.value = (.success, data)
            } else {
                self.showDataResponse.value = (.error, GatewayException(message: "No Results to MerchantSummary"))
            }
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .cardNumber:
            cardNumber = value
        case .cardCvv:
            cvv = value
        case .cardExpiryDate:
            cardExpiration = value
        case .cardHolderName:
            cardHolderName = value
        case .fromTimeCreated:
            fromTimeCreated = value
        case .toTimeCreated:
            toTimeCreated = value
        default:
            break
        }
    }
    
    func onBillingAddressPressed() {
        showAddressScreen.executer()
    }
    
    private func createEmptyAddress() -> Address {
        let address = Address()
        address.streetAddress1 = "Apartment 852"
        address.streetAddress2 = "Complex 741"
        address.streetAddress3 = "no"
        address.city = "Birmingham"
        address.postalCode = "50001"
        address.countryCode = "US"
        address.state = "IL"
        return address
    }
}
