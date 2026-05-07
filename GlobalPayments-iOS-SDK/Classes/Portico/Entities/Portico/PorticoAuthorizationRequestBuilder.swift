//
//  PorticoAuthorizationRequestBuilder.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Yashwant Patil on 18/02/26.
//

import Foundation

struct PorticoAuthorizationRequestBuilder: PorticoRequestData {
    
    func generateRequest(for builder: AuthorizationBuilder, config: PorticoConfig) -> PorticoRequest? {
        guard let requestType = mapRequestType(builder) else { return nil }
        let requestXML = try? buildRequest(builder: builder, config: config, requestType: requestType)
        return PorticoRequest(
            endpoint: PorticoRequest.Endpoints.exchange(),
            method: .post,
            request: requestXML
        )
    }
    
     func mapRequestType(_ builder: AuthorizationBuilder) -> String? {
        switch builder.transactionType {
        case .auth:
            guard builder.paymentMethod?.paymentMethodType == .credit else { return nil }
            switch builder.transactionModifier {
            case .additional:
                return "CreditAdditionalAuth"
            case .incremental:
                return "CreditIncrementalAuth"
            case .offline:
                return "CreditOfflineAuth"
            default:
                return "CreditAuth"
            }
        case .sale:
            if builder.paymentMethod?.paymentMethodType == .credit {
                switch builder.transactionModifier {
                case .offline:
                    return "CreditOfflineSale"
                case .recurring:
                    return "RecurringBilling"
                default:
                    return "CreditSale"
                }
            }
            if builder.paymentMethod?.paymentMethodType == .gift {
                return "GiftCardSale"
            }
        case .reversal:
            if builder.paymentMethod?.paymentMethodType == .credit {
                return "CreditReversal"
            }
        case .verify:
            if builder.paymentMethod?.paymentMethodType == .credit {
                return "CreditAccountVerify"
            }
        case .decline:
            if builder.transactionModifier == .chipDecline {
                return "ChipCardDecline"
            }
        case .refund:
            if builder.paymentMethod?.paymentMethodType == .credit {
                return "CreditReturn"
            }
        case .addValue:
            if builder.paymentMethod?.paymentMethodType == .gift {
                return "GiftCardAddValue"
            }
        case .balance:
            if builder.paymentMethod?.paymentMethodType == .gift {
                return "GiftCardBalanceInquiry"
            }
        case .activate:
            if builder.paymentMethod?.paymentMethodType == .gift {
                return "GiftCardActivate"
            }
        case .alias:
            if builder.paymentMethod?.paymentMethodType == .gift {
                return "GiftCardAlias"
            }
        case .replace:
            if builder.paymentMethod?.paymentMethodType == .gift {
                return "GiftCardReplace"
            }
        case .reward:
            if builder.paymentMethod?.paymentMethodType == .gift {
                return "GiftCardRedeem"
            }
        case .deactivate:
            if builder.paymentMethod?.paymentMethodType == .gift {
                return "GiftCardDeactivate"
            }
        case .capture:
            if builder.paymentMethod?.paymentMethodType == .credit {
                return "CreditAddToBatch"
            }
        default:
            break
        }
        return nil
    }

    // MARK: - Build XML Request

    private func buildRequest(builder: AuthorizationBuilder, config: PorticoConfig, requestType: String) throws -> String {
        var element: [XMLElementNode] = []

        if builder.transactionType != .verify {
            
            if (builder.transactionType == .auth || builder.transactionType == .sale)
                && builder.paymentMethod?.paymentMethodType != .gift {
                element.append(
                    XMLElementBuilder.element(name: "AllowDup", value: builder.allowDuplicates == true ? "Y" : "N")
                )
                if builder.transactionModifier == .none {
                    element.append(
                        XMLElementBuilder.element(name: "AllowPartialAuth", value: builder.allowPartialAuth ? "Y" : "N")
                    )
                }
            }
            
            if let amount = builder.amount {
                element.append(XMLElementBuilder.element(name: "Amt", value: amount.stringValue))
            }
            if let convenienceAmount = builder.convenienceAmount {
                element.append(XMLElementBuilder.element(name: "ConvenienceAmtInfo", value: convenienceAmount.stringValue))
            }
            if let gratuity = builder.gratuity {
                element.append(XMLElementBuilder.element(name: "GratuityAmtInfo", value: gratuity.toString))
            }
            if let shippingAmount = builder.shippingAmount {
                element.append(XMLElementBuilder.element(name: "ShippingAmtInfo", value: shippingAmount.stringValue))
            }
            if let surchargeAmount = builder.surchargeAmount {
                element.append(XMLElementBuilder.element(name: "SurchargeAmtInfo", value: surchargeAmount.stringValue))
            }
        }

        if let offlineAuthCode = builder.offlineAuthCode, !offlineAuthCode.isEmpty {
            element.append(XMLElementBuilder.element(name: "OfflineAuthCode", value: offlineAuthCode))
        }

        if let billingAddress = builder.billingAddress {
            var holderElements: [XMLElementNode] = []
            if let street = billingAddress.streetAddress1, !street.isEmpty {
                holderElements.append(XMLElementBuilder.element(name: "CardHolderAddr", value: street))
            }
            if let city = billingAddress.city, !city.isEmpty {
                holderElements.append(XMLElementBuilder.element(name: "CardHolderCity", value: city))
            }
            if let state = billingAddress.state, !state.isEmpty {
                holderElements.append(XMLElementBuilder.element(name: "CardHolderState", value: state))
            }
            if let zip = billingAddress.postalCode, !zip.isEmpty {
                holderElements.append(XMLElementBuilder.element(name: "CardHolderZip", value: zip))
            }
            if let creditCard = builder.paymentMethod as? CreditCardData,
               let name = creditCard.cardHolderName, !name.isEmpty {
                let parts = name.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
                holderElements.append(XMLElementBuilder.element(name: "CardHolderFirstName", value: parts[0]))
                if parts.count > 1 {
                    holderElements.append(
                        XMLElementBuilder.element(name: "CardHolderLastName", value: parts.dropFirst().joined(separator: " "))
                    )
                }
            }
            if !holderElements.isEmpty {
                element.append(XMLElementBuilder.element(name: "CardHolderData", children: holderElements))
            }
        }

        if builder.paymentMethod?.paymentMethodType == .credit {
            element.append(buildCreditCardData(builder: builder))
        }
        
        if builder.paymentMethod?.paymentMethodType == .gift {
            element.append(buildGiftCardData(giftCard: builder))
        }

        if builder.paymentMethod?.paymentMethodType == .credit {
            if builder.level2Request || builder.cpcReq {
                element.append(XMLElementBuilder.element(name: "CPCReq", value: "Y"))
            } else if builder.transactionType == .auth
                        || builder.transactionType == .sale
                        || builder.transactionType == .verify {
                element.append(XMLElementBuilder.element(name: "CPCReq", value: builder.cpcReq ? "Y" : "N"))
            }
        }

        let hasCustomerId = !(builder.customerId?.isEmpty ?? true)
        let hasDescription = !(builder.transactionDescription?.isEmpty ?? true)
        let hasInvoiceNumber = !(builder.invoiceNumber?.isEmpty ?? true)
        if hasCustomerId || hasDescription || hasInvoiceNumber {
            var txnFields: [XMLElementNode] = []
            if hasCustomerId {
                txnFields.append(XMLElementBuilder.element(name: "CustomerID",  value: builder.customerId!))
            }
            if hasDescription   {
                txnFields.append(XMLElementBuilder.element(name: "Description", value: builder.transactionDescription!))
            }
            if hasInvoiceNumber {
                txnFields.append(XMLElementBuilder.element(name: "InvoiceNbr",  value: builder.invoiceNumber!))
            }
            element.append(XMLElementBuilder.element(name: "AdditionalTxnFields", children: txnFields))
        }

        if let descriptor = builder.dynamicDescriptor, !descriptor.isEmpty {
            element.append(XMLElementBuilder.element(name: "TxnDescriptor", value: descriptor))
        }

        if let tagData = builder.tagData, !tagData.isEmpty {
            let tagValues = XMLElementBuilder.element(name: "TagValues", attributes: ["source": "chip"], value: tagData)
            element.append(XMLElementBuilder.element(name: "TagData", children: [tagValues]))
        }

        if let chipCondition = builder.emvChipCondition, chipCondition != .noChipOrChipSuccess {
            let chipEl = XMLElementBuilder.element(name: "EMVChipCondition", value: chipCondition.rawValue)
            element.append(XMLElementBuilder.element(name: "EMVData", children: [chipEl]))
        }

        if let autoSub = builder.autoSubstantiation {
            
          if autoSub.amounts.count > 4 {
                throw BuilderException(
                        message: "You may only specify three different subtotals in a single transaction."
                    )
                }
            
        if let amount = builder.amount {
           if autoSub.totalHealthcareAmount.compare(amount) == .orderedDescending {
                throw BuilderException(
                        message: "Amount cannot be less than healthcare total."
                   )
                }
            }
            
            let amtTagNames = [
                "FirstAdditionalAmtInfo",
                "SecondAdditionalAmtInfo",
                "ThirdAdditionalAmtInfo",
                "FourthAdditionalAmtInfo"
            ]
            
            let subtotals = autoSub.amounts
            
            var autoSubElements: [XMLElementNode] = []
            for (index, (amtType, amt)) in subtotals.enumerated() {
                autoSubElements.append(XMLElementBuilder.element(name: amtTagNames[index], children: [
                    XMLElementBuilder.element(name: "AmtType", value: amtType),
                    XMLElementBuilder.element(name: "Amt", value: amt.stringValue),
                ]))
            }
            autoSubElements.append(
                XMLElementBuilder.element(name: "RealTimeSubstantiation", value: autoSub.realTimeSubstantiation ? "Y" : "N")
            )
            element.append(XMLElementBuilder.element(name: "AutoSubstantiation", children: autoSubElements))
        }

        let block1 = XMLElementBuilder.element(name: "Block1", children: element)
        let transaction = XMLElementBuilder.element(name: requestType, children: [block1])

        let header = buildHeader(config: config, clientTransactionId: builder.clientTransactionId)
        return buildEnvelope(header: header, transaction: transaction)
    }

    // MARK: - Build Credit Card Data

    private func buildCreditCardData(builder: AuthorizationBuilder) -> XMLElementNode {
        if let track = builder.paymentMethod as? CreditTrackData {
            var children: [XMLElementNode] = []
            children.append(XMLElementBuilder.element(
                name: "TrackData",
                attributes: ["method": track.entryMethod?.rawValue ?? ""],
                value: track.value ?? ""
            ))
            if let encData = track.encryptionData {
                children.append(XMLElementBuilder.element(name: "EncryptionData", children: [
                    XMLElementBuilder.element(name: "Version", value: encData.version),
                    XMLElementBuilder.element(name: "EncryptedTrackNumber", value: encData.trackNumber ?? ""),
                    XMLElementBuilder.element(name: "KSN", value: encData.ksn ?? ""),
                ]))
            }
            children.append(XMLElementBuilder.element(
                name: "TokenRequest", value: builder.requestMultiUseToken == true ? "Y" : "N"
            ))
            return XMLElementBuilder.element(name: "CardData", children: children)
        }

        if let card = builder.paymentMethod as? CreditCardData {
            let cardToken = !(card.token?.isEmpty ?? true)
            var children: [XMLElementNode] = []
            
            if cardToken {
                children.append(XMLElementBuilder.element(name: "TokenData", children: [
                    XMLElementBuilder.element(name: "TokenValue", value: card.token ?? ""),
                ]))
            } else {
                children.append(XMLElementBuilder.element(name: "ManualEntry", children: [
                    XMLElementBuilder.element(name: "CardNbr", value: card.number ?? ""),
                    XMLElementBuilder.element(name: "ExpMonth",  value: card.expMonth),
                    XMLElementBuilder.element(name: "ExpYear", value: card.expYear),
                    XMLElementBuilder.element(name: "CVV2", value: card.cvn ?? ""),
                    XMLElementBuilder.element(name: "CardPresent", value: card.cardPresent ? "Y" : "N"),
                    XMLElementBuilder.element(name: "ReaderPresent", value: card.readerPresent ? "Y" : "N"),
                ]))
            }
            
            children.append(XMLElementBuilder.element(
                name: "TokenRequest", value: (!cardToken && builder.requestMultiUseToken == true) ? "Y" : "N"
            ))
            return XMLElementBuilder.element(name: "CardData", children: children)
        }

        return XMLElementBuilder.element(name: "CardData", children: [])
    }

    // MARK: - Gift Card Data

    private func buildGiftCardData(giftCard: AuthorizationBuilder) -> XMLElementNode {
        if let track = giftCard.paymentMethod as? GiftCard {
            var children: [XMLElementNode] = []
            if let trackData = track.trackData, !trackData.isEmpty {
                children.append(XMLElementBuilder.element(name: "TrackData", value: trackData))
            }
            if let encData = track.encryptionData {
                children.append(XMLElementBuilder.element(name: "EncryptionData", children: [
                    XMLElementBuilder.element(name: "Version", value: encData.version),
                    XMLElementBuilder.element(name: "EncryptedTrackNumber", value: encData.trackNumber ?? ""),
                    XMLElementBuilder.element(name: "KSN", value: encData.ksn ?? ""),
                ]))
            }
            return XMLElementBuilder.element(name: "CardData", children: children)
        }
        return XMLElementBuilder.element(name: "CardData", children: [])
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
        let transactionWrapper = XMLElementNode(name: "Transaction", children: [transaction])
        let ver10 = XMLElementNode(name: "Ver1.0", children: [header, transactionWrapper])
        let posRequest = XMLElementBuilder.element(name: "PosRequest", children: [ver10])
        return SOAPDOMBuilder()
            .with(body: posRequest)
            .build()
    }
}
