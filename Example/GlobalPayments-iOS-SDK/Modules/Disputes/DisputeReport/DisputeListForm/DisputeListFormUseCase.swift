import Foundation
import GlobalPayments_iOS_SDK

class DisputeListFormUseCase {
    
    lazy var form: DisputeListForm = DisputeListForm()
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .page:
            form.page = value.toInt()
        case .pageSize:
            form.pageSize = value.toInt()
        case .order:
            form.sortOrder = SortDirection(value: value)
        case .orderBy:
            form.sortProperty = DisputeSortProperty(value: value)
        case .status:
            form.status = DisputeStatus(value: value)
        case .arn:
            form.arn = value
        case .fromTimeCreated:
            form.fromTimeCreated = value.formattedDate()
        case .toTimeCreated:
            form.toTimeCreated = value.formattedDate()
        case .brand:
            form.brand = value
        case .stage:
            form.stage = DisputeStage(value: value)
        case .systemMid:
            form.systemMID = value
        case .systemHierarchy:
            form.systemHierarchy = value
        default:
            break
        }
    }
    
    func setSettlement(value: Bool) {
        form.source = value ? .settlement : .regular
    }
}
