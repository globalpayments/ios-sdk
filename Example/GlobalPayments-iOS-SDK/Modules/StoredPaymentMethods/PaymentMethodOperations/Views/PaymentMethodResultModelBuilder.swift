import Foundation
import GlobalPayments_iOS_SDK

struct PaymentMethodResultModelBuilder {

    static func buildTokenizeModels(_ token: String) -> [PaymentMethodResultModel] {
        [
            PaymentMethodResultModel(
                title: "payment.method.operations.result.view.payment.method.id".localized(),
                description: token
            )
        ]
    }

    static func buildEditModels(_ result: Bool) -> [PaymentMethodResultModel] {
        [
            PaymentMethodResultModel(
                title: "payment.method.operations.result.view.result".localized(),
                description: result == true ? "Success" : "Failure"
            )
        ]
    }

    static func buildDeleteModels(_ result: Bool) -> [PaymentMethodResultModel] {
        [
            PaymentMethodResultModel(
                title: "payment.method.operations.result.view.result".localized(),
                description: result == true ? "Success" : "Failure"
            )
        ]
    }

    static func buildDetokenizeModels(_ cardData: CreditCardData) -> [PaymentMethodResultModel] {
        [
            PaymentMethodResultModel(
                title: "payment.method.operations.result.view.card.type".localized(),
                description: cardData.cardType
            ),
            PaymentMethodResultModel(
                title: "payment.method.operations.result.view.card.number".localized(),
                description: cardData.number
            ),
            PaymentMethodResultModel(
                title: "payment.method.operations.result.view.card.expiry.month".localized(),
                description: String(cardData.expMonth)
            ),
            PaymentMethodResultModel(
                title: "payment.method.operations.result.view.card.expiry.year".localized(),
                description: String(cardData.expYear)
            )
        ]
    }
}
