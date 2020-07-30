import Foundation

public enum Target {
    case nws
    case vaps
    case transit
    case portico
    case gpApi
}

public protocol Mappable {
    func mapped(for target: Target) -> String?
}
