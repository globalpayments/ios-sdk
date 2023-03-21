import Foundation

public enum SdkUiType: String {
    case text
    case singleSelect
    case multiSelect
    case oob
    case htmlOther
    
    static func sdkUiTypes(_ sdkUiTypes: [SdkUiType]? , target:Target) -> [String] {
        
        return sdkUiTypes?.map({ type in
            type.rawValue.uppercased()
        }) ?? []
    }
}
