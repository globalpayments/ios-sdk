import Foundation

struct PorticoReportRequestBuilder<T> {
    
    func generateRequest(for builder: ReportBuilder<T>, config: PorticoConfig?, porticoConfigData: PorticoConfigData) -> PorticoRequest? {
        
        if let builder = builder as? TransactionReportBuilder {
            return handleTransationProcessReportCases(builder, config: config, merchantUrl: "", porticoConfigData: porticoConfigData)
        } else {
            return nil
        }
    }
    
    private func handleTransationProcessReportCases(_ builder: TransactionReportBuilder<T>, config: PorticoConfig?, merchantUrl: String, porticoConfigData: PorticoConfigData) -> PorticoRequest? {
        
        switch builder.reportType {
        case .findTransactions:
            let reportType = builder.reportType
            let transactionType = XMLElementTree(name: mapReportType(builder.reportType))
            
            let envelope = XMLElementTree(
                name: "soap:Envelope",
                attributes: ["xmlns:soap": "http://schemas.xmlsoap.org/soap/envelope/"]
            )
            
            let body = XMLElementTree(name: "soap:Body")
            envelope.addChild(body)
            
            let posRequest = XMLElementTree(
                name: "PosRequest",
                attributes: ["xmlns": "http://Hps.Exchange.PosGateway"]
            )
            body.addChild(posRequest)
            
            let ver = XMLElementTree(name: "Ver1.0")
            posRequest.addChild(ver)
            
            let header = XMLElementTree(name: "Header")
            ver.addChild(header)
            header.addChild(XMLElementTree(name: "SecretAPIKey", value: porticoConfigData.secretApiKey))
            header.addChild(XMLElementTree(name: "SiteId", value: porticoConfigData.siteId))
            header.addChild(XMLElementTree(name: "LicenseId", value: porticoConfigData.licenseId))
            header.addChild(XMLElementTree(name: "DeviceId", value: porticoConfigData.deviceId))
            header.addChild(XMLElementTree(name: "UserName", value: porticoConfigData.username))
            header.addChild(XMLElementTree(name: "Password", value: porticoConfigData.password))
            header.addChild(XMLElementTree(name: "DeveloperID", value: porticoConfigData.developerId))
            header.addChild(XMLElementTree(name: "VersionNbr", value: porticoConfigData.versionNumber))
            header.addChild(XMLElementTree(name: "ClientTxnId", value: builder.transactionId))
            header.addChild(XMLElementTree(name: "PosReqDT", value: Date().stringFromDateWithMilliseconds("YYYY-MM-dd'T'HH:mm:ss.SSS'Z'")))
            header.addChild(XMLElementTree(name: "UniqueDeviceId", value: porticoConfigData.uniqueDeviceId))
            header.addChild(XMLElementTree(name: "SDKNameVersion", value: "iOS;version=" + getVersionSDK()))
            
            if porticoConfigData.IsSafDataSupported != nil {
                let safData = XMLElementTree(name: "SAFData")
                if let isSafDateSupport  = porticoConfigData.IsSafDataSupported  {
                    safData.addChild(XMLElementTree(name: "SAFIndicator", value: isSafDateSupport))
                }
                safData.addChild(XMLElementTree(name: "SAFOrigDT", value: Date().stringFromDateWithMilliseconds("YYYY-MM-dd'T'HH:mm:ss.SSS'Z'")))
                header.addChild(safData)
            }
            
            let transaction = XMLElementTree(name: "Transaction")
            ver.addChild(transaction)
            
            let findTransactions = XMLElementTree(name: "FindTransactions")
            transaction.addChild(findTransactions)
            
            if (reportType == .findTransactions || reportType == .transactionDetail) {
                transactionType.addChild(XMLElementTree(name: "TxnID", value: builder.transactionId))
                print("findTransactions || transactionDetail")
            }
            
            if (reportType == .findTransactions || reportType == .activity) {
                let criteria = XMLElementTree(name: "Criteria")
                findTransactions.addChild(criteria)
                criteria.addChild(XMLElementTree(name: "StartUtcDT", value: builder.searchCriteriaBuilder.startDate?.stringFromDateWithMilliseconds("YYYY-MM-dd'T'HH:mm:ss.SSS'Z'")))
                criteria.addChild(XMLElementTree(name: "EndUtcDT", value: builder.searchCriteriaBuilder.endDate?.stringFromDateWithMilliseconds("YYYY-MM-dd'T'HH:mm:ss.SSS'Z'")))
                criteria.addChild(XMLElementTree(name: "AuthCode", value: builder.searchCriteriaBuilder.authCode))
                criteria.addChild(XMLElementTree(name: "CardHolderLastName", value: builder.searchCriteriaBuilder.cardHolderLastName))
                criteria.addChild(XMLElementTree(name: "CardHolderFirstName", value: builder.searchCriteriaBuilder.cardHolderFirstName))
                criteria.addChild(XMLElementTree(name: "CardNbrFirstSix", value: builder.searchCriteriaBuilder.cardNumberFirstSix))
                criteria.addChild(XMLElementTree(name: "CardNbrLastFour", value: builder.searchCriteriaBuilder.cardNumberLastFour))
                criteria.addChild(XMLElementTree(name: "InvoiceNbr", value: builder.searchCriteriaBuilder.invoiceNumber))
                criteria.addChild(XMLElementTree(name: "CardHolderPONbr", value: builder.searchCriteriaBuilder.cardHolderPoNumber))
                criteria.addChild(XMLElementTree(name: "CustomerID", value: builder.searchCriteriaBuilder.customerId))
                criteria.addChild(XMLElementTree(name: "IssuerResult", value: builder.searchCriteriaBuilder.issuerResult))
                criteria.addChild(XMLElementTree(name: "SettlementAmt", value: builder.searchCriteriaBuilder.settlementAmount))
                criteria.addChild(XMLElementTree(name: "IssTxnId", value: builder.searchCriteriaBuilder.issuerTransactionId))
                criteria.addChild(XMLElementTree(name: "RefNbr", value: builder.searchCriteriaBuilder.referenceNumber))
                criteria.addChild(XMLElementTree(name: "UserName", value: builder.searchCriteriaBuilder.username))
                criteria.addChild(XMLElementTree(name: "ClerkID", value: builder.searchCriteriaBuilder.clerkId))
                criteria.addChild(XMLElementTree(name: "BatchSeqNbr", value: builder.searchCriteriaBuilder.batchSequenceNumber))
                criteria.addChild(XMLElementTree(name: "BatchId", value: builder.searchCriteriaBuilder.batchId))
                criteria.addChild(XMLElementTree(name: "SiteTrace", value: builder.searchCriteriaBuilder.siteTrace))
                criteria.addChild(XMLElementTree(name: "DisplayName", value: builder.searchCriteriaBuilder.displayName))
                criteria.addChild(XMLElementTree(name: "ClientTxnId", value: builder.searchCriteriaBuilder.clientTransactionId))
                criteria.addChild(XMLElementTree(name: "UniqueDeviceId", value: builder.searchCriteriaBuilder.uniqueDeviceId))
                criteria.addChild(XMLElementTree(name: "AcctNbrLastFour", value: builder.searchCriteriaBuilder.accountNumberLastFour))
                criteria.addChild(XMLElementTree(name: "BankRountingNbr", value: builder.searchCriteriaBuilder.bankRoutingNumber))
                criteria.addChild(XMLElementTree(name: "CheckNbr", value: builder.searchCriteriaBuilder.checkNumber))
                criteria.addChild(XMLElementTree(name: "CheckFirstName", value: builder.searchCriteriaBuilder.checkFirstName))
                criteria.addChild(XMLElementTree(name: "CheckLastName", value: builder.searchCriteriaBuilder.checkLastName))
                criteria.addChild(XMLElementTree(name: "CheckName", value: builder.searchCriteriaBuilder.checkName))
                criteria.addChild(XMLElementTree(name: "GiftCurrency", value: builder.searchCriteriaBuilder.giftCurrency))
                criteria.addChild(XMLElementTree(name: "GiftMaskedAlias", value: builder.searchCriteriaBuilder.giftMaskedAlias))
                criteria.addChild(XMLElementTree(name: "OneTime", value: builder.searchCriteriaBuilder.oneTime))
                criteria.addChild(XMLElementTree(name: "PaymentMethodKey", value: builder.searchCriteriaBuilder.paymentMethodKey))
                criteria.addChild(XMLElementTree(name: "ScheduleID", value: builder.searchCriteriaBuilder.scheduleId))
                criteria.addChild(XMLElementTree(name: "BuyerEmailAddress", value: builder.searchCriteriaBuilder.buyerEmailAddress))
                criteria.addChild(XMLElementTree(name: "AltPaymentStatus", value: builder.searchCriteriaBuilder.altPaymentStatus))
                criteria.addChild(XMLElementTree(name: "FullyCapturedInd", value: builder.searchCriteriaBuilder.fullyCaptured))
            }
            
            if (reportType == .activity || reportType == .openAuths || reportType == .  batchDetail) {
                if let timeZone = builder.timeZoneConversion {
                    transactionType.addChild(XMLElementTree(name: "TzConversion", value: timeZone))
                }
            }
            
            if (reportType == .openAuths || reportType == .batchDetail) {
                transactionType.addChild(XMLElementTree(name: "DeviceId", value: builder.deviceId))
            }
            
            if (reportType == .batchDetail) {
                transactionType.addChild(XMLElementTree(name: "BatchId", value: builder.searchCriteriaBuilder.batchId))
            }
            
            let request = envelope.toXMLString(includeXMLDeclaration: true, encoding: "utf-8", standalone: "no")
            
            return PorticoRequest(
                endpoint: PorticoRequest.Endpoints.exchange(),
                method: .post,
                request: request)
            
        default:
            return nil
        }
    }
    
    func mapReportType(_ type: ReportType) -> String {
        switch type {
        case .activity, .findTransactions:
            return "TransactionDetail"
        case .transactionDetail:
            return "ReportTxnDetail"
        case .batchDetail:
            return "ReportBatchDetail"
        case .openAuths:
            return "ReportOpenAuths"
        default:
            return ""
        }
    }
    
    private func getVersionSDK() -> String {
        guard let version = Bundle(identifier: "org.cocoapods.GlobalPayments-iOS-SDK")?.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return version
    }
}
