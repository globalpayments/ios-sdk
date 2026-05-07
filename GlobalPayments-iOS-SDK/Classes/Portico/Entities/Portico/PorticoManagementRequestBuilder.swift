//
//  PorticoManagementRequestBuilder.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Yashwant Patil on 11/03/26.
//

import Foundation

struct PorticoManagementRequestBuilder: PorticoRequestData {
    
    func generateRequest(for builder: ManagementBuilder, config: PorticoConfig) -> PorticoRequest? {
        guard let requestType = mapRequestType(builder) else { return nil }
        let requestXML = buildRequest(builder: builder, config: config, requestType: requestType)
        return PorticoRequest(
            endpoint: PorticoRequest.Endpoints.exchange(),
            method: .post,
            request: requestXML
        )
    }
    
     func mapRequestType(_ builder: ManagementBuilder) -> String? {
        let paymentMethodType = builder.paymentMethod?.paymentMethodType
        
        switch builder.transactionType {
        case .capture:
            if paymentMethodType == .credit {
                return "CreditAddToBatch"
            }
        case .reversal:
            if paymentMethodType == .credit {
                return "CreditReversal"
            }
            if paymentMethodType == .gift {
                return "GiftCardReversal"
            }
        case .edit:
            if paymentMethodType == .credit {
                if builder.transactionModifier == .levelII {
                    return "CreditCPCEdit"
                }
                return "CreditTxnEdit"
            }
        case .void:
            if paymentMethodType == .credit {
                return "CreditVoid"
            }
            if paymentMethodType == .gift {
                return "GiftCardVoid"
            }
        case .batchClose:
            return "BatchClose"
        case .refund:
            if paymentMethodType == .credit {
                return "CreditReturn"
            }
        default:
            break
        }
        return nil
    }

    // MARK: - Build XML Request

    private func buildRequest(builder: ManagementBuilder, config: PorticoConfig, requestType: String) -> String {
        var element: [XMLElementNode] = []

        if builder.transactionType != .batchClose {
            if let amount = builder.amount {
                element.append(XMLElementBuilder.element(name: "Amt", value: amount.stringValue))
            }

            if let authAmount = builder.authAmount {
                element.append(XMLElementBuilder.element(name: "AuthAmt", value: authAmount.stringValue))
            }

            if let gratuity = builder.gratuity {
                element.append(XMLElementBuilder.element(name: "GratuityAmtInfo", value: gratuity.stringValue))
            }

            if let transactionId = builder.transactionId, !transactionId.isEmpty {
                element.append(XMLElementBuilder.element(name: "GatewayTxnId", value: transactionId))
            }

            if let clientTransactionId = builder.clientTransactionId, !clientTransactionId.isEmpty {
                element.append(XMLElementBuilder.element(name: "ClientTxnId", value: clientTransactionId))
            }
        }

        if builder.transactionType == .edit && builder.transactionModifier == .levelII {
            var cpcDataElements: [XMLElementNode] = []
            
            if let poNumber = builder.poNumber, !poNumber.isEmpty {
                cpcDataElements.append(XMLElementBuilder.element(name: "CardHolderPONbr", value: poNumber))
            }
            
            if let taxType = builder.taxType {
                cpcDataElements.append(XMLElementBuilder.element(name: "TaxType", value: mapTaxType(taxType)))
            }
            
            if let taxAmount = builder.taxAmount {
                cpcDataElements.append(XMLElementBuilder.element(name: "TaxAmt", value: taxAmount.stringValue))
            }
            
            if !cpcDataElements.isEmpty {
                element.append(XMLElementBuilder.element(name: "CPCData", children: cpcDataElements))
            }
        } else if builder.transactionType == .edit && builder.surchargeAmtInfo != nil {
            if let gatewayTransactionId = builder.gatewayTransactionId, !gatewayTransactionId.isEmpty {
                element.append(XMLElementBuilder.element(name: "GatewayTxnId", value: gatewayTransactionId))
            }
            
            if let clientTransactionId = builder.clientTransactionId, !clientTransactionId.isEmpty {
                element.append(XMLElementBuilder.element(name: "ClientTxnId", value: clientTransactionId))
            }
            
            if let surchargeAmtInfo = builder.surchargeAmtInfo, !surchargeAmtInfo.isEmpty {
                element.append(XMLElementBuilder.element(name: "SurchargeAmtInfo", value: surchargeAmtInfo))
            }
        }

        if builder.transactionType == .refund || builder.transactionType == .reversal {
            let hasCustomerId = !(builder.customerId?.isEmpty ?? true)
            let hasDescription = !(builder.transactionDescription?.isEmpty ?? true)
            let hasInvoiceNumber = !(builder.invoiceNumber?.isEmpty ?? true)
            
            if hasCustomerId || hasDescription || hasInvoiceNumber {
                var txnFields: [XMLElementNode] = []
                if hasCustomerId {
                    txnFields.append(XMLElementBuilder.element(name: "CustomerID", value: builder.customerId!))
                }
                if hasDescription {
                    txnFields.append(XMLElementBuilder.element(name: "Description", value: builder.transactionDescription!))
                }
                if hasInvoiceNumber {
                    txnFields.append(XMLElementBuilder.element(name: "InvoiceNbr", value: builder.invoiceNumber!))
                }
                element.append(XMLElementBuilder.element(name: "AdditionalTxnFields", children: txnFields))
            }
        }

        if builder.transactionType == .reversal, let tagData = builder.tagData, !tagData.isEmpty {
            let tagValues = XMLElementBuilder.element(name: "TagValues", attributes: ["source": "chip"], value: tagData)
            element.append(XMLElementBuilder.element(name: "TagData", children: [tagValues]))
        }

        let root: XMLElementNode
        if builder.transactionType == .refund
            || builder.transactionType == .reversal
            || builder.paymentMethod?.paymentMethodType == .gift {
            let block1 = XMLElementBuilder.element(name: "Block1", children: element)
            root = XMLElementBuilder.element(name: requestType, children: [block1])
        } else {
            root = XMLElementBuilder.element(name: requestType, children: element)
        }

        let transaction = XMLElementBuilder.element(name: "Transaction", children: [root])
        let header = buildHeader(config: config, clientTransactionId: builder.clientTransactionId)
        return buildEnvelope(header: header, transaction: transaction)
    }

    private func mapTaxType(_ taxType: TaxType) -> String {
        switch taxType {
        case .notUsed:
            return "NOTUSED"
        case .salesTax:
            return "SALESTAX"
        case .taxExempt:
            return "TAXEXEMPT"
        }
    }

    // MARK: - Build Header

    private func buildHeader(config: PorticoConfig, clientTransactionId: String?) -> XMLElementNode {
        var elements: [XMLElementNode] = []

        if let clientTxnId = clientTransactionId, !clientTxnId.isEmpty {
            elements.append(XMLElementBuilder.element(name: "ClientTxnId", value: clientTxnId))
        }

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
