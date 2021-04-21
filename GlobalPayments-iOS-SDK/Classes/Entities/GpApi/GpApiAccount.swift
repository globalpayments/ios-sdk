import Foundation

class GpApiAccount {
    var id: String?
    var name: String?
    var permissions: [String]?

    init(id: String?, name: String?, permissions: [String]?) {
        self.id = id
        self.name = name
        self.permissions = permissions
    }
}
