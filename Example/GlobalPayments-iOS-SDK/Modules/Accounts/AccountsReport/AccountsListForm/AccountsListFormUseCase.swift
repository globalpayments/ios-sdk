import Foundation
import GlobalPayments_iOS_SDK

class AccountsListFormUseCase {
    
    lazy var form: AccountsListForm = AccountsListForm()
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .page:
            form.page = value.toInt()
        case .pageSize:
            form.pageSize = value.toInt()
        case .order:
            form.order = SortDirection(value: value)
        case .orderBy:
            form.orderBy = TransactionSortProperty(value: value)
        case .id:
            form.id = value
        case .toTimeCreated:
            form.toTimeCreated = value.formattedDate()
        case .fromTimeCreated:
            form.fromTimeCreated = value.formattedDate()
        case .name:
            form.name = value
        case .status:
            form.status = UserStatus(value: value)
        default:
            break
        }
    }
}
