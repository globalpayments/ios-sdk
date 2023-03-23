import Foundation

public class Person: NSObject {
    /// Describes the functions that a person can have in an organization.
    public var functions: PersonFunctions?
    /// Person's first name
    public var firstName: String?
    /// Middle's first name
    public var middleName: String?
    /// Person's last name
    public var lastName: String?
    /// Person's email address
    public var email: String?
    /// Person's date of birth
    public var dateOfBirth: String?
    /// The national id number or reference for the person for their nationality. For example for Americans this would
    /// be SSN, for Canadians it would be the SIN, for British it would be the NIN.
    public var nationalIdReference: String?
    /// The job title the person has.
    public var jobTitle: String?
    /// The equity percentage the person owns of the business that is applying to Global Payments for payment processing services.
    public var equityPercentage: String?
    /// Customer's address
    public var address: Address?
    /// Person's home phone number
    public var homePhone: PhoneNumber?
    /// Person's work phone number
    public var workPhone: PhoneNumber?
}
