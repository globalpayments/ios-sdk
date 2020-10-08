import Foundation

extension Encodable {

    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }

    func asString() throws -> String? {
        let data = try JSONEncoder().encode(self)
        return String(data: data, encoding: .utf8)
    }

    func asData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
