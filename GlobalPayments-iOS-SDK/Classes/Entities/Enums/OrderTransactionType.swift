import Foundation

@objc public enum OrderTransactionType: Int {
    case goodsServicePurchase
    case checkAcceptance
    case accountFunding
    case quasiCashTransaction
    case prepaidActivationAndLoad
}
