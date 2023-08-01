import Foundation
import GlobalPayments_iOS_SDK

protocol CustomerViewInput: AnyObject {
    func setCustomerData()
    func createCustomerData(_ form: CustomerForm)
}

protocol CustomerViewOutput: AnyObject {
    func showDefaultData(_ data: Customer)
    func sendCustomerData(_ data: Customer)
}

final class CustomerViewModel: CustomerViewInput {
    
    weak var view: CustomerViewOutput?
    private var customer: Customer?
    
    init(customer: Customer? = nil) {
        self.customer = customer
    }
    
    func setCustomerData() {
        if let customer = customer {
            view?.showDefaultData(customer)
        }
    }
    
    func createCustomerData(_ form: CustomerForm) {
        let customer = Customer()
        customer.firstName = form.firstName
        customer.lastName = form.lastName
        customer.email = form.email
        
        let phoneNumber = PhoneNumber()
        phoneNumber.countryCode = form.countryCode
        phoneNumber.number = form.numberPhone
        phoneNumber.areaCode = form.numberType
        customer.phoneNumber = phoneNumber
        
        let document = CustomerDocument()
        document.issuer = form.issuer
        document.reference = form.documentReference
        document.type = CustomerDocumentType(value: form.documentType)
        var documents: [CustomerDocument] = []
        documents.append(document)
        customer.documents = documents
        
        view?.sendCustomerData(customer)
    }
}

