import Foundation

public enum FileProcessingActionType: Int, Mappable, CaseIterable {
    
    case CREATE_UPLOAD_URL = 1
    case GET_DETAILS = 2
    
    public init?(value: Int?) {
        guard let value = value,
              let status = FileProcessingActionType(rawValue: value) else { return nil }
        self = status
    }
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return "\(self.rawValue)"
        default:
            return nil
        }
    }
}
