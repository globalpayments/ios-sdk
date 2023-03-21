import Foundation

enum TransactionStatus: String, Decodable {
    case AuthenticationSuccessful = "Y"
    case TransactionDenied = "N"
    case TechnicalProblem = "U"
    case AttemptsProcessing = "A"
    case ChallengeRequired = "C"
    case AuthenticationRejected = "R"
    case DecoupledAuthentication = "D"
    case InformationalPurposesOnly = "I"
}

struct AcsRenderingType: Decodable {
    let acsInterface: String
    let aacsUiTemplate: String
}

struct TransactionResult: Decodable {
    let threeDSServerTransID: String
    let transStatus: TransactionStatus
    let transStatusReason: String?
    let authenticationValue: String?
    let eci: String?
    let acsTransID: String
    let dsTransID: String?
    let acsReferenceNumber: String
    let cardholderInfo: String?
    let authenticationType: String?
    
    init(threeDSServerTransID: String,
         transStatus: TransactionStatus,
         transStatusReason: String,
         authenticationValue: String,
         eci: String,
         acsTransID: String,
         dsTransID: String,
         acsReferenceNubmer: String,
         cardholderInfo: String,
         authenticationType: String) {
        self.threeDSServerTransID = threeDSServerTransID
        self.transStatus = transStatus
        self.transStatusReason = transStatusReason
        self.authenticationValue = authenticationValue
        self.eci = eci
        self.acsTransID = acsTransID
        self.dsTransID = dsTransID
        self.acsReferenceNumber = acsReferenceNubmer
        self.cardholderInfo = cardholderInfo
        self.authenticationType = authenticationType
    }
}

struct ChallengeData: Decodable {
    let acsSignedContent: String?
    let acsUIType: String?
}

struct AuthenticationResponse: Deserialisable, Decodable {

    let indicator: String
    let transactionResult: TransactionResult
    let challengeData: ChallengeData?
    
    init(indicator: String, transactionResult: TransactionResult, challengeData: ChallengeData?) {
        self.indicator = indicator
        self.transactionResult = transactionResult
        self.challengeData = challengeData
    }
    
    static func deserialize<T>(from data: Data?) -> T? {

        guard let dataToDeserialize = data,
            let response = try? JSONDecoder().decode(AuthenticationResponse.self,
                                                     from: dataToDeserialize),
            let authenticationResponse = response as? T else {
                return nil
        }
        return authenticationResponse
    }
}
