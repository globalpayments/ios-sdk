//
//  PorticoDuplicateData.swift
//  Pods
//
//  Created by Ranu Dhurandhar on 19/02/26.
//

import Foundation

public class PorticoDuplicateData {
    var transactionId: String?
    var hostResponseDate: String?
    var clientTransactionId: String?
    var uniqueDeviceId: String?
    var globalTransactionId: String?
    var authorizationCode: String?
    var referenceNumber: String?
    var authorizedAmount: String?
    var cardType: String?
    var cardLast4: String?

    init(transactionId: String? = nil, hostResponseDate: String? = nil, clientTransactionId: String? = nil, uniqueDeviceId: String? = nil, globalTransactionId: String? = nil, authorizationCode: String? = nil, referenceNumber: String? = nil, authorizedAmount: String? = nil, cardType: String? = nil, cardLast4: String? = nil) {
        self.transactionId = transactionId
        self.hostResponseDate = hostResponseDate
        self.clientTransactionId = clientTransactionId
        self.uniqueDeviceId = uniqueDeviceId
        self.globalTransactionId = globalTransactionId
        self.authorizationCode = authorizationCode
        self.referenceNumber = referenceNumber
        self.authorizedAmount = authorizedAmount
        self.cardType = cardType
        self.cardLast4 = cardLast4
    }
}
