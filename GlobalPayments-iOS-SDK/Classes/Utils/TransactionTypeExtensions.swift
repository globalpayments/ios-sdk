import Foundation

extension TransactionType: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}
