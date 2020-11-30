import Foundation

struct PaymentMethodsModel {
    let name: String
    let path: Path

    enum Path {
        case report
        case operations
    }
}

extension PaymentMethodsModel {

    static var models: [PaymentMethodsModel] {
        [
            PaymentMethodsModel(name: "payment.methods.report.title".localized(), path: .report),
            PaymentMethodsModel(name: "payment.methods.operations.title".localized(), path: .operations)
        ]
    }
}
