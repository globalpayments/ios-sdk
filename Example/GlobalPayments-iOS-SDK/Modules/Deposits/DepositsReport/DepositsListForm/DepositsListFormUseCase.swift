import Foundation
import GlobalPayments_iOS_SDK

class DepositsListFormUseCase {
    
    lazy var form: DepositsListForm = DepositsListForm()
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .page:
            form.page = value.toInt()
        case .pageSize:
            form.pageSize = value.toInt()
        case .order:
            form.order = SortDirection(value: value)
        case .orderBy:
            form.orderBy = DepositSortProperty(value: value)
        case .accountName:
            form.accountName = value
        case .status:
            form.status = DepositStatus(value: value)
        case .id:
            form.id = value
        case .fromTimeCreated:
            form.fromTimeCreated = value.formattedDate()
        case .toTimeCreated:
            form.toTimeCreated = value.formattedDate()
        case .amount:
            form.amount = NSDecimalNumber(string: value)
        case .maskedAccountNumber:
            form.maskedNumber = value
        case .systemMid:
            form.systemMID = value
        case .systemHierarchy:
            form.systemHierarchy = value
        default:
            break
        }
    }
}

