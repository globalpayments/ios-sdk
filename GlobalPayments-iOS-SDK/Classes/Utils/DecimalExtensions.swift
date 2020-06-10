import Foundation

extension Decimal {

    static func sum(_ lhs: Decimal?, _ rhs: Decimal?) -> Decimal {
        return (lhs ?? .zero) + (rhs ?? .zero)
    }
}
