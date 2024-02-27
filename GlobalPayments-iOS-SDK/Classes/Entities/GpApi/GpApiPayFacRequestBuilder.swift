import Foundation

struct GpApiPayFacRequestBuilder<T> {
    
    func buildRequest(for builder: PayFacBuilder<T>, config: GpApiConfig?) -> GpApiRequest?{
        let merchantUrl: String = !(config?.merchantId?.isEmpty ?? true) ? "/merchants/\(config?.merchantId ?? "")" : ""
        
        switch builder.transactionType {
        case .create:
            if builder.transactionModifier == .merchant {
                if builder.userPersonalData == nil {
                    return nil// ERROR Merchant data is mandatory!
                }
                
                let payload = buildCreateMerchantRequest(builder)
                return GpApiRequest(
                    endpoint: merchantUrl + "/merchants",
                    method: .post,
                    requestBody: payload.toString()
                )
            }
        case .edit:
            if builder.transactionModifier == .merchant {
                let payload = buildEditMerchantRequest(builder)
                
                return GpApiRequest(
                    endpoint: merchantUrl + "/merchants/" + (builder.userReference?.userId ?? ""),
                    method: .patch,
                    requestBody: payload.toString()
                )
            }
        case .fetch:
            switch builder.transactionModifier {
            case .merchant:
                return GpApiRequest(
                    endpoint: merchantUrl + "/merchants/" + (builder.userReference?.userId ?? ""),
                    method: .get
                )
            case .account:
                let accountId = builder.userReference?.userId ?? ""
                return GpApiRequest(
                    endpoint: merchantUrl + GpApiRequest.Endpoints.accountById(id: accountId),
                    method: .get
                )
            default :
                break
            }
        case .addFunds:
            let payload = JsonDoc()
            payload.set(for: "account_id", value: builder.accountNumber)
            payload.set(for: "type", value: builder.paymentMethodType?.value)
            payload.set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            payload.set(for: "currency", value: builder.currency)
            payload.set(for: "payment_method", value: builder.paymentMethodName?.rawValue)
            payload.set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
            
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.merchantTransferFunds(builder.userReference?.userId ?? ""),
                method: .post,
                requestBody: payload.toString()
            )
        default:
            break
        }
        return nil
    }
    
    private func setMerchantInfo(_ builder: PayFacBuilder<T>) -> JsonDoc {
        if builder.userPersonalData == nil {
            return JsonDoc()
        }
        
        let merchantData = builder.userPersonalData
        
        let data = JsonDoc()
        data.set(for: "name", value: merchantData?.userName)
        data.set(for: "legal_name", value: merchantData?.legalName)
        data.set(for: "dba", value: merchantData?.DBA)
        data.set(for: "merchant_category_code", value: merchantData?.merchantCategoryCode)
        data.set(for: "website", value: merchantData?.website)
        data.set(for: "currency", value: merchantData?.currencyCode)
        data.set(for: "tax_id_reference", value: merchantData?.taxIdReference)
        data.set(for: "notification_email", value: merchantData?.notificationEmail)
        if let userReference = builder.userReference, let userStatus = userReference.userStatus {
            data.set(for: "status", value: userStatus.rawValue)
        }
        
        let notifications = JsonDoc()
        notifications.set(for: "status_url", value: merchantData?.notificationStatusUrl)
        
        if !notifications.keys.isEmpty {
            data.set(for: "notifications", doc: notifications)
        }
        return data
    }
    
    private func buildCreateMerchantRequest(_ builder: PayFacBuilder<T>) -> JsonDoc {
        let merchantData = builder.userPersonalData
        let data = setMerchantInfo(builder)
        data.set(for: "description", value: builder.descriptionPayFac)
        data.set(for: "type", value: merchantData?.type?.mapped(for: .gpApi))
        data.set(for: "addresses", values: setAddressList(builder))
        data.set(for: "payment_processing_statistics", doc: setPaymentStatistics(builder))

        data.set(for: "payment_methods", values: setPaymentMethod(builder))
        data.set(for: "persons", values: setPersonList(builder: builder))
        data.set(for: "products", values: setProductList(builder.productData))
        data.set(for: "pricing_profile", value: merchantData?.tier)
        
        return data
    }
    
    private func setPaymentStatistics(_ builder: PayFacBuilder<T>) -> JsonDoc? {
        guard let paymentStatistics = builder.paymentStatistics else { return nil }
        let statistics = JsonDoc()
        statistics.set(for: "total_monthly_sales_amount", value: paymentStatistics.totalMonthlySalesAmount?.toNumericCurrencyString())
        statistics.set(for: "average_ticket_sales_amount", value: paymentStatistics.averageTicketSalesAmount?.toNumericCurrencyString())
        statistics.set(for: "highest_ticket_sales_amount", value: paymentStatistics.highestTicketSalesAmount?.toNumericCurrencyString())
        return statistics
    }
    
    private func setPersonList(_ type: String? = nil, builder: PayFacBuilder<T>) -> [JsonDoc]? {
        
        guard let personsData = builder.personsData, !personsData.isEmpty else { return nil }
        var personInfo = [JsonDoc]()
        
        personsData.forEach { person in
            let doc = JsonDoc()
            doc.set(for: "functions", value: [person.functions?.mapped(for: .gpApi)])
            doc.set(for: "first_name", value: person.firstName)
            doc.set(for: "middle_name", value: person.middleName)
            doc.set(for: "last_name", value: person.lastName)
            doc.set(for: "email", value: person.email)
            doc.set(for: "date_of_birth", value: person.dateOfBirth)
            doc.set(for: "national_id_reference", value: person.nationalIdReference)
            doc.set(for: "equity_percentage", value: person.equityPercentage)
            doc.set(for: "job_title", value: person.jobTitle)
            
            if let address = person.address, type == nil {
                let addressDoc = JsonDoc()
                addressDoc.set(for: "line_1", value: address.streetAddress1)
                addressDoc.set(for: "line_2", value: address.streetAddress2)
                addressDoc.set(for: "line_3", value: address.streetAddress3)
                addressDoc.set(for: "city", value: address.city)
                addressDoc.set(for: "state", value: address.state)
                addressDoc.set(for: "postal_code", value: address.postalCode)
                addressDoc.set(for: "country", value: address.countryCode)
                
                doc.set(for: "address", doc: addressDoc)
            }
            
            if let homePhone = person.homePhone {
                let contactPhoneDoc = JsonDoc()
                contactPhoneDoc.set(for: "country_code", value: homePhone.countryCode)
                contactPhoneDoc.set(for: "subscriber_number", value: homePhone.number)
                doc.set(for: "contact_phone", doc: contactPhoneDoc)
            }
            
            if let workPhone = person.workPhone {
                let contactPhoneDoc = JsonDoc()
                contactPhoneDoc.set(for: "country_code", value: workPhone.countryCode)
                contactPhoneDoc.set(for: "subscriber_number", value: workPhone.number)
                doc.set(for: "work_phone", doc: contactPhoneDoc)
            }
            
            personInfo.append(doc)
        }
        
        return personInfo
    }
    
    private func setBankTransferInfo(_ bankAccountData: BankAccountData?) -> JsonDoc? {
        if let bankAccountData = bankAccountData {
            let data = JsonDoc()
            data.set(for: "account_holder_type", value: bankAccountData.accountOwnershipType)
            data.set(for: "account_number", value: bankAccountData.accountNumber)
            data.set(for: "account_type", value: bankAccountData.accountType)
            
            let bank = JsonDoc()
            
            if let bankName = bankAccountData.bankName, !bankName.isEmpty {
                bank.set(for: "name", value: bankName)
            }
            
            if let routingNumber = bankAccountData.routingNumber, !routingNumber.isEmpty {
                bank.set(for: "code", value: routingNumber)
            }
            
            if let bankAddress = bankAccountData.bankAddress {
                let address = JsonDoc()
                address.set(for: "line_1", value: bankAddress.streetAddress1)
                address.set(for: "line_2", value: bankAddress.streetAddress2)
                address.set(for: "line_3", value: bankAddress.streetAddress3)
                address.set(for: "city", value: bankAddress.city)
                address.set(for: "postal_code", value: bankAddress.postalCode)
                address.set(for: "state", value: bankAddress.state)
                address.set(for: "country", value: CountryUtils.shared.countryByCode(bankAddress.countryCode))
                
                bank.set(for: "address", doc: address)
            }

            data.set(for: "bank", doc: bank)
            return data
        }
        
        return nil
    }
    
    private func setCreditCardInfo(_ creditCardInformation: CreditCardData?) -> JsonDoc? {
        if let creditCardInformation = creditCardInformation {
            let data = JsonDoc()
            if let holderName = creditCardInformation.cardHolderName {
                data.set(for: "name", value: holderName)
            }
            
            data.set(for: "number", value: creditCardInformation.number)
            data.set(for: "expiry_month", value: creditCardInformation.expMonth)
            data.set(for: "expiry_year", value: creditCardInformation.expYear)
            
            return data
        }
        return nil
    }
    
    private func setProductList(_ productData: [Product]?) -> [JsonDoc]? {
        guard let productData = productData, !productData.isEmpty else { return nil }
        
        var products = [JsonDoc]()
        productData.forEach { product in
            let item = JsonDoc()
            item.set(for: "id", value: product.productId)
            if product.productId?.contains("_CP-") ?? false {
                let deviceDoc = JsonDoc()
                deviceDoc.set(for: "quantity", value: product.quantity)
                item.set(for: "device", doc: deviceDoc)
            }
            products.append(item)
        }
        
        return products
    }
    
    private func setPaymentMethod(_ builder: PayFacBuilder<T>) -> [JsonDoc]? {
        guard let methodsFunctions = builder.paymentMethodsFunctions else { return nil }
        
        var paymentMethods = [JsonDoc]()
        let item1 = JsonDoc()
        item1.set(for: "functions", value: methodsFunctions[builder.creditCardInformation?.theClassName ?? ""]?.mapped(for: .gpApi))
        item1.set(for: "card", doc: setCreditCardInfo(builder.creditCardInformation))
        
        paymentMethods.append(item1)
        
        let item2 = JsonDoc()
        item2.set(for: "functions", value: methodsFunctions[builder.bankAccountData?.theClassName ?? ""]?.mapped(for: .gpApi))
        item2.set(for: "name", value: builder.bankAccountData?.accountHolderName)
        item2.set(for: "bank_transfer", doc: setBankTransferInfo(builder.bankAccountData))
        
        paymentMethods.append(item2)
        
        return paymentMethods
    }
    
    private func setAddressList(_ builder: PayFacBuilder<T>) -> [JsonDoc]? {
        guard let merchantData = builder.userPersonalData else { return nil }
        var addressList = [String: Any]()
        
        if let userAddress = merchantData.userAddress {
            addressList[AddressType.business.rawValue] = userAddress
        }
        
        if let mailingAddress = merchantData.mailingAddress {
            addressList[AddressType.shipping.rawValue] = mailingAddress
        }
        
        var addresses = [JsonDoc]()
        
        addressList.forEach {
            if let address = $0.value as? Address {
                let item  = JsonDoc()
                item.set(for: "functions", value: [$0.key])
                item.set(for: "line_1", value: address.streetAddress1)
                item.set(for: "line_2", value: address.streetAddress2)
                item.set(for: "city", value: address.city)
                item.set(for: "postal_code", value: address.postalCode)
                item.set(for: "state", value: address.state)
                item.set(for: "country", value: CountryUtils.shared.countryCodeByCountry(address.countryCode))
                addresses.append(item)
            }
        }
        return addresses
    }
    
    private func buildEditMerchantRequest(_ builder: PayFacBuilder<T>) -> JsonDoc {
        let requestBody = setMerchantInfo(builder)
        requestBody.set(for: "status_change_reason", value: builder.statusChangeReason?.rawValue)
        requestBody.set(for: "addresses", values: setAddressList(builder))
        requestBody.set(for: "persons", values: setPersonList("edit", builder: builder))
        requestBody.set(for: "payment_processing_statistics", doc: setPaymentStatistics(builder))
        requestBody.set(for: "payment_methods", values: setPaymentMethod(builder))
        
        return requestBody
    }
}
