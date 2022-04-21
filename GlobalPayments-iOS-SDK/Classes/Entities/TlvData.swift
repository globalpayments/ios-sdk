import Foundation

struct TlvData {
    var tag: String
    var length: String
    var value: String
    var description: String

    func getBinaryValue() -> String? {
        var sb = ""
        for b in value.bytes {
//            let string = Convert.ToString((b & 0xFF) + 0x100,2).Substring(1)
            var bytes = Int8(b & 0xFF)
            let data = Data(bytes: &bytes, count: MemoryLayout<UInt32>.size)
            let value = String(data: data, encoding: .utf8) ?? ""
            sb += value
        }
        return sb
    }
}
