import Foundation

struct DisputesModel {
    let name: String
    let path: Path

    enum Path {
        case report
        case operations
    }
}

extension DisputesModel {

    static var models: [DisputesModel] {
        [
            DisputesModel(name: "disputes.report.title".localized(), path: .report),
            DisputesModel(name: "disputes.operations.title".localized(), path: .operations)
        ]
    }
}
