import Foundation

struct DisputeByIDForm {
    let disputeId: String
    let source: Source

    enum Source {
        case settlement
        case regular
    }
}
