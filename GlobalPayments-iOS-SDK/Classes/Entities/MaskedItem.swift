import Foundation

public class MaskedItem {
    let value: String
    let start: Int
    let end: Int
    
    public init(value: String, start: Int, end: Int) {
        self.value = value
        self.start = start
        self.end = end
    }
}
