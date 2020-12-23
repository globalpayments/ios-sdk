import Foundation

class ValuesKeys {}

class ValuesKey<T>: ValuesKeys {
    let key: String

    init(_ key: String) {
        self.key = key
    }
}
