import Foundation

public enum TrackNumber {
    case unknown
    case trackOne
    case trackTwo
    case bothOneAndTwo
    
    var stringValue: String {
           switch self {
           case .trackTwo: return "2"
           case .trackOne: return "1"
           case .bothOneAndTwo: return "BOTH"
           case .unknown: return "UNKNOWN"
           }
       }
}
