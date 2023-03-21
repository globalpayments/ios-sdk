import Foundation

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }

    func groups(_ string: String) -> [String]? {
        let range = NSRange(location: 0, length: string.utf16.count)
        guard let match = firstMatch(in: string, options: [], range: range) else { return nil }
        return match.groups(string)
    }
}

private extension NSTextCheckingResult {
    func groups(_ string: String) -> [String] {
        var groups = [String]()
        for position in  0 ..< self.numberOfRanges {
            guard let range = Range(self.range(at: position), in: string) else { continue }
            let group = String(string[range])
            groups.append(group)
        }
        return groups
    }
}
