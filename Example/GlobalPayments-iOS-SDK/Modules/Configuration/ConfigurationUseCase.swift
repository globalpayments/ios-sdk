import Foundation
import GlobalPayments_iOS_SDK

class ConfigurationUseCase {
    
    lazy var form: ConfigurationForm = ConfigurationForm()
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .appId:
            form.appId = value
        case .appKey:
            form.appKey =  value
        case .secondsToExpire:
            form.secondsToExpire = value.toInt()
        case .interval:
            form.intervalToExpire = IntervalToExpire(value: value)
        case .channel:
            form.channel = Channel(value: value)
        case .language:
            form.language = Language(value: value)
        case .country:
            form.country = value
        case .merchantId:
            form.merchantId = value
        case .transactionProccesing:
            form.transactionProcessing = value
        case .tokenization:
            form.tokenization = value
        case .challengeNotification:
            form.challengeNotificationUrl = value
        case .methodNotification:
            form.methodNotificationUrl = value
        case .merchantContactUrl:
            form.merchantContactUrl = value
        default:
            break
        }
    }
    
    func getConfig() -> Config {
        let config = Config(
            appId: form.appId ?? "",
            appKey: form.appKey ?? "",
            secondsToExpire: form.secondsToExpire,
            intervalToExpire: form.intervalToExpire ?? .day,
            channel: form.channel ?? .cardNotPresent,
            language: form.language,
            country: form.country,
            challengeNotificationUrl: form.challengeNotificationUrl,
            methodNotificationUrl: form.methodNotificationUrl,
            merchantContactUrl: form.merchantContactUrl,
            merchantId: form.merchantId,
            transactionProcessing: form.transactionProcessing,
            tokenization: form.tokenization
        )
        return config
    }
}

