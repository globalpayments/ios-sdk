//
//  PorticoXmlResponseParser.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Ranu Dhurandhar on 11/03/26.
//

import Foundation

class PorticoXmlResponseParser: NSObject, XMLParserDelegate {
    var parser: XMLParser?
    var currentElement: String?
    var gatewayResponseCode: String?
    var gatewayResponseMessage: String?
    var serviceName: String?
    var transaction: Transaction?
    var singleReport: TransactionSummary?
    var listReport: [TransactionSummary]?
    var requestType: String?
    var gatewayTransactionId: String?
    var currentTransactionType: String?
    
    init(xml: String) {
        super.init()
        if let data = xml.data(using: .utf8) {
            self.parser = XMLParser(data: data)
            self.parser?.delegate = self
        }
    }
    
    // MARK: - Helpers
    private func decimal(from string: String?) -> NSDecimalNumber? {
        guard let s = string?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        // Remove any currency formatting or commas if present
        let normalized = s.replacingOccurrences(of: ",", with: "")
        let number = NSDecimalNumber(string: normalized)
        if number == NSDecimalNumber.notANumber { return nil }
        return number
    }

    private func date(from string: String?) -> Date? {
        guard let s = string?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        // Try a few common formats used by Portico
        let fmts = [
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd HH:mm:ss",
            "MM/dd/yyyy HH:mm:ss",
            "yyyy-MM-dd"
        ]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for fmt in fmts {
            formatter.dateFormat = fmt
            if let d = formatter.date(from: s) { return d }
        }
        return nil
    }
    
    func parse(requestType: String) -> Bool {
        
        self.requestType = requestType
        
        if requestType == "ReportTxnDetail" {
            self.singleReport = TransactionSummary()
        } else if requestType == "FindTransactions" {
            self.listReport = []
        } else {
            self.transaction = Transaction()
        }
        
        return self.parser?.parse() ?? false
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if listReport != nil && elementName == "Transactions" {
            self.singleReport = TransactionSummary()
        }
        
        if PorticoTransactionTypes.contains(elementName) {
            currentTransactionType = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == nil {
            currentElement = ""
        }
        currentElement? += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if listReport != nil {
            handleListReportElement(elementName: elementName)
        } else if singleReport != nil {
            handleSingleReportElement(elementName: elementName)
        } else {
            handleTransactionElement(elementName: elementName)
        }
        
        currentElement = nil
    }
    
    private func handleListReportElement(elementName: String) {
        handleSingleReportElement(elementName: elementName)
        
        if listReport != nil && elementName == "Transactions", let singleReport = singleReport {
            listReport?.append(singleReport)
            self.singleReport = nil
        }
    }
    
    private func handleSingleReportElement(elementName: String) {
        switch elementName {
        case "AccDataSrc":
            singleReport?.accountDataSource = currentElement
        case "Amt":
            singleReport?.amount = currentElement?.toNSDecimalNumber
        case "AuthCode":
            singleReport?.authCode = currentElement
        case "AuthAmt":
            singleReport?.authorizedAmount = currentElement?.toNSDecimalNumber
        case "BatchCloseDT":
            singleReport?.batchCloseDate = date(from: currentElement)
        case "BatchSeqNbr":
            singleReport?.batchSequenceNumber = currentElement
        case "CaptureAmtInfo":
            singleReport?.captureAmount = currentElement?.toNSDecimalNumber
        case "CardSwiped":
            singleReport?.cardSwiped = currentElement
        case "CardType":
            singleReport?.cardType = currentElement
        case "CAVVResultCode":
            singleReport?.cavvResponseCode = currentElement
        case "ClerkID":
            singleReport?.clerkId = currentElement
        case "ClientTxnId":
            singleReport?.clientTransactionId = currentElement
        case "Company":
            singleReport?.companyName = currentElement
        case "ConvenienceAmtInfo":
            singleReport?.convenienceAmount = currentElement?.toNSDecimalNumber
        case "CustomerFirstname":
            singleReport?.customerFirstName = currentElement
        case "CustomerID":
            singleReport?.customerId = currentElement
        case "CustomerLastname":
            singleReport?.customerLastName = currentElement
        case "DebtRepaymentIndicator":
            singleReport?.debtRepaymentIndicator = (currentElement == "Y")
        case "Description":
            singleReport?.transactionDescription = currentElement
        case "EMVChipCondition":
            singleReport?.emvChipCondition = currentElement
        case "EMVIssuerResp":
            singleReport?.emvIssuerResponse = currentElement
        case "FraudInfoRule":
            singleReport?.fraudRuleInfo = currentElement
        case "FullyCapturedInd":
            singleReport?.fullyCaptured = (currentElement == "Y")
        case "GatewayRspCode":
            singleReport?.gatewayResponseCode = currentElement
        case "GatewayRspMsg":
            singleReport?.gatewayResponseMessage = currentElement
        case "GiftCurrency":
            singleReport?.giftCurrency = currentElement
        case "GratuityAmtInfo":
            singleReport?.gratuityAmount = currentElement?.toNSDecimalNumber
        case "HasEMVTag":
            singleReport?.hasEmvTags = (currentElement == "Y")
        case "HasEComPaymentData":
            singleReport?.hasEcomPaymentData = (currentElement == "Y")
        case "InvoiceNbr":
            singleReport?.invoiceNumber = currentElement
        case "IssuerRspCode", "RspCode":
            singleReport?.issuerResponseCode = currentElement
        case "IssuerRspText", "RspText":
            singleReport?.issuerResponseMessage = currentElement
        case "IssTxnId":
            singleReport?.issuerTransactionId = currentElement
        case "GiftMaskedAlias":
            singleReport?.maskedAlias = currentElement
        case "MaskedCardNbr":
            singleReport?.maskedCardNumber = currentElement
        case "OneTime":
            singleReport?.oneTimePayment = (currentElement == "Y")
        case "OriginalGatewayTxnId":
            singleReport?.originalTransactionId = currentElement
        case "PaymentMethodKey":
            singleReport?.paymentMethodKey = currentElement
        case "PaymentType":
            singleReport?.paymentType = currentElement
        case "CardHolderPONbr":
            singleReport?.poNumber = currentElement
        case "RecurringDataCode":
            singleReport?.recurringDataCode = currentElement
        case "RefNbr":
            singleReport?.referenceNumber = currentElement
        case "RspDT":
            singleReport?.responseDate = date(from: currentElement)
        case "ScheduleID":
            singleReport?.scheduleId = currentElement
        case "ServiceName":
            singleReport?.serviceName = currentElement
        case "SettlementAmt":
            singleReport?.settlementAmount = currentElement?.toNSDecimalNumber
        case "ShippingAmtInfo":
            singleReport?.shippingAmount = currentElement?.toNSDecimalNumber
        case "Status", "TxnStatus":
            singleReport?.status = currentElement
        case "SurchargeAmtInfo":
            singleReport?.surchargeAmount = currentElement?.toNSDecimalNumber
        case "TaxType":
            singleReport?.taxType = currentElement
        case "TokenPANLast4":
            singleReport?.tokenPanLastFour = currentElement
        case "TxnUtcDT", "ReqUtcDT":
            singleReport?.transactionDate = date(from: currentElement)
        case "TxnDescriptor":
            singleReport?.transactionDescriptor = currentElement
        case "GatewayTxnId":
            singleReport?.transactionId = currentElement
        case "UniqueDeviceId":
            singleReport?.uniqueDeviceId = currentElement
        case "UserName":
            singleReport?.username = currentElement
        case "CardHolderFirstName":
            singleReport?.cardHolderFirstName = currentElement
        case "CardHolderLastName":
            singleReport?.cardHolderLastName = currentElement
        case "CardHolderAddr":
            ensureBillingAddressExists()
            singleReport?.billingAddress?.streetAddress1 = currentElement
        case "CardHolderCity":
            ensureBillingAddressExists()
            singleReport?.billingAddress?.city = currentElement
        case "CardHolderState":
            ensureBillingAddressExists()
            singleReport?.billingAddress?.state = currentElement
        case "CardHolderZip":
            ensureBillingAddressExists()
            singleReport?.billingAddress?.postalCode = currentElement
        case "DeviceId":
            singleReport?.deviceId = currentElement?.toInt
        default:
            break
        }
    }
    
    private func handleTransactionElement(elementName: String) {
        switch elementName {
        case "GatewayRspCode":
            gatewayResponseCode = currentElement ?? ""
        case "GatewayRspMsg":
            gatewayResponseMessage = currentElement ?? ""
        case "AuthAmt":
            transaction?.authorizedAmount = decimal(from: currentElement)
        case "AvailableBalance":
            transaction?.availableBalance = decimal(from: currentElement)
        case "AVSRsltCode":
            transaction?.avsResponseCode = currentElement ?? ""
        case "AVSRsltText":
            transaction?.avsResponseMessage = currentElement ?? ""
        case "BalanceAmt":
            transaction?.balanceAmount = decimal(from: currentElement)
        case "CardType":
            transaction?.cardType = currentElement ?? ""
        case "TokenPANLast4":
            transaction?.cardLast4 = currentElement ?? ""
        case "CAVVResultCode":
            transaction?.cavvResponseCode = currentElement ?? ""
        case "CPCInd":
            transaction?.commercialIndicator = currentElement ?? ""
        case "CVVRsltCode":
            transaction?.cvnResponseCode = currentElement ?? ""
        case "CVVRsltText":
            transaction?.cvnResponseMessage = currentElement ?? ""
        case "EMVIssuerResp":
            transaction?.emvIssuerResponse = currentElement ?? ""
        case "PointsBalanceAmt":
            transaction?.pointsBalanceAmount = decimal(from: currentElement)
        case "RecurringDataCode":
            transaction?.recurringDataCode = currentElement ?? ""
        case "RefNbr":
            transaction?.referenceNumber = currentElement ?? ""
        case "RspCode":
            transaction?.responseCode = currentElement ?? ""
        case "RspText":
            transaction?.responseMessage = currentElement ?? ""
        case "TxnDescriptor":
            transaction?.transactionDescriptor = currentElement ?? ""
        case "HostRspDT":
            transaction?.hostResponseDate = date(from: currentElement)
        case "GatewayTxnId":
            if transaction?.transactionReference == nil {
                transaction?.transactionReference = TransactionReference()
            }
            transaction?.transactionReference?.transactionId = currentElement
        case "AuthCode":
            if transaction?.transactionReference == nil {
                transaction?.transactionReference = TransactionReference()
            }
            transaction?.transactionReference?.authCode = currentElement
        case "CardData":
            transaction?.giftCard = GiftCard()
        case "CardNbr":
            (transaction?.giftCard as? GiftCard)?.number = currentElement
        case "Alias":
            (transaction?.giftCard as? GiftCard)?.alias = currentElement
        case "PIN":
            (transaction?.giftCard as? GiftCard)?.pin = currentElement
        case "TokenValue":
            transaction?.token = currentElement ?? ""
        case "OriginalGatewayTxnId":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.transactionId = currentElement
        case "OriginalRspDT":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.hostResponseDate = currentElement
        case "OriginalClientTxnId":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.clientTransactionId = currentElement
        case "OriginalUniqueDeviceId":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.uniqueDeviceId = currentElement
        case "Originalx_global_transaction_id":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.globalTransactionId = currentElement
        case "OriginalAuthCode":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.authorizationCode = currentElement
        case "OriginalRefNbr":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.referenceNumber = currentElement
        case "OriginalAuthAmt":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.authorizedAmount = currentElement
        case "OriginalCardType":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.cardType = currentElement
        case "OriginalCardNbrLast4":
            ensureDuplicateDataExists()
            transaction?.duplicateData?.cardLast4 = currentElement
        case "IsSurchargeable":
            transaction?.isSurchargeable = currentElement ?? ""
        case "SurchargeAmtInfo":
            transaction?.surchargeAmtInfo = currentElement ?? ""
        case "BankResponseCode":
            transaction?.bankRespCode = currentElement ?? ""
        case "CreditAccountVerify":
            if let txnType = currentTransactionType {
                transaction?.serviceName = txnType
            }
        case "CreditAuth", "CreditSale", "CreditCPCEdit",
            "CreditAddToBatch", "CreditReturn", "CreditTxnEdit",
            "CreditReversal", "GiftCardSale", "CreditVoid":
            transaction?.serviceName = currentTransactionType ?? ""
            
        case "ChipCardDecline":
            transaction?.serviceName = currentTransactionType ?? ""
            
        default:
            break
        }
    }
    
    private func ensureDuplicateDataExists() {
        if transaction?.duplicateData == nil {
            transaction?.duplicateData = PorticoDuplicateData()
        }
    }
    
    private func ensureBillingAddressExists() {
        if singleReport?.billingAddress == nil {
            singleReport?.billingAddress = Address()
        }
    }
}
