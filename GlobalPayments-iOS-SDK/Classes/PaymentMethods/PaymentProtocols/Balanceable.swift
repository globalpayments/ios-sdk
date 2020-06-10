import Foundation

@objc public protocol Balanceable {
    func balanceInquiry(inquiry: InquiryType) -> AuthorizationBuilder
}
