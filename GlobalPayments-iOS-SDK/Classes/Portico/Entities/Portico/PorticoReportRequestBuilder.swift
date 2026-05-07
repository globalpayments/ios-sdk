//
//  PorticoReportRequestBuilder.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Yashwant Patil on 30/03/26.
//

import Foundation

struct PorticoReportRequestBuilder<T>: PorticoRequestData {

    func generateRequest(for builder: TransactionReportBuilder<T>, config: PorticoConfig) -> PorticoRequest? {
        guard let requestType = mapRequestType(builder) else { return nil }
        let requestXML = buildRequest(builder: builder, config: config, requestType: requestType)
        return PorticoRequest(
            endpoint: PorticoRequest.Endpoints.exchange(),
            method: .post,
            request: requestXML
        )
    }

    func mapRequestType(_ builder: TransactionReportBuilder<T>) -> String? {
        switch builder.reportType {
        case .findTransactions:
            return "FindTransactions"
        case .transactionDetail:
            return "ReportTxnDetail"
        case .activity:
            return "TransactionDetail"
        case .batchDetail:
            return "ReportBatchDetail"
        case .openAuths:
            return "ReportOpenAuths"
        default:
            return nil
        }
    }

    // MARK: - Build XML Request

    private func buildRequest(builder: TransactionReportBuilder<T>, config: PorticoConfig, requestType: String) -> String {
        let reportType = builder.reportType
        var element: [XMLElementNode] = []

        if reportType == .transactionDetail {
            if let txnId = builder.transactionId, !txnId.isEmpty {
                element.append(XMLElementBuilder.element(name: "TxnId", value: txnId))
            }
        }

        if reportType == .findTransactions || reportType == .activity {
            var criteriaElements: [XMLElementNode] = []
            criteriaElements.append(XMLElementBuilder.element(name: "StartUtcDT", value: builder.searchCriteriaBuilder.startDate?.stringFromDateWithMilliseconds("YYYY-MM-dd'T'HH:mm:ss.SSS'Z'")))
            criteriaElements.append(XMLElementBuilder.element(name: "EndUtcDT", value: builder.searchCriteriaBuilder.endDate?.stringFromDateWithMilliseconds("YYYY-MM-dd'T'HH:mm:ss.SSS'Z'")))
            criteriaElements.append(XMLElementBuilder.element(name: "AuthCode", value: builder.searchCriteriaBuilder.authCode))
            criteriaElements.append(XMLElementBuilder.element(name: "CardHolderLastName", value: builder.searchCriteriaBuilder.cardHolderLastName))
            criteriaElements.append(XMLElementBuilder.element(name: "CardHolderFirstName", value: builder.searchCriteriaBuilder.cardHolderFirstName))
            criteriaElements.append(XMLElementBuilder.element(name: "CardNbrFirstSix", value: builder.searchCriteriaBuilder.cardNumberFirstSix))
            criteriaElements.append(XMLElementBuilder.element(name: "CardNbrLastFour", value: builder.searchCriteriaBuilder.cardNumberLastFour))
            criteriaElements.append(XMLElementBuilder.element(name: "InvoiceNbr", value: builder.searchCriteriaBuilder.invoiceNumber))
            criteriaElements.append(XMLElementBuilder.element(name: "CardHolderPONbr", value: builder.searchCriteriaBuilder.cardHolderPoNumber))
            criteriaElements.append(XMLElementBuilder.element(name: "CustomerID", value: builder.searchCriteriaBuilder.customerId))
            criteriaElements.append(XMLElementBuilder.element(name: "IssuerResult", value: builder.searchCriteriaBuilder.issuerResult))
            criteriaElements.append(XMLElementBuilder.element(name: "SettlementAmt", value: builder.searchCriteriaBuilder.settlementAmount))
            criteriaElements.append(XMLElementBuilder.element(name: "IssTxnId", value: builder.searchCriteriaBuilder.issuerTransactionId))
            criteriaElements.append(XMLElementBuilder.element(name: "RefNbr", value: builder.searchCriteriaBuilder.referenceNumber))
            criteriaElements.append(XMLElementBuilder.element(name: "UserName", value: builder.searchCriteriaBuilder.username))
            criteriaElements.append(XMLElementBuilder.element(name: "ClerkID", value: builder.searchCriteriaBuilder.clerkId))
            criteriaElements.append(XMLElementBuilder.element(name: "BatchSeqNbr", value: builder.searchCriteriaBuilder.batchSequenceNumber))
            criteriaElements.append(XMLElementBuilder.element(name: "BatchId", value: builder.searchCriteriaBuilder.batchId))
            criteriaElements.append(XMLElementBuilder.element(name: "SiteTrace", value: builder.searchCriteriaBuilder.siteTrace))
            criteriaElements.append(XMLElementBuilder.element(name: "DisplayName", value: builder.searchCriteriaBuilder.displayName))
            criteriaElements.append(XMLElementBuilder.element(name: "ClientTxnId", value: builder.searchCriteriaBuilder.clientTransactionId))
            criteriaElements.append(XMLElementBuilder.element(name: "UniqueDeviceId", value: builder.searchCriteriaBuilder.uniqueDeviceId))
            criteriaElements.append(XMLElementBuilder.element(name: "AcctNbrLastFour", value: builder.searchCriteriaBuilder.accountNumberLastFour))
            criteriaElements.append(XMLElementBuilder.element(name: "BankRountingNbr", value: builder.searchCriteriaBuilder.bankRoutingNumber))
            criteriaElements.append(XMLElementBuilder.element(name: "CheckNbr", value: builder.searchCriteriaBuilder.checkNumber))
            criteriaElements.append(XMLElementBuilder.element(name: "CheckFirstName", value: builder.searchCriteriaBuilder.checkFirstName))
            criteriaElements.append(XMLElementBuilder.element(name: "CheckLastName", value: builder.searchCriteriaBuilder.checkLastName))
            criteriaElements.append(XMLElementBuilder.element(name: "CheckName", value: builder.searchCriteriaBuilder.checkName))
            criteriaElements.append(XMLElementBuilder.element(name: "GiftCurrency", value: builder.searchCriteriaBuilder.giftCurrency))
            criteriaElements.append(XMLElementBuilder.element(name: "GiftMaskedAlias", value: builder.searchCriteriaBuilder.giftMaskedAlias))
            criteriaElements.append(XMLElementBuilder.element(name: "OneTime", value: builder.searchCriteriaBuilder.oneTime))
            criteriaElements.append(XMLElementBuilder.element(name: "PaymentMethodKey", value: builder.searchCriteriaBuilder.paymentMethodKey))
            criteriaElements.append(XMLElementBuilder.element(name: "ScheduleID", value: builder.searchCriteriaBuilder.scheduleId))
            criteriaElements.append(XMLElementBuilder.element(name: "BuyerEmailAddress", value: builder.searchCriteriaBuilder.buyerEmailAddress))
            criteriaElements.append(XMLElementBuilder.element(name: "AltPaymentStatus", value: builder.searchCriteriaBuilder.altPaymentStatus))
            criteriaElements.append(XMLElementBuilder.element(name: "FullyCapturedInd", value: builder.searchCriteriaBuilder.fullyCaptured))
            let filteredCriteria = criteriaElements.filter { $0.value != nil || !$0.children.isEmpty }
            let criteriaNode: XMLElementNode = filteredCriteria.isEmpty
                ? XMLElementBuilder.element(name: "Criteria",
                                    children: [XMLElementBuilder.element(name: "ClientTxnId", value: builder.transactionId)])
                : XMLElementBuilder.element(name: "Criteria", children: filteredCriteria)
            element.append(criteriaNode)
        }

        if reportType == .activity || reportType == .openAuths || reportType == .batchDetail {
            if let timeZone = builder.timeZoneConversion {
                element.append(XMLElementBuilder.element(name: "TzConversion", value: timeZone))
            }
        }

        if reportType == .openAuths || reportType == .batchDetail {
            if let deviceId = builder.deviceId, !deviceId.isEmpty {
                element.append(XMLElementBuilder.element(name: "DeviceId", value: deviceId))
            }
        }

        if reportType == .batchDetail {
            if let batchId = builder.searchCriteriaBuilder.batchId, !batchId.isEmpty {
                element.append(XMLElementBuilder.element(name: "BatchId", value: batchId))
            }
        }

        let root = XMLElementBuilder.element(name: requestType, children: element)
        let transaction = XMLElementBuilder.element(name: "Transaction", children: [root])
        let header = buildHeader(config: config, clientTransactionId: nil)
        return buildEnvelope(header: header, transaction: transaction)
    }

    // MARK: - Build Header

    private func buildHeader(config: PorticoConfig, clientTransactionId: String?) -> XMLElementNode {
        var elements: [XMLElementNode] = []

        if let secretKey = config.secretApiKey, !secretKey.isEmpty {
            elements.append(XMLElementBuilder.element(name: "SecretAPIKey", value: secretKey))
        } else {
            if let username = config.username {
                elements.append(XMLElementBuilder.element(name: "UserName", value: username))
            }
            if let password = config.password {
                elements.append(XMLElementBuilder.element(name: "Password", value: password))
            }
            if let siteId = config.siteId {
                elements.append(XMLElementBuilder.element(name: "SiteId", value: siteId))
            }
            if let deviceId = config.deviceId {
                elements.append(XMLElementBuilder.element(name: "DeviceId", value: deviceId))
            }
            if let licenseId = config.licenseId {
                elements.append(XMLElementBuilder.element(name: "LicenseId", value: licenseId))
            }
        }

        if let clientTxnId = clientTransactionId, !clientTxnId.isEmpty {
            elements.append(XMLElementBuilder.element(name: "ClientTxnId", value: clientTxnId))
        }

        if let developerId = config.developerId, !developerId.isEmpty {
            elements.append(XMLElementBuilder.element(name: "DeveloperID", value: developerId))
        }
        if let versionNumber = config.versionNumber, !versionNumber.isEmpty {
            elements.append(XMLElementBuilder.element(name: "VersionNbr", value: versionNumber))
        }
        
        if let sdkNameVersion = config.sdkNameVersion, !sdkNameVersion.isEmpty {
            elements.append(XMLElementBuilder.element(name: "SDKNameVersion", value: sdkNameVersion))
        }
        return XMLElementBuilder.element(name: "Header", children: elements)
    }

    // MARK: - Build Envelope
    
    private func buildEnvelope(header: XMLElementNode, transaction: XMLElementNode) -> String {
        let ver10 = XMLElementNode(name: "Ver1.0", children: [header, transaction])
        let posRequest = XMLElementBuilder.element(name: "PosRequest", children: [ver10])
        return SOAPDOMBuilder()
            .with(body: posRequest)
            .build()
    }
}
