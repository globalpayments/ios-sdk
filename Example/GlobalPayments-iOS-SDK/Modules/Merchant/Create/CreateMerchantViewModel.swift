import Foundation
import GlobalPayments_iOS_SDK

protocol CreateMerchantViewInput: AnyObject {
    func setUser(_ user: UserPersonalData)
    func setStatistics(_ statistics: PaymentStatistics)
    func setProducts(_ products: [Product])
    func createMerchant()
}

protocol CreateMerchantViewOutput: AnyObject{
    func showErrorView(error: Error?)
    func showUser(_ user: User)
}

final class CreateMerchantViewModel: CreateMerchantViewInput {
    
    private var merchantData: UserPersonalData?
    private var statistics: PaymentStatistics?
    private var products: [Product]?
    
    weak var view: CreateMerchantViewOutput?
    
    func setUser(_ user: UserPersonalData) {
        self.merchantData = user
    }
    
    func setStatistics(_ statistics: PaymentStatistics) {
        self.statistics = statistics
    }
    
    func setProducts(_ products: [Product]) {
        self.products = products
    }
    
    func createMerchant() {
        guard let merchantData = merchantData, let statistics = statistics, let products = products else { return }
        merchantData.notificationStatusUrl = "https://www.example.com/notifications/status"
        PayFacService.createMerchant()
            .withUserPersonalData(merchantData)
            .withDescription("Merchant Business Description")
            .withProductData(products)
            .withPaymentStatistics(statistics)
            .withPersonsData(getPersonList())
            .execute(completion: showOutput)
    }
    
    private func showOutput(user: User?, error: Error?) {
        UI {
            guard let user = user else {
                self.view?.showErrorView(error: error)
                return
            }
            self.view?.showUser(user)
        }
    }
    
    private func getPersonList(_ type: String? = nil) -> [Person] {
        var persons = [Person]()
        
        let person = Person()
        person.functions = .APPLICANT
        person.firstName = "James \(type ?? "")"
        person.middleName = "Mason \(type ?? "")"
        person.lastName = "Doe " + " " + "\(type ?? "")"
        person.email = "uniqueemail@address.com"
        person.dateOfBirth = "1982-02-23"
        person.nationalIdReference = "123456789"
        person.jobTitle = "CEO";
        person.equityPercentage = "25";
        person.address = Address();
        person.address?.streetAddress1 = "1 Business Address"
        person.address?.streetAddress2 = "Suite 2"
        person.address?.streetAddress3 = "1234"
        person.address?.city = "Atlanta"
        person.address?.state = "GA"
        person.address?.postalCode = "30346"
        person.address?.country = "US"
        
        let phoneNumber = PhoneNumber()
        phoneNumber.countryCode = "01"
        phoneNumber.number = "8008675309"
        
        person.homePhone = phoneNumber
        person.workPhone = phoneNumber
        
        persons.append(person)
        
        return persons
    }
}
