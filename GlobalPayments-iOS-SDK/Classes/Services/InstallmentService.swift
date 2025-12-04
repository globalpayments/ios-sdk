import Foundation

// <summary>
/// Represents the Installment Service to create the installment
/// </summary>
public class InstallmentService {
    
    /// <summary>
    /// Creates the Installment
    /// </summary>
    /// <param name="entity"></param>
    /// <param name="configName"></param>
    /// <returns>Installment</returns>
    
    public static func create(entity: Installment, configName: String = "default", completion: ((Installment?, Error?) -> Void)?) {
        InstallmentBuilder(entity: entity).execute(configName: configName, completion: completion)
    }
}
