import Foundation
//public class RecurringBuilder<TResult>: TransactionBuilder<TResult> {
public class InstallmentBuilder<TResult>: BaseBuilder<TResult> {
    
    /// <summary>
    /// Represents the Installment entity
    /// </summary>
    internal var entity: InstallmentEntity?
    
    /// <summary>
    /// Represents the parameterized constructor to set the installment Entity value
    /// </summary>
    /// <param name="entity"></param>
    init(entity: InstallmentEntity? = nil) {
        if let entity = entity {
            self.entity = entity
        }
    }
    
    /// <summary>
    /// Executes the Installment builder against the gateway.
    /// </summary>
    /// <returns>TResult</returns>
    public override func execute(configName: String = "default",
                                 completion: ((TResult?, Error?) -> Void)?) {
        
        super.execute(configName: configName) { _, error in
            if let error = error {
                completion?(nil, error)
                return
            }
        }
        do {
            let client = try ServicesContainer.shared.getInstallmentClient(configName: configName)
            client.ProcessInstallment(builder: self, completion: completion)
        } catch {
            completion?(nil, error)
        }
    }
}
