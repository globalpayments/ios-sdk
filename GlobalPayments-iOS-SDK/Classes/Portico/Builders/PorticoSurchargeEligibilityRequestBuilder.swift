//
//  PorticoSurchargeEligibilityRequestBuilder.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Ranu Dhurandhar on 30/03/26.
//

import Foundation

struct PorticoSurchargeEligibilityLookupRequestBuilder: PorticoRequestData {

    func generateRequest(for builder: SurchargeEligibilityLookupBuilder, config: PorticoConfig) -> PorticoRequest? {
        guard let requestType = mapRequestType(builder) else { return nil }
        let requestXML = buildRequest(builder: builder, config: config, requestType: requestType)
        return PorticoRequest(
            endpoint: PorticoRequest.Endpoints.exchange(),
            method: .post,
            request: requestXML
        )
    }

    func mapRequestType(_ builder: SurchargeEligibilityLookupBuilder) -> String? {
        guard builder.transactionType == .surcharge else { return nil }
        if builder.paymentMethod?.paymentMethodType == .credit {
            return "CreditSurchargeEligibilityLookup"
        }
        if builder.paymentMethod?.paymentMethodType == .gift {
            return "GiftCardSurchargeEligibilityLookup"
        }
        return nil
    }

    // MARK: - Build XML Request

    private func buildRequest(builder: SurchargeEligibilityLookupBuilder, config: PorticoConfig, requestType: String) -> String {
        var element: [XMLElementNode] = []

        if builder.paymentMethod?.paymentMethodType == .credit {
            element.append(buildCreditCardData(builder: builder))
        } else if builder.paymentMethod?.paymentMethodType == .gift {
            element.append(buildGiftCardData(builder: builder))
        }

        let block1 = XMLElementBuilder.element(name: "Block1", children: element)
        let transaction = XMLElementBuilder.element(name: requestType, children: [block1])

        let header = buildHeader(config: config, clientTransactionId: builder.clientTransactionId)
        return buildEnvelope(header: header, transaction: transaction)
    }

    // MARK: - Credit Card Data

    private func buildCreditCardData(builder: SurchargeEligibilityLookupBuilder) -> XMLElementNode {
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
                name: "TokenRequest", value: builder.requestMultiUseToken ? "Y" : "N"
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
                    XMLElementBuilder.element(name: "ExpMonth", value: card.expMonth),
                    XMLElementBuilder.element(name: "ExpYear", value: card.expYear),
                    XMLElementBuilder.element(name: "CVV2", value: card.cvn ?? ""),
                    XMLElementBuilder.element(name: "CardPresent", value: card.cardPresent ? "Y" : "N"),
                    XMLElementBuilder.element(name: "ReaderPresent", value: card.readerPresent ? "Y" : "N"),
                ]))
            }
            children.append(XMLElementBuilder.element(
                name: "TokenRequest", value: (!cardToken && builder.requestMultiUseToken) ? "Y" : "N"
            ))
            return XMLElementBuilder.element(name: "CardData", children: children)
        }

        return XMLElementBuilder.element(name: "CardData", children: [])
    }

    // MARK: - Gift Card Data

    private func buildGiftCardData(builder: SurchargeEligibilityLookupBuilder) -> XMLElementNode {
        if let card = builder.paymentMethod as? GiftCard {
            var children: [XMLElementNode] = []
            if let trackData = card.trackData, !trackData.isEmpty {
                children.append(XMLElementBuilder.element(name: "TrackData", value: trackData))
            }
            if let encData = card.encryptionData {
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
