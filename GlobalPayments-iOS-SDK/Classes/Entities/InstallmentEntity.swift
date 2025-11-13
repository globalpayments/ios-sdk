import Foundation

public protocol InstallmentEntity {
    func create(configName: String, completion: ((Installment?, Error?) -> Void)?)
}
