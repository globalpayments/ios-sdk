import Foundation

public struct PorticoApiMapping {
    
    public static func mapReportResponse<T>(_ rawResponse: String, _ reportType: ReportType) -> T? {
        var result: Any?
        guard let porticoResponseParser = PorticoApiMapping.xmlParseXmlResponse(rawResponse) else {
            return nil
        }
        
        if reportType == .findTransactions {
            let transactionSummury = PorticoApiMapping.mapTransactionSummary(porticoResponseParser)
            result = transactionSummury
        }
        return result as? T
    }
    
    public static func mapTransactionSummary(_ porticoResponseParser: PorticoResponseParser) -> [TransactionSummary] {
        return porticoResponseParser.transactionReportSummary.transactions
    }
    
    public static func xmlParseXmlResponse(_ xmlString: String) ->  PorticoResponseParser? {
        if let data = xmlString.data(using: .utf8) {
            let parser = XMLParser(data: data)
            let porticoResponseParser = PorticoResponseParser()
            parser.delegate = porticoResponseParser
            return porticoResponseParser
        }
        return nil
    }
    
    public static func mapTransactionReportHeader(_ elementName: String, _ currentValue: String, _ transactionReportHeader: TransactionReportHeader, _ transactionReportSummary: TransactionReportSummary) {
        switch elementName {
        case "LicenseId": transactionReportHeader.licenseId = currentValue
        case "SiteId": transactionReportHeader.siteId = currentValue
        case "DeviceId": transactionReportHeader.deviceId = currentValue
        case "GatewayTxnId": transactionReportHeader.gatewayTxnId = currentValue
        case "GatewayRspCode": transactionReportHeader.gatewayRspCode = currentValue
        case "GatewayRspMsg": transactionReportHeader.gatewayRspMsg = currentValue
        case "RspDT": transactionReportHeader.rspDT = currentValue
        case "x_global_transaction_id": transactionReportHeader.xGlobalTransactionId = currentValue
        case "x_global_transaction_source": transactionReportHeader.xGlobalTransactionSource = currentValue
        case "Header":
            transactionReportSummary.header = transactionReportHeader
        default: break
        }
    }
    
    public static func mapTransactionReportSummary(_ elementName: String, _ currentValue: String, _ transactionSummary: TransactionSummary, _ transactionReportSummary: TransactionReportSummary) {
        switch elementName {
        case "GatewayTxnId": transactionSummary.transactionId = currentValue
        case "GatewayRspCode": transactionSummary.gatewayResponseCode = currentValue
        case "GatewayRspMsg": transactionSummary.gatewayResponseMessage = currentValue
        case "CardType": transactionSummary.cardType = currentValue
        case "MaskedCardNbr": transactionSummary.maskedCardNumber = currentValue
        case "CardSwiped": transactionSummary.cardSwiped = currentValue
        case "PaymentType": transactionSummary.paymentType = currentValue
        case "ServiceName": transactionSummary.serviceName = currentValue
        case "TxnStatus": transactionSummary.transactionStatus = TransactionStatus(rawValue: currentValue)
        case "AuthCode": transactionSummary.authCode = currentValue
        case "Amt": transactionSummary.amount = NSDecimalNumber(string: currentValue)
        case "AuthAmt": transactionSummary.authorizedAmount = NSDecimalNumber(string: currentValue)
        case "SettlementAmt": transactionSummary.settlementAmount = NSDecimalNumber(string: currentValue)
        case "UserName": transactionSummary.username = currentValue
        case "RspDT": transactionSummary.transactionDate = currentValue.format()
        case "RspCode": transactionSummary.issuerResponseCode = currentValue
        case "RspText": transactionSummary.gatewayResponseMessage = currentValue
        case "IssTxnId": transactionSummary.issuerTransactionId = currentValue
        case "RefNbr": transactionSummary.referenceNumber = currentValue
        case "BatchSeqNbr": transactionSummary.batchSequenceNumber = currentValue
        case "OriginalGatewayTxnId": transactionSummary.originalTransactionId = currentValue
        case "AcctDataSrc": transactionSummary.accountDataSource = currentValue
        case "UniqueDeviceId": transactionSummary.uniqueDeviceId = currentValue
        case "EMVChipCondition": transactionSummary.emvChipCondition = currentValue
        case "HasEMVTag": transactionSummary.hasEmvTags = (currentValue as NSString).boolValue
        case "HasEComPaymentData": transactionSummary.hasEcomPaymentData = (currentValue as NSString).boolValue
        case "CAVVResultCode": transactionSummary.cavvResponseCode = currentValue
        case "TokenPANLast4": transactionSummary.tokenPanLastFour = currentValue
        case "Transactions":
            transactionReportSummary.transactions.append(transactionSummary)
            
        default: break
        }
    }
    
    public static func mapTransactionReportAdditionalTxnFields(_ elementName: String, _ currentValue: String, _ transactionReportAdditionalTxnFields: TransactionReportAdditionalTxnFields) {
        switch elementName {
        case "Description": transactionReportAdditionalTxnFields.description = currentValue
        case "InvoiceNbr": transactionReportAdditionalTxnFields.invoiceNbr = currentValue
        case "CustomerID": transactionReportAdditionalTxnFields.customerID = currentValue
        default: break
        }
    }
    
    public static func mapTransactionReportCardHolder(_ elementName: String, _ currentValue: String, _ transactionReportCardHolder: TransactionReportCardHolder) {
        switch elementName {
        case "CardHolderLastName": transactionReportCardHolder.cardHolderLastName = currentValue
        default: break
        }
    }
}


