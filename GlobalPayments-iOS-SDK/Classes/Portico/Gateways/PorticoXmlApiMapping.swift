//
//  PorticoXmlApiMapping.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Ranu Dhurandhar on 12/03/26.
//

import Foundation


// MARK: - PorticoXmlResponseParser Mapping

public struct PorticoXmlApiMapping {
    // Map a PorticoXmlResponseParser transaction to Transaction
     static func mapTransaction(_ parser: PorticoXmlResponseParser, _ transaction: Transaction) {
        // Map basic response fields
        transaction.gatewayResponseCode = parser.gatewayResponseCode
        transaction.gatewayResponseMessage = parser.gatewayResponseMessage
        transaction.authorizedAmount = parser.transaction?.authorizedAmount ?? NSDecimalNumber.zero
        transaction.availableBalance = parser.transaction?.availableBalance ?? NSDecimalNumber.zero
        transaction.avsResponseCode = parser.transaction?.avsResponseCode ?? ""
        transaction.avsResponseMessage = parser.transaction?.avsResponseMessage ?? ""
        transaction.balanceAmount = parser.transaction?.balanceAmount ?? NSDecimalNumber.zero
        transaction.cardType = parser.transaction?.cardType ?? ""
        transaction.cardLast4 = parser.transaction?.cardLast4 ?? ""
        transaction.cavvResponseCode = parser.transaction?.cavvResponseCode ?? ""
        transaction.commercialIndicator = parser.transaction?.commercialIndicator ?? ""
        transaction.cvnResponseCode = parser.transaction?.cvnResponseCode ?? ""
        transaction.cvnResponseMessage = parser.transaction?.cvnResponseMessage ?? ""
        transaction.emvIssuerResponse = parser.transaction?.emvIssuerResponse ?? ""
        transaction.pointsBalanceAmount = parser.transaction?.pointsBalanceAmount ?? NSDecimalNumber.zero
        transaction.recurringDataCode = parser.transaction?.recurringDataCode ?? ""
        transaction.referenceNumber = parser.transaction?.referenceNumber ?? ""
        transaction.responseCode = parser.transaction?.responseCode ?? transaction.responseCode
        transaction.responseMessage = parser.transaction?.responseMessage ?? transaction.responseMessage
        transaction.transactionDescriptor = parser.transaction?.transactionDescriptor ?? ""
        transaction.token = parser.transaction?.token ?? ""
        transaction.isSurchargeable = parser.transaction?.isSurchargeable ?? ""
        transaction.surchargeAmtInfo = parser.transaction?.surchargeAmtInfo ?? ""
        transaction.bankRespCode = parser.transaction?.bankRespCode ?? ""
        transaction.hostResponseDate = parser.transaction?.hostResponseDate
        transaction.transactionReference = parser.transaction?.transactionReference
        transaction.giftCard = parser.transaction?.giftCard
        transaction.duplicateData = parser.transaction?.duplicateData
        transaction.serviceName = parser.transaction?.serviceName ?? ""
    }

    // Map a PorticoXmlResponseParser singleReport to PorticoTransactionSummary
     static func mapTransactionSummary(_ parser: PorticoXmlResponseParser) -> [TransactionSummary] {
        return parser.listReport ?? (parser.singleReport != nil ? [parser.singleReport!] : [])
    }
}
