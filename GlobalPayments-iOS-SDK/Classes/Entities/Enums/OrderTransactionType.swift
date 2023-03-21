import Foundation

public enum OrderTransactionType: String, Mappable, CaseIterable {
    case goodsServicePurchase = "GOODS_SERVICE_PURCHASE"
    case checkAcceptance = "CHECK_ACCEPTANCE"
    case accountFunding = "ACCOUNT_FUNDING"
    case quasiCashTransaction = "QUASI_CASH_TRANSACTION"
    case prepaidActivationAndLoad = "PREPAID_ACTIVATION_AND_LOAD"

    public init?(value: String?) {
        guard let value = value,
              let transactionType = OrderTransactionType(rawValue: value) else { return nil }
        self = transactionType
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
