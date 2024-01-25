import Foundation
import GlobalPayments_iOS_SDK

class ActionsListUseCase {
    
    lazy var form: ActionListForm = ActionListForm()
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .page:
            form.page = value.toInt()
        case .pageSize:
            form.pageSize = value.toInt()
        case .order:
            form.order = SortDirection(value: value)
        case .orderBy:
            form.orderBy = ActionSortProperty(value: value)
        case .id:
            form.id = value
        case .toTimeCreated:
            form.toTimeCreated = value.formattedDate()
        case .fromTimeCreated:
            form.fromTimeCreated = value.formattedDate()
        case .type:
            form.type = value
        case .resource:
            form.resource = value
        case .resourceStatus:
            form.resourceStatus = value
        case .resourceId:
            form.resourceId = value
        case .merchantName:
            form.merchantName = value
        case .accountName:
            form.accountName = value
        case .responseCode:
            form.responseCode = value
        case .httpResponseCode:
            form.httpResponseCode = value
        case .appName:
            form.appName = value
        case .version:
            form.version = value
        default:
            break
        }
    }
}
