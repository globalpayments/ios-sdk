import Foundation

protocol MaskedSensitiveDataRepository: AnyObject {
    func maskedData(maskedItems: [MaskedItem], request: String) -> String?
    func maskItem(item: MaskedItem, jsonDoc: JsonDoc?)
}

class MaskedSensitiveDataImpl: MaskedSensitiveDataRepository {
    
    func maskedData(maskedItems: [MaskedItem], request: String) -> String? {
        let jsonData = JsonDoc.parse(request)
        maskedItems.forEach {
            maskItem(item: $0, jsonDoc: jsonData)
        }
        return jsonData?.toString()
    }
    
    func maskItem(item: MaskedItem, jsonDoc: JsonDoc?) {
        var doc: JsonDoc? = nil
        item.value.components(separatedBy: ".").forEach { data in
            if let value: JsonDoc = doc?.getValue(key: data) {
                doc = value
            } else if let value: JsonDoc = jsonDoc?.getValue(key: data){
                doc = value
            }else if let value: String = doc?.getValue(key: data) {
                var maskedValue = value
                if item.start > 0 {
                    maskedValue = String(maskedValue.enumerated().map { !(0...item.start - 1).contains($0) ? $1 : "*" })
                }
                
                if item.end > 0 {
                    let startIndex = maskedValue.count - item.end
                    maskedValue = String(maskedValue.enumerated().map { !(startIndex...maskedValue.count).contains($0) ? $1 : "*" })
                }
                
                if item.start == 0 && item.end == 0 {
                    maskedValue = String(maskedValue.enumerated().map {_ in "*"})
                }
                doc?.set(for: data, value: maskedValue)
            }
        }
    }
}
