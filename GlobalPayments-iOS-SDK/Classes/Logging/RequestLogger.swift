import Foundation

public protocol RequestLogger {
    func requestSent(request: String?)
    func responseReceived(response: String?)
}

public class SampleRequestLogger: RequestLogger {
    
    private lazy var maskedDataRepository: MaskedSensitiveDataRepository = MaskedSensitiveDataImpl()
    private let maskedItems: [MaskedItem]
    
    public init(maskedItems: [MaskedItem]){
        self.maskedItems = maskedItems
    }
    
    public func requestSent(request: String?) {
        if let request = request {
            let maskedData = maskedDataRepository.maskedData(maskedItems: maskedItems, request: request)
            print("request: \(maskedData ?? "")")
        }
    }
    
    public func responseReceived(response: String?) {
        if let response = response {
            print("response: \(response)")
        }
    }
}
