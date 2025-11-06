import Foundation

public class TransactionReportAdditionalTxnFields {
    var description: String?
    var invoiceNbr: String?
    var customerID: String?
}

public class TransactionReportCardHolder {
    var cardHolderLastName: String?
}

public class TransactionReportHeader {
    var licenseId: String?
    var siteId: String?
    var deviceId: String?
    var gatewayTxnId: String?
    var gatewayRspCode: String?
    var gatewayRspMsg: String?
    var rspDT: String?
    var xGlobalTransactionId: String?
    var xGlobalTransactionSource: String?
}

public class TransactionReportSummary {
    var header: TransactionReportHeader?
    var transactions: [TransactionSummary] = []
}
