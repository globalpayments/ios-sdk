import Foundation
import CommonCrypto

extension String {

    static let empty = ""

    var sha512: String {
        return HMAC.hash(self, algorithm: .SHA512)
    }

    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func trim(_ trimString: String) -> String {
        return replacingOccurrences(of: self, with: trimString)
    }

    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(with range: Range<Int>) -> String {
        guard self.count >= range.lowerBound,
            self.count >= range.upperBound else { return .empty }
        let startIndex = index(from: range.lowerBound)
        let endIndex = index(from: range.upperBound)
        return String(self[startIndex..<endIndex])
    }

    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

private struct HMAC {

    static func hash(_ input: String, algorithm: HMACAlgorithm) -> String {
        guard let stringData = input.data(using: .utf8, allowLossyConversion: false) else {
            return .empty
        }

        return hexStringFromData(digest(stringData as NSData, algorithm: algorithm))
    }

    private static func digest(_ input: NSData, algorithm: HMACAlgorithm) -> NSData {
        let digestLength = algorithm.digestLength()
        var hash = [UInt8](repeating: 0, count: digestLength)

        switch algorithm {
        case .MD5: CC_MD5(input.bytes, UInt32(input.length), &hash)
        case .SHA1: CC_SHA1(input.bytes, UInt32(input.length), &hash)
        case .SHA224: CC_SHA224(input.bytes, UInt32(input.length), &hash)
        case .SHA256: CC_SHA256(input.bytes, UInt32(input.length), &hash)
        case .SHA384: CC_SHA384(input.bytes, UInt32(input.length), &hash)
        case .SHA512: CC_SHA512(input.bytes, UInt32(input.length), &hash)
        }

        return NSData(bytes: hash, length: digestLength)
    }

    private static func hexStringFromData(_ input: NSData) -> String {

        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        return hexString
    }
}

private enum HMACAlgorithm {

    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

    func digestLength() -> Int {

        var result: CInt = 0
        switch self {
        case .MD5: result = CC_MD5_DIGEST_LENGTH
        case .SHA1: result = CC_SHA1_DIGEST_LENGTH
        case .SHA224: result = CC_SHA224_DIGEST_LENGTH
        case .SHA256: result = CC_SHA256_DIGEST_LENGTH
        case .SHA384: result = CC_SHA384_DIGEST_LENGTH
        case .SHA512: result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
