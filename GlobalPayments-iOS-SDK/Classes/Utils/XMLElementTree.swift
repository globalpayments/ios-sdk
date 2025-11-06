import Foundation

private protocol OptionalProtocol {
    var isNil: Bool { get }
    var wrappedValue: Any { get }
}

public class XMLElementTree {
    public let name: String
    public var value: Any?
    public var attributes: [String: String]
    public var children: [XMLElementTree]

    public init(name: String, value: Any? = nil, attributes: [String: String] = [:], children: [XMLElementTree] = []) {
        self.name = name
        self.value = value
        self.attributes = attributes
        self.children = children
    }

    public func addChild(_ child: XMLElementTree) {
        children.append(child)
    }

    private func escape(_ string: String) -> String {
        var escaped = string
        escaped = escaped.replacingOccurrences(of: "&", with: "&amp;")
        escaped = escaped.replacingOccurrences(of: "<", with: "&lt;")
        escaped = escaped.replacingOccurrences(of: ">", with: "&gt;")
        escaped = escaped.replacingOccurrences(of: "\"", with: "&quot;")
        escaped = escaped.replacingOccurrences(of: "'", with: "&apos;")
        return escaped
    }

    private func valueToString(_ value: Any?) -> String? {
        guard let value = value else { return nil }
       
        if let optional = value as? OptionalProtocol {
            if optional.isNil { return nil }
            return String(describing: optional.wrappedValue)
        }
        return String(describing: value)
    }

    func toXMLString(
        indentation: String = "",
        includeXMLDeclaration: Bool = false,
        xmlVersion: String = "1.0",
        encoding: String = "utf-8",
        standalone: String? = nil
    ) -> String {
        var xml = ""
        if includeXMLDeclaration {
            xml += "<?xml version=\"\(xmlVersion)\" encoding=\"\(encoding)\""
            if let standalone = standalone {
                xml += " standalone=\"\(standalone)\""
            }
            xml += "?>\n"
        }
        xml += toXMLString(indentation: indentation)
        return xml
    }
    
    /// Generates the XML string for this node and its children.
    public func toXMLString(indentation: String = "", indentLevel: Int = 0) -> String {
        let indent = String(repeating: indentation, count: indentLevel)
        var xml = "\(indent)<\(name)"
        for (key, val) in attributes {
            xml += " \(key)=\"\(escape(val))\""
        }
        let valueString = valueToString(value)
        let isValueEmpty = valueString?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        if children.isEmpty && isValueEmpty {
            return "" // Do not create the tag at all
        }
        xml += ">"
        var hasChild = false
        if let valueString = valueString, !valueString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            xml += escape(valueString)
        }
        let childXMLs = children
            .map { $0.toXMLString(indentation: indentation, indentLevel: indentLevel + 1) }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if !childXMLs.isEmpty {
            xml += "\n"
            xml += childXMLs.joined(separator: "\n")
            xml += "\n" + indent
            hasChild = true
        }
        xml += "</\(name)>"
        return xml
    }
}
