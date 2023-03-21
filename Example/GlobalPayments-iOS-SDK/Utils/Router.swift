import Foundation

protocol Router {
    associatedtype Destination

    func navigate(to destination: Destination)
}
