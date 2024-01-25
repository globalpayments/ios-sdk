import Foundation
import GlobalPayments_iOS_SDK

class PaymentMethodsListUseCase {
    
    lazy var form: PaymentMethodsListForm = PaymentMethodsListForm()
    
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
            form.status = StoredPaymentMethodStatus(value: value)
        case .toTimeCreated:
            form.toTimeCreated = value.formattedDate()
        case .fromTimeCreated:
            form.fromTimeCreated = value.formattedDate()
        case .toTimeLastUpdated:
            form.endLastUpdatedDate = value.formattedDate()
        case .fromTimeLastUpdated:
            form.startLastUpdatedDate = value.formattedDate()
        default:
            break
        }
    }
}
