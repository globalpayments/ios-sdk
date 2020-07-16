import Foundation

public class MerchantDataCollection: NSObject {

    private var collection: [MerchantKVP]

    public init(collection: [MerchantKVP] = [MerchantKVP]()) {
        self.collection = collection
    }

    public func getKey(_ key: String) -> String? {
        return collection
            .first { $0.key == key && $0.isVisible }?.value
    }

    public func getKeys() -> [String] {
        return collection
            .filter { $0.isVisible }
            .map { $0.key }
    }

    public func count() -> Int {
        return collection
            .filter { $0.isVisible }
            .count
    }

    private func indexOf(key: String) -> Int {
        for (index, merchant) in collection.enumerated() where merchant.key == key {
            return index
        }
        return -1
    }

    private func getHiddenValues<T: MerchantKVP>(array: [T]?) -> [MerchantKVP]? {
        return array?.filter { !$0.isVisible }
    }

    public func put(key: String?, value: String?, isVisible: Bool = true) throws {
        guard let key = key else {
            throw ApiException.generic(
                message: String(format: "Key can't be nil")
            )
        }
        guard let value = value else {
            throw ApiException.generic(
                message: String(format: "Value can't be nil")
            )
        }
        if let _ = collection.first(where: { $0.key == key }) {
            if isVisible {
                throw ApiException.generic(
                    message: String(format: "Key %@ already exists in the collection.", key)
                )
            } else {
                collection.remove(at: indexOf(key: key))
            }
        }

        collection.append(MerchantKVP(
            key: key,
            value: value,
            isVisible: isVisible)
        )
    }

    func getDecimal(key: String) -> Decimal? {
        for merchant in collection where merchant.key == key {
            return Decimal(string: merchant.value)
        }
        return nil
    }

    func getString(key: String) -> String? {
        return collection.first { $0.key == key }?.value
    }

    func mergeHidden(collection: MerchantDataCollection?) {
        guard let hidden = getHiddenValues(array: collection?.collection) else { return }
        for merchant in hidden where !hasKey(key: merchant.key) {
            self.collection.append(merchant)
        }
    }

    func hasKey(key: String?) -> Bool {
        return collection
            .first { $0.key == key } != nil
    }

    public static func parse(kvpString: String, encoder: MerchantDataEncoder? = nil) throws -> MerchantDataCollection {
        let collection = MerchantDataCollection()

        // decrypt the string
        var decryptedKvp: String?
        if encoder != nil {
            decryptedKvp = encoder?.decode(input: kvpString)
        } else {
            decryptedKvp = decryptedKvp?.base64Decoded()
        }

        // build the object
        guard let merchantData = decryptedKvp?.components(separatedBy: "\\|") else {
            return collection
        }
        for kvp in merchantData {
            let data = kvp.components(separatedBy: ":")
            try collection.put(
                key: data[0],
                value: data[1],
                isVisible: Bool(data[2]) ?? false
            )
        }
        return collection
    }

    public func toString(encoder: MerchantDataEncoder? = nil) -> String? {
        var result: String = .empty
        collection.forEach {
            result.append("{\($0.key)}:{\($0.value)}:{\($0.isVisible)}|")
        }
        var formatted = String(result.dropLast())
        if let encoder = encoder {
            formatted = encoder.encode(input: formatted)
        }

        return formatted.base64Encoded()
    }
}
