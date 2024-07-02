import Foundation

public enum MerchantDocumentType: String, Mappable, CaseIterable {
    
    case tif
    case tiff
    case bmp
    case jpg
    case jpeg
    case gif
    case png
    case doc
    case docx
    
    public init?(value: String?) {
        guard let value = value,
              let type = MerchantDocumentType(rawValue: value) else { return nil }
        self = type
    }
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
