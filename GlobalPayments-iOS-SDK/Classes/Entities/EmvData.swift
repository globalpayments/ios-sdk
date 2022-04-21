import Foundation

class EmvData {

    var tlvData: [String: TlvData] = [:]
    var removedTags: [String: TlvData] = [:]
    var standInStatus: Bool = false
    var standInStatusReason: String = ""

    func getTag(_ tagName: String) -> TlvData? {
        if let keyExists = tlvData[tagName] {
            return keyExists
        }
        return nil
    }

    func isContactlessMsd() -> Bool {
        guard let entryMode = getEntryMode() else {return false}
        return entryMode == "91"
    }

    func getEntryMode() -> String? {
        guard let posEntryMode = getTag("9F39") else {return nil}
        return posEntryMode.value
    }

    func setStandInStatus(_ value: Bool, reason: String) {
        standInStatus = value
        standInStatusReason = reason
    }

    internal func addRemovedTag(tag: String, length: String, value: String, description: String) {
        addRemovedTag(TlvData(tag: tag, length: length, value: value, description: description))
    }
    internal func addRemovedTag(_ tagData: TlvData) {
        removedTags[tagData.tag] = tagData
    }

    internal func addTag(_ tag: String, length: String, value: String, description: String) {
        addTag(TlvData(tag: tag, length: length, value: value, description: description))
    }
    internal func addTag(_ tagData: TlvData) {
        tlvData[tagData.tag] = tagData
    }
}
