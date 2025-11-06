import Foundation

public class PorticoResponseParser: NSObject {
    
    var transactionReportSummary = TransactionReportSummary()
    var transactionReportHeader: TransactionReportHeader?
    var transactionSummary: TransactionSummary?
    var transactionReportAdditionalTxnFields: TransactionReportAdditionalTxnFields?
    var transactionReportCardHolder: TransactionReportCardHolder?
    var currentElement = ""
    var currentValue: String = ""
    var isHeader = false
    var isTransactionSummary = false
    var isAdditionalTxnFields = false
    var isCardHolderData = false
}

extension PorticoResponseParser: XMLParserDelegate {
    
    public func parser(_ parser: XMLParser,
                       didStartElement elementName:
                       String, namespaceURI: String?,
                       qualifiedName qName: String?,
                       attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentValue = ""
        if elementName == "Header" {
            isHeader = true
            transactionReportHeader = TransactionReportHeader()
        } else if elementName == "Transactions" {
            isTransactionSummary = true
            transactionSummary = TransactionSummary()
        } else if elementName == "AdditionalTxnFields" {
            isAdditionalTxnFields = true
            transactionReportAdditionalTxnFields = TransactionReportAdditionalTxnFields()
        } else if elementName == "CardHolderData" {
            isCardHolderData = true
            transactionReportCardHolder = TransactionReportCardHolder()
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if isHeader {
            
            guard let header = transactionReportHeader else {
                return
            }
            PorticoApiMapping.mapTransactionReportHeader(elementName, currentValue, header, transactionReportSummary)
            isHeader = false
        } else if isTransactionSummary {
            
            guard let transactionSummary = transactionSummary else {
                return
            }
            PorticoApiMapping.mapTransactionReportSummary(elementName, currentValue, transactionSummary, transactionReportSummary)
            isTransactionSummary = false
        } else if isAdditionalTxnFields {
            
            guard let additionalTxnFields = transactionReportAdditionalTxnFields else {
                return
            }
            PorticoApiMapping.mapTransactionReportAdditionalTxnFields(elementName, currentValue, additionalTxnFields)
        } else if isCardHolderData {
            
            guard let reportCardHolder = transactionReportCardHolder else {
                return
            }
            PorticoApiMapping.mapTransactionReportCardHolder(elementName, currentValue, reportCardHolder)
        }
    }
}
