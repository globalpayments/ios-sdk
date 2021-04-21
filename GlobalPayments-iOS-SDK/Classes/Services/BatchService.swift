import Foundation

public class BatchService {

    public static func closeBatch(batchReference: String?, completion: ((BatchSummary?, Error?) -> Void)?) {
        ManagementBuilder(transactionType: .batchClose)
            .withBatchReference(batchReference)
            .execute { transaction, error in
                guard let batchSummary = transaction?.batchSummary else {
                    completion?(nil, error)
                    return
                }
                completion?(batchSummary, nil)
            }
    }
}
