//
//  PorticoBatchService.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Yashwant Patil on 02/03/26.
//

import Foundation

public class PorticoBatchService {
    
    public static func closeBatch(completion: ((Transaction?, Error?) -> Void)?) {
        let builder = ManagementBuilder(transactionType: .batchClose)
        builder.execute { transaction, error in
            guard let transaction = transaction else {
                completion?(nil, error)
                return
            }
            completion?(transaction, nil)
        }
    }
}
