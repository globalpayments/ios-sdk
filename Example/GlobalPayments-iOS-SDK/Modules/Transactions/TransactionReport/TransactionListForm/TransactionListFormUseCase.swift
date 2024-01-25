import Foundation
import GlobalPayments_iOS_SDK

class TransactionListFormUseCase {
    
    lazy var form: TransactionListForm = TransactionListForm()

    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .page:
            form.page = value.toInt()
        case.pageSize:
            form.pageSize = value.toInt()
        case .order:
            form.sortOrder = SortDirection(value: value)
        case .orderBy:
            form.sortProperty = TransactionSortProperty(value: value)
        case .brand:
            form.cardBrand = value
        case .brandReference:
            form.brandReference = value
        case .authCode:
            form.authCode = value
        case .reference:
            form.referenceNumber = value
        case .status:
            form.transactionStatus = TransactionStatus(value: value)
        case .numberFirst6:
            form.numberFirst6 = value
        case .numberLast4:
            form.numberLast4 = value
        case .fromTimeCreated:
            form.startDate = value.formattedDate()
        case .toTimeCreated:
            form.endDate = value.formattedDate()
        case .amount:
            form.amount = NSDecimalNumber(string: value)
        case .currency:
            form.currency = value
        case .transactionId:
            form.transactionId = value
        case .type:
            form.type = PaymentType(value: value)
        case .channel:
            form.channel = Channel(value: value)
        case .tokenFirst6:
            form.tokenFirst6 = value
        case .tokenLast4:
            form.tokenLast4 = value
        case .accountHolderName:
            form.accountName = value
        case .country:
            form.country = value
        case .batchId:
            form.batchId = value
        case .entryMode:
            form.entryMode = PaymentEntryMode(value: value)
        case .name:
            form.name = value
        default:
            break
        }
    }
    
    func setSettlement(value: Bool) {
        form.source = value ? .settlement : .regular
    }
}
