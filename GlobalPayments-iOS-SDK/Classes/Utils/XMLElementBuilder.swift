//
//  XMLDOMBuilder.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Yashwant Patil on 09/03/26.
//

import Foundation

public class XMLElementNode: NSObject {
    public var name: String
    public var value: String?
    public var attributes: [String: String]
    public var children: [XMLElementNode]
    
    public init(name: String, value: String? = nil, attributes: [String: String] = [:], children: [XMLElementNode] = []) {
        self.name = name
        self.value = value
        self.attributes = attributes
        self.children = children
        super.init()
    }
}

public class XMLElementBuilder: NSObject {
    
    public static func buildXML(from element: XMLElementNode) -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        xml += buildElement(element, indent: 0)
        return xml
    }
    
    private static func buildElement(_ element: XMLElementNode, indent: Int) -> String {
        let indentString = String(repeating: "  ", count: indent)
        var xml = ""
        
        xml += indentString + "<\(element.name)"
        
        for (key, value) in element.attributes.sorted(by: { $0.key < $1.key }) {
            xml += " \(key)=\"\(escapeXML(value))\""
        }
        
        if element.children.isEmpty && element.value == nil {
            xml += "/>\n"
            return xml
        }
        
        xml += ">"
        
        if let value = element.value, !value.isEmpty {
            if element.children.isEmpty {
                xml += escapeXML(value)
            } else {
                xml += "\n" + indentString + "  " + escapeXML(value) + "\n"
            }
        }
        
        if !element.children.isEmpty {
            if element.value == nil || element.value?.isEmpty == true {
                xml += "\n"
            }
            for child in element.children {
                xml += buildElement(child, indent: indent + 1)
            }
            xml += indentString
        }
        
        xml += "</\(element.name)>\n"
        
        return xml
    }
    
    private static func escapeXML(_ string: String) -> String {
        var escaped = string
        escaped = escaped.replacingOccurrences(of: "&", with: "&amp;")
        escaped = escaped.replacingOccurrences(of: "<", with: "&lt;")
        escaped = escaped.replacingOccurrences(of: ">", with: "&gt;")
        escaped = escaped.replacingOccurrences(of: "\"", with: "&quot;")
        escaped = escaped.replacingOccurrences(of: "'", with: "&apos;")
        return escaped
    }
    
    public static func element<T>(name: String, value: T) -> XMLElementNode {
        return XMLElementNode(name: name, value: "\(value)")
    }
    
    public static func element(name: String, value: String) -> XMLElementNode {
        return XMLElementNode(name: name, value: value)
    }
    
    public static func element<T>(name: String, value: T?) -> XMLElementNode {
        if let value = value {
            return XMLElementNode(name: name, value: "\(value)")
        }
        return XMLElementNode(name: name, value: nil)
    }
    
    public static func element(name: String, children: [XMLElementNode]) -> XMLElementNode {
        return XMLElementNode(name: name, children: children)
    }
    
    public static func element(name: String, attributes: [String: String]) -> XMLElementNode {
        return XMLElementNode(name: name, attributes: attributes)
    }
    
    public static func element<T>(name: String, attributes: [String: String], value: T) -> XMLElementNode {
        return XMLElementNode(name: name, value: "\(value)", attributes: attributes)
    }
    
    public static func element(name: String, attributes: [String: String], value: String) -> XMLElementNode {
        return XMLElementNode(name: name, value: value, attributes: attributes)
    }
    
    public static func element<T>(name: String, attributes: [String: String], value: T?) -> XMLElementNode {
        if let value = value {
            return XMLElementNode(name: name, value: "\(value)", attributes: attributes)
        }
        return XMLElementNode(name: name, value: nil, attributes: attributes)
    }
    
    public static func element(name: String, attributes: [String: String], children: [XMLElementNode]) -> XMLElementNode {
        return XMLElementNode(name: name, attributes: attributes, children: children)
    }
}

public class SOAPDOMBuilder: NSObject {
    
    private var header: XMLElementNode?
    private var body: XMLElementNode?
    
    public func with(header: XMLElementNode) -> Self {
        self.header = header
        return self
    }
    
    public func with(body: XMLElementNode) -> Self {
        self.body = body
        return self
    }
    
    public func build() -> String {
        var soapBodyChildren: [XMLElementNode] = []
        if let body = self.body {
            soapBodyChildren.append(body)
        }
        let soapBody = XMLElementNode(name: "soap:Body", children: soapBodyChildren)
        
        var envelopeChildren: [XMLElementNode] = []
        if let header = self.header {
            let soapHeader = XMLElementNode(name: "soap:Header", children: [header])
            envelopeChildren.append(soapHeader)
        }
        envelopeChildren.append(soapBody)
        
        let envelope = XMLElementNode(
            name: "soap:Envelope",
            attributes: [
                "xmlns:soap": "http://schemas.xmlsoap.org/soap/envelope/",
                "xmlns": "http://Hps.Exchange.PosGateway"
            ],
            children: envelopeChildren
        )
        
        return XMLElementBuilder.buildXML(from: envelope)
    }
}
