import Foundation

public enum SdkUiType: String, CaseIterable {
    case text
    case singleSelect = "single_select"
    case multiSelect = "multi_select"
    case oob = "out_of_band"
    case htmlOther = "html_other"
    
    static func sdkUiTypes(_ sdkUiTypes: [SdkUiType]? , target:Target) -> [String] {
        
        return sdkUiTypes?.map({ type in
            type.rawValue.uppercased()
        }) ?? []
    }
}
