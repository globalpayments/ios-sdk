import Foundation

public enum SdkInterface: String, Mappable {
    case native
    case browser
    case both
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
