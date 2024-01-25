import Foundation

public enum PermissionsEnum: String, CaseIterable {
    
    case ACT_POST_Multiple
    case ACT_GET_Single
    case ACT_GET_List
    case ACC_GET_Single
    case GET_Single
    case PMT_POST_Detokenize
    case PMT_POST_Search
    case PMT_POST_Create
    case PMT_GET_Single
    case PMT_PATCH_Edit
}
