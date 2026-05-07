import Foundation

public enum EmvChipCondition: String {
    case chipFailPreviousSuccess = "CHIP_FAILED_PREV_SUCCESS"
    case chipFailPreviousFail = "CHIP_FAILED_PREV_FAILED"
    case noChipOrChipSuccess = "NO_CHIP_OR_CHIP_SUCCESS"
}
