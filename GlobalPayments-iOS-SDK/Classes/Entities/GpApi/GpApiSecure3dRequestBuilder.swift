import Foundation

struct GpApiSecure3dRequestBuilder: GpApiRequestData {

    func generateRequest(for builder: Secure3dBuilder, config: GpApiConfig?) -> GpApiRequest? {
        let merchantUrl: String = !(config?.merchantId?.isEmpty ?? true) ? "/merchants/\(config?.merchantId ?? "")" : ""
        switch builder.transactionType {
        case .verifyEnrolled?:
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.authenticationCheckAvailability(),
                method: .post,
                requestBody: verifyEnrolled(builder, config).toString()
            )
        case .initiateAuthentication?:
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.authenticationInitiate(id: builder.serverTransactionId ?? .empty),
                method: .post,
                requestBody: initiateAuthenticationData(builder, config).toString()
            )
        case .verifySignature?:
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.authenticationResult(id: builder.serverTransactionId ?? .empty),
                method: .post,
                requestBody: verifySignature(builder)?.toString()
            )
        default:
            return nil
        }
    }

    private func verifyEnrolled(_ builder: Secure3dBuilder, _ config: GpApiConfig?) -> JsonDoc {
        var payload = JsonDoc()
        initBaseParams(payload: &payload, config: config)
        payload.set(for: "reference", value: builder.referenceNumber ?? UUID().uuidString)
        payload.set(for: "amount", value: builder.amount?.toNumericCurrencyString())
        payload.set(for: "currency", value: builder.currency)
        payload.set(for: "payment_method", doc: paymentMethodParam(builder))
        payload.set(for: "source", value: builder.authenticationSource.mapped(for: .gpApi))
        payload.set(for: "preference", value: builder.challengeRequestIndicator?.mapped(for: .gpApi))
        payload.set(for: "initiator", value: builder.storedCredential?.initiator.mapped(for: .gpApi))

        if let storedCredential = builder.storedCredential {
            let storedCredential = JsonDoc()
                .set(for: "model", value: storedCredential.type.mapped(for: .gpApi))
                .set(for: "reason", value: storedCredential.reason.mapped(for: .gpApi))
                .set(for: "sequence", value: storedCredential.sequence.mapped(for: .gpApi))
            payload.set(for: "stored_credential", doc: storedCredential)
        }

        let notifications = JsonDoc()
            .set(for: "challenge_return_url", value: config?.challengeNotificationUrl)
            .set(for: "three_ds_method_return_url", value: config?.methodNotificationUrl)
            .set(for: "decoupled_notification_url", value: builder.decoupledNotificationUrl)
        payload.set(for: "notifications", doc: notifications)

        return payload
    }

    private func initiateAuthenticationData(_ builder: Secure3dBuilder, _ config: GpApiConfig?) -> JsonDoc {
        let order = JsonDoc()
            .set(for: "reference", value: builder.referenceNumber)
            .set(for: "time_created_reference", value: builder.orderCreateDate?.format("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))
            .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            .set(for: "currency", value: builder.currency)
            .set(for: "address_match_indicator", value: (builder.addressMatchIndicator == nil) ? false : true)
            .set(for: "gift_card_count", value: builder.giftCardCount)
            .set(for: "gift_card_amount", value: builder.giftCardAmount?.toNumericCurrencyString())
            .set(for: "gift_card_currency", value: builder.giftCardCurrency)
            .set(for: "delivery_email", value: builder.deliveryEmail)
            .set(for: "delivery_timeframe", value: builder.deliveryTimeFrame?.mapped(for: .gpApi))
            .set(for: "shipping_method", value: builder.shippingMethod?.mapped(for: .gpApi))
            .set(for: "shipping_name_matches_cardholder_name", value: builder.shippingNameMatchesCardHolderName)
            .set(for: "preorder_indicator", value: builder.preOrderIndicator?.mapped(for: .gpApi))
            .set(for: "preorder_availability_date", value: builder.preOrderAvailabilityDate?.format("yyyy-MM-dd"))
            .set(for: "transaction_type", value: builder.orderTransactionType?.mapped(for: .gpApi))
            .set(for: "reorder_indicator", value: builder.reorderIndicator?.mapped(for: .gpApi))
            .set(for: "category", value: builder.messageCategory.rawValue)

        if let shippingAddress = builder.shippingAddress {
            let address = JsonDoc()
                .set(for: "line1", value: shippingAddress.streetAddress1)
                .set(for: "line2", value: shippingAddress.streetAddress2)
                .set(for: "line3", value: shippingAddress.streetAddress3)
                .set(for: "city", value: shippingAddress.city)
                .set(for: "postal_code", value: shippingAddress.postalCode)
                .set(for: "state", value: shippingAddress.state)
                .set(for: "country", value: shippingAddress.countryCode)
            order.set(for: "shipping_address", doc: address)
        }

        let paymentMethod = paymentMethodParam(builder)

        let homePhone = JsonDoc()
            .set(for: "country_code", value: builder.homeCountryCode)
            .set(for: "subscriber_number", value: builder.homeNumber)

        let workPhone = JsonDoc()
            .set(for: "country_code", value: builder.workCountryCode)
            .set(for: "subscriber_number", value: builder.workNumber)

        let payer = JsonDoc()
            .set(for: "reference", value: builder.customerAccountId) // TODO: - To Confirm
            .set(for: "account_age", value: builder.accountAgeIndicator?.mapped(for: .gpApi))
            .set(for: "account_creation_date", value: builder.accountCreateDate?.format("yyyy-MM-dd"))
            .set(for: "account_change_date", value: builder.accountChangeDate?.format("yyyy-MM-dd"))
            .set(for: "account_change_indicator", value: builder.accountChangeIndicator?.mapped(for: .gpApi))
            .set(for: "account_password_change_date", value: builder.passwordChangeDate?.format("yyyy-MM-dd"))
            .set(for: "account_password_change_indicator", value: builder.passwordChangeIndicator?.mapped(for: .gpApi))
            .set(for: "home_phone", doc: homePhone)
            .set(for: "work_phone", doc: workPhone)
            .set(for: "payment_account_creation_date", value: builder.paymentAccountCreateDate?.format("yyyy-MM-dd"))
            .set(for: "payment_account_age_indicator", value: builder.paymentAgeIndicator?.mapped(for: .gpApi))
            .set(for: "purchases_last_6months_count", value: builder.numberOfPurchasesInLastSixMonths)
            .set(for: "transactions_last_24hours_count", value: builder.numberOfTransactionsInLast24Hours)
            .set(for: "transaction_last_year_count", value: builder.numberOfTransactionsInLastYear)
            .set(for: "provision_attempt_last_24hours_count", value: builder.numberOfAddCardAttemptsInLast24Hours)
            .set(for: "shipping_address_time_created_reference", value: builder.shippingAddressCreateDate?.format("yyyy-MM-dd"))
            .set(for: "shipping_address_creation_indicator", value: builder.shippingAddressUsageIndicator?.mapped(for: .gpApi))
            .set(for: "suspicious_account_activity", value: builder.suspiciousAccountActivity?.mapped(for: .gpApi))
            .set(for: "email", value: builder.customerEmail)

        let payerPriorThreeDsAuthenticationData = JsonDoc()
            .set(for: "authentication_method", value: builder.priorAuthenticationMethod?.mapped(for: .gpApi))
            .set(for: "acs_transaction_reference", value: builder.priorAuthenticationTransactionId)
            .set(for: "authentication_timestamp", value: builder.priorAuthenticationTimestamp?.format("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))
            .set(for: "authentication_data", value: builder.priorAuthenticationData)

        let recurringAuthorizationData = JsonDoc()
            .set(for: "max_number_of_instalments", value: builder.maxNumberOfInstallments)
            .set(for: "frequency", value: builder.recurringAuthorizationFrequency)
            .set(for: "expiry_date", value: builder.recurringAuthorizationExpiryDate?.format("yyyy-MM-dd"))

        let payerLoginData = JsonDoc()
            .set(for: "authentication_data", value: builder.customerAuthenticationData)
            .set(for: "authentication_timestamp", value: builder.customerAuthenticationTimestamp?.format("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"))
            .set(for: "authentication_type", value: builder.customerAuthenticationMethod?.mapped(for: .gpApi))

        let browserData = JsonDoc()
            .set(for: "accept_header", value: builder.browserData?.acceptHeader)
            .set(for: "color_depth", value: builder.browserData?.colorDepth?.rawValue)
            .set(for: "ip", value: builder.browserData?.ipAddress)
            .set(for: "java_enabled", value: builder.browserData?.javaEnabled)
            .set(for: "javascript_enabled", value: builder.browserData?.javaScriptEnabled)
            .set(for: "language", value: builder.browserData?.language)
            .set(for: "screen_height", value: builder.browserData?.screenHeight)
            .set(for: "screen_width", value: builder.browserData?.screenWidth)
            .set(for: "challenge_window_size", value: builder.browserData?.challengeWindowSize?.rawValue)
            .set(for: "timezone", value: builder.browserData?.timezone)
            .set(for: "user_agent", value: builder.browserData?.userAgent)
        
        let mobileData = JsonDoc()
            .set(for: "encoded_data", value: builder.mobileData?.encodedData)
            .set(for: "application_reference", value: builder.mobileData?.applicationReference)
            .set(for: "sdk_interface", value: builder.mobileData?.sdkInterface?.mapped(for: .gpApi))
            .set(for: "sdk_ui_type", value: SdkUiType.sdkUiTypes(builder.mobileData?.sdkUiTypes, target: .gpApi))
            .set(for: "ephemeral_public_key",doc: builder.mobileData?.ephemeralPublicKey)
            .set(for: "maximum_timeout", value: builder.mobileData?.maximumTimeout)
            .set(for: "reference_number", value: builder.mobileData?.referenceNumber)
            .set(for: "sdk_trans_reference", value: builder.mobileData?.sdkTransReference)
        

        let storedCredential = JsonDoc()
            .set(for: "model", value: builder.storedCredential?.type.mapped(for: .gpApi))
            .set(for: "reason", value: builder.storedCredential?.reason.mapped(for: .gpApi))
            .set(for: "sequence", value: builder.storedCredential?.sequence.mapped(for: .gpApi))

        let threeDS = JsonDoc()
            .set(for: "source", value: builder.authenticationSource.mapped(for: .gpApi))
            .set(for: "preference", value: builder.challengeRequestIndicator?.mapped(for: .gpApi))
            .set(for: "message_version", value: builder.messageVersion)

        var payload = JsonDoc()
            .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            .set(for: "currency", value: builder.currency)
            .set(for: "method_url_completion_status", value: builder.methodUrlCompletion?.mapped(for: .gpApi))
            .set(for: "merchant_contact_url", value: config?.merchantContactUrl)
            .set(for: "payment_method", doc: paymentMethod)
            .set(for: "order", doc: order)
            .set(for: "payer", doc: payer)
            .set(for: "payer_prior_three_ds_authentication_data", doc: payerPriorThreeDsAuthenticationData)
            .set(for: "recurring_authorization_data", doc: recurringAuthorizationData)
            .set(for: "payer_login_data", doc: payerLoginData)
            .set(for: "browser_data", doc: browserData)
            .set(for: "mobile_data", doc: mobileData)
            .set(for: "initiator", value: builder.storedCredential?.initiator.mapped(for: .gpApi))
            .set(for: "stored_credential", doc: storedCredential)
            .set(for: "three_ds", doc: threeDS)

        let notifications = JsonDoc()
            .set(for: "challenge_return_url", value: config?.challengeNotificationUrl)
            .set(for: "three_ds_method_return_url", value: config?.methodNotificationUrl)
            .set(for: "decoupled_notification_url", value: builder.decoupledNotificationUrl)
        payload.set(for: "notifications", doc: notifications)

        if let flowRequest = builder.decoupledFlowRequest {
            payload.set(for: "decoupled_flow_request", value: flowRequest ? DecoupledFlowRequest.DECOUPLED_PREFERRED.rawValue : DecoupledFlowRequest.DO_NOT_USE_DECOUPLED.rawValue)
        }
        payload.set(for: "decoupled_flow_timeout", value: builder.decoupledFlowTimeout)

        initBaseParams(payload: &payload, config: config)

        return payload
    }

    private func verifySignature(_ builder: Secure3dBuilder) -> JsonDoc? {
        guard let payerAuthenticationResponse = builder.payerAuthenticationResponse,
              !payerAuthenticationResponse.isEmpty else {
            return nil
        }
        return JsonDoc().set(
            for: "three_ds",
            doc: JsonDoc()
                .set(for: "challenge_result_value", value: payerAuthenticationResponse)
        )
    }

    private func paymentMethodParam(_ builder: Secure3dBuilder) -> JsonDoc {
        let payload = JsonDoc()

        if let tokenizable = builder.paymentMethod as? Tokenizable,
           let token = tokenizable.token, !token.isEmpty {
            payload.set(for: "id", value: token)
        } else if let cardData = builder.paymentMethod as? CardData {
            let card = JsonDoc()
                .set(for: "number", value: cardData.number)
                .set(for: "expiry_month", value: cardData.expMonth > .zero ? "\(cardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : .empty)
                .set(for: "expiry_year", value: cardData.expYear > .zero ? "\(cardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : .empty)
            payload.set(for: "card", doc: card)
        }

        return payload
    }
}
