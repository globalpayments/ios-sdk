import Foundation
import GlobalPayments_iOS_SDK

final class DisputesOperationsFormViewModel: BaseViewModel {
    
    var addDocument: Dynamic<DocumentInfo> = Dynamic(DocumentInfo(type: .salesReceipt, b64Content: nil))
    
    private var cardNumber: String = ""
    private var cardExpiration: String = ""
    private var cvv: String = ""
    private var disputeId: String = ""
    private var idempotencyKey: String = ""
    private var operationType: OperationType = .accept
    private var currency: String = ""
    
    func onSubmitPressed(_ documents: [DocumentInfo]) {
        showLoading.executer()
        let form = DisputesOperationsForm(disputeId: disputeId, idempotencyKey: idempotencyKey)
        switch operationType {
        case .accept:
            accceptDispute(form: form)
        case .challenge:
            if documents.isEmpty {
                self.showDataResponse.value = (.error, GatewayException(message: "Documents can't be empty"))
            }else {
                challengeDispute(form: form, documents: documents)
            }
        }
    }

    func accceptDispute(form: DisputesOperationsForm) {
        ReportingService
            .acceptDispute(id: form.disputeId)
            .withIdempotencyKey(form.idempotencyKey)
            .execute(completion: showOutput)
    }

    func challengeDispute(form: DisputesOperationsForm, documents: [DocumentInfo]) {
        ReportingService
            .challangeDispute(id: form.disputeId, documents: documents)
            .withIdempotencyKey(form.idempotencyKey)
            .execute(completion: showOutput)
    }

    private func showOutput(transaction: Any?, error: Error?) {
        UI {
            guard let transaction = transaction else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            self.showDataResponse.value = (.success, transaction)
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .disputeId:
            disputeId = value
        case .idempotencyId:
            idempotencyKey = value
        case .cardNumber:
            cardNumber = value
        case .cardCvv:
            cvv = value
        case .cardExpiryDate:
            cardExpiration = value
        case .operationType:
            operationType = OperationType(value: value.lowercased()) ?? .accept
        case .currencyType:
            currency = value
        default:
            break
        }
    }
    
    func validateDocument(_ image: UIImage?) {
        guard let content = image?.pngData() else {
            return
        }
        let document = DocumentInfo(type: .salesReceipt, b64Content: content)
        addDocument.value = document
    }
}
