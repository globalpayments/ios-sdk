import Foundation

struct PaymentCardModel {
    let name: String
    let number: String
    let month: String
    let year: String
    let cvv: String
}

extension PaymentCardModel {

    static var models: [PaymentCardModel] {
        [
            PaymentCardModel(name: "VISA_SUCCESSFUL", number: "4263970000005262", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "MASTERCARD_SUCCESSFUL", number: "5425230000004415", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "AMEX_SUCCESSFUL", number: "374101000000608", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "VISA_DECLINED", number: "4000120000001154", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "MASTERCARD_DECLINED", number: "5114610000004778", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "AMEX_DECLINED", number: "376525000000010", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "VISA_3DS_NOT_ENROLLED", number: "4917000000000087", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "VISA_3DS1_CHALLENGE", number: "4012001037141112", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "VISA_3DS2_CHALLENGE", number: "4012001038488884", month: "5", year: "2025", cvv: "852"),
            PaymentCardModel(name: "VISA_3DS2_FRICTIONLESS", number: "4263970000005262", month: "5", year: "2025", cvv: "852")
        ]
    }
}
