//
//  PorticoSurchargeEligibilityLookupBuilder.swift
//  Pods
//
//  Created by Ranu Dhurandhar on 27/02/26.
//

import Foundation

class SurchargeEligibilityLookupBuilder: TransactionBuilder<Transaction> {
    var allowDuplicates: Bool = false
    var allowPartialAuth: Bool = false
    var cpcReq: Bool = false
    var amount: String?
    var billingAddress: Address?
    var chipCondition: EmvChipCondition = .noChipOrChipSuccess
    var clientTransactionId: String?
    var convenienceAmount: String?
    var customerId: String?
    var dynamicDescriptor: String?
    var gratuity: String?
    var invoiceNumber: String?
    var level2Request: Bool = false
    var offlineAuthCode: String?
    var requestMultiUseToken: Bool = false
    var shippingAddress: Address?
    var shippingAmount: String?
    var surchargeAmount: String?
    var tagData: String?
    var transactionDescription: String?
    var autoSubstantiation: AutoSubstantiation?
    
    public override func execute(configName: String = "default",
                                 completion: ((Transaction?, Error?) -> Void)?) {

        super.execute(configName: configName) { _, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            do {
                try ServicesContainer.shared
                    .client(configName: configName)
                    .processSurchargeEligibilityLookup(self, completion: { transaction, error in
                        completion?(transaction, error)
                    })
            } catch {
                completion?(nil, error)
            }
        }
    }

}
