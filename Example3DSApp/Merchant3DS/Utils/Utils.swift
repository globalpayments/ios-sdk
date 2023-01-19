import Foundation

func UI(execute block: @escaping () -> Void) {
    if Thread.isMainThread { return block() }
    DispatchQueue.main.async(execute: block)
}
