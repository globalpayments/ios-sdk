//
//  PorticoTransactionType.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Yashwant Patil on 23/03/26.
//

import Foundation

public enum PorticoTransactionTypes: String, CaseIterable {
    
    case creditSale = "CreditSale"
    case creditAuth = "CreditAuth"
    case creditReturn = "CreditReturn"
    case creditReversal = "CreditReversal"
    case creditCPC = "CreditCPC"
    case creditCPCEdit = "CreditCPCEdit"
    case creditAddToBatch = "CreditAddToBatch"
    case creditTxnEdit = "CreditTxnEdit"
    case chipCardDecline = "ChipCardDecline"
    case creditAccountVerify = "CreditAccountVerify"
    case giftCardSale = "GiftCardSale"
    case creditVoid = "CreditVoid"
    
    public init?(value: String?) {
        guard let value = value,
              let status = PorticoTransactionTypes(rawValue: value) else { return nil }
        self = status
    }
    
    // Check if string exists in enum
    public static func contains(_ value: String) -> Bool {
        return PorticoTransactionTypes.allCases.contains { $0.rawValue == value }
    }
}
