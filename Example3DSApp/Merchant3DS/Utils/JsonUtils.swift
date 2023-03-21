import Foundation

public protocol RequestEncoder {
    func encode(value: Any?) -> String?
    func decode(value: Any?) -> String?
}

public class Base64Encoder: RequestEncoder {

    public func encode(value: Any?) -> String? {
        guard let value = value as? String else { return nil }
        guard let data = value.data(using: .utf8) else { return nil }
        return data.base64EncodedString()
    }

    public func decode(value: Any?) -> String? {
        guard let value = value as? String else { return nil }
        guard let data = Data(base64Encoded: value) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

public class JsonEncoders {
    public static var base64Encoder: Base64Encoder {
        return Base64Encoder()
    }
}

public class JsonDoc {
    var dict: [String: Any]
    var encoder: RequestEncoder?

    init(dict: [String: Any] = [String: Any](),
         encoder: RequestEncoder? = nil) {
        self.dict = dict
        self.encoder = encoder
    }

    public var keys: [String] {
        return dict.map { $0.key }
    }

    public func remove(valueFor key: String) -> JsonDoc {
        dict.removeValue(forKey: key)
        return self
    }

    @discardableResult public func set(for key: String, value: Encodable?, force: Bool = false) -> JsonDoc {
        guard let value = value else { return self }
        dict[key] = encoder != nil ? encoder?.encode(value: value) : value
        return self
    }

    @discardableResult public func set(for key: String, doc: JsonDoc?) -> JsonDoc {
        guard let doc = doc, !doc.keys.isEmpty else { return self }
        dict[key] = doc
        return self
    }

    public func subElement(for key: String) -> JsonDoc {
        let subRequest = JsonDoc()
        dict[key] = subRequest
        return subRequest
    }

    public func toString() -> String? {
        let final = finalize()
        if final.keys.isEmpty { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: final, options: .prettyPrinted) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public func finalize() -> [String: Any] {
        var final = [String: Any]()
        for key in dict.keys {
            if let jsonDoc = dict[key] as? JsonDoc {
                final[key] = jsonDoc.finalize()
            } else {
                final[key] = dict[key]
            }
        }
        return final
    }

    public func get(valueFor key: String) -> JsonDoc? {
        if dict.keys.contains(key) {
            if let jsonDoc = dict[key] as? JsonDoc {
                return jsonDoc
            }
        }
        return nil
    }

    public func getValue<T>(key: String) -> T? {
        return dict[key] as? T
    }

    public func getValue<T>(keys: String...) -> T? {
        for key in keys {
            guard let value = dict[key] as? T else {
                continue
            }
            return value
        }
        return nil
    }

    public func getValue(key: String, encoder: RequestEncoder?) -> Any? {
        var value = dict[key]
        if encoder != nil {
            value = encoder?.decode(value: value)
        }
        if encoder != nil {
            return encoder?.encode(value: value)
        }
        return value
    }

    public func getEnumerator(key: String) -> [JsonDoc]? {
        if let value = dict[key] {
            if value is [Any] {
                return value as? [JsonDoc]
            }
        }
        return nil
    }

    public func has(key: String) -> Bool {
        return dict.keys.contains(key)
    }

    public static func parse(_ json: String, encoder: RequestEncoder? = nil) -> JsonDoc? {
        guard let data = json.data(using: .utf8) else { return nil }
        guard let jsonDict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return nil }
        return parseObject(jsonDict, encoder)
    }

    public static func parseSingleValue(_ json: String,
                                        _ name: String,
                                        _ encoder: RequestEncoder? = nil) -> Any? {
        let doc = parse(json, encoder: encoder)

        return doc?.get(valueFor: name)
    }

    public static func parseObject(_ jsonDict: [String: Any],
                                   _ encoder: RequestEncoder?) -> JsonDoc? {
        var values = [String: Any]()
        for key in jsonDict.keys {
            if let array = jsonDict[key] as? [Any] {
                if array.first is [String: Any] {
                    let objs = parseObjectArray(array, encoder)
                    values[key] = objs
                } else {
                    let objs: [String] = parseTypeArray(array)
                    values[key] = objs
                }
            } else if let dict = jsonDict[key] as? [String: Any] {
                values[key] = parseObject(dict, encoder)
            } else {
                values[key] = jsonDict[key]
            }
        }

        return JsonDoc(dict: values, encoder: encoder)
    }

    private static func parseObjectArray(_ array: [Any],
                                         _ encoder: RequestEncoder?) -> [JsonDoc?] {
        return array
            .compactMap { $0 as? [String: Any] }
            .map { parseObject($0, encoder) }
    }

    private static func parseTypeArray<T>(_ array: [Any]) -> [T] {
        return array.compactMap { $0 as? T }
    }
}

