import Foundation

/// Data relating to a bank transfer directly to or from the merchant's bank account.
public class DepositBankTransfer: NSObject {
    /// The bank account number, masked to show the last 4 digits.
    public var maskedAccountNumberLast4: String?
    /// The bank the transfer was sent to.
    public var bank: DepositBankTransferBank?
}

/// The bank a deposit's bank transfer was sent to.
public class DepositBankTransferBank: NSObject {
    /// The local identifier code for the bank.
    public var code: String?
}
