import Foundation

public protocol Balanceable {
    func balanceInquiry(inquiry: InquiryType) -> AuthorizationBuilder
}
