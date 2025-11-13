import Foundation

public protocol InstallmentServiceProtocol {
    func ProcessInstallment<T>(builder: InstallmentBuilder<T>, completion: ((T?, Error?) -> Void)?)
}
