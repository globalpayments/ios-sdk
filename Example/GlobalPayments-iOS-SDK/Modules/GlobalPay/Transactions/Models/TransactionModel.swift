import Foundation

struct TransactionModel {
    let name: String
    let path: Path

    enum Path {
        case report
        case operations
    }
}

extension TransactionModel {

    static var models: [TransactionModel] {
        [
            TransactionModel(name: "transactions.report.title".localized(), path: .report),
            TransactionModel(name: "transactions.operations.title".localized(), path: .operations)
        ]
    }
}
