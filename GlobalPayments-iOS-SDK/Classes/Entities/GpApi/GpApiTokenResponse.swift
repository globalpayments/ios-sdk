import Foundation

class GpApiTokenResponse {
    var token: String?
    var type: String?
    var appId: String?
    var appName: String?
    var timeCreated: Date?
    var secondsToExpire: Int?
    var email: String?
    //var statusCode: Int?
    //var responseMessage: String?

    init(_ jsonString: String) {
        let doc = JsonDoc.parse(jsonString)
        mapResponseValues(doc)
    }

    func mapResponseValues(_ doc: JsonDoc?) {
        token = doc?.getValue(key: "token")
        type = doc?.getValue(key: "type")
        appId = doc?.getValue(key: "app_id")
        appName = doc?.getValue(key: "app_name")
        timeCreated = doc?.getValue(key: "time_created")
        secondsToExpire = doc?.getValue(key: "seconds_to_expire")
        email = doc?.getValue(key: "email")
        //statusCode = doc?.getValue(key: "status_code")
        //responseMessage = doc?.getValue(key: "response_message")
    }
}
