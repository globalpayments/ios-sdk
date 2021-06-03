import Foundation
import GlobalPayments_iOS_SDK

/// Simulates authetincation result code
enum AuthenticationResultCode: Int {
    /// Successful Authentication
    case successful = 0
    /// Authentication Unavailable
    case unavailable = 5
    /// Authentication Attempt Ack
    case attemptAcknowledge = 7
    /// Authentication Failed
    case failed = 9
}

/// This 3DS ACS client mocks the ACS Authentication Simulator used for testing purposes
struct GpApi3DSecureAcsClient {

    private let redirectURL: String

    init?(redirectURL: String?) {
        guard let redirectURL = redirectURL else { return nil }
        self.redirectURL = redirectURL
    }

    /// Performs ACS authentication for 3DS version 1
    /// - Parameters:
    ///   - secureEcom: ThreeDSecure object
    ///   - authenticationResultCode: Authetincation result code
    ///   - completion: Raw HTML result
    func authenticateV1(_ secureEcom: ThreeDSecure?,
                        _ authenticationResultCode: AuthenticationResultCode,
                        _ completion: @escaping (AcsResponse?) -> Void) {

        guard let secureEcom = secureEcom,
              let issuerAcsUrl = secureEcom.issuerAcsUrl,
              let sessionDataFieldName = secureEcom.sessionDataFieldName,
              let messageType = secureEcom.messageType else {
            completion(nil)
            return
        }
        var formData = [String: String]()
        formData["TermUrl"] = secureEcom.challengeReturnUrl
        formData[sessionDataFieldName] = secureEcom.serverTransactionId
        formData[messageType] = secureEcom.payerAuthenticationRequest
        formData["AuthenticationResultCode"] = "\(authenticationResultCode.rawValue)"

        submitFormData(formUrl: issuerAcsUrl, formData: formData) { result in
            switch result {
            case .success(let rawResponse):
                guard let paRes = getInputValue(rawHTML: rawResponse, inputName: "PaRes") else {
                    completion(nil)
                    return
                }
                formData.removeAll()
                formData["PaRes"] = paRes
                formData["MD"] = getInputValue(rawHTML: rawResponse, inputName: "MD")
                guard let serviceUrl = getFormAction(rawHTML: rawResponse, formName: "PAResForm") else {
                    completion(nil)
                    return
                }
                submitFormData(formUrl: serviceUrl, formData: formData) { result in
                    switch result {
                    case .success(let response):
                        var acsResponse = AcsResponse()
                        acsResponse.status = response == "{\"success\":true}" ? true : false
                        acsResponse.authResponse = paRes
                        acsResponse.merchantData = getInputValue(rawHTML: rawResponse, inputName: "MD")
                        completion(acsResponse)
                    case .failure(let error):
                        print(error.localizedDescription)
                        completion(nil)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }

    /// Performs ACS authentication for 3DS version 2
    /// - Parameters:
    ///   - secureEcom: ThreeDSecure object
    ///   - completion: Raw HTML result
    func authenticateV2(secureEcom: ThreeDSecure?,
                        _ completion: @escaping (AcsResponse?) -> Void) {

        guard let secureEcom = secureEcom,
              let issuerAcsUrl = secureEcom.issuerAcsUrl else {
            completion(nil)
            return
        }
        var formData = [String: String]()
        formData[secureEcom.messageType ?? ""] = secureEcom.payerAuthenticationRequest
        submitFormData(formUrl: issuerAcsUrl, formData: formData) { result in
            switch result {
            case .success:
                formData.removeAll()
                formData["get-status-type"] = "true"
                checkStatus(formData: formData) { result in
                    switch result {
                    case .success:
                        submitFormData(formUrl: redirectURL, formData: [String: String]()) { result in
                            switch result {
                            case .success(let rawResponse):
                                formData.removeAll()
                                let cres = getInputValue(rawHTML: rawResponse, inputName: "cres") ?? ""
                                formData["cres"] = cres
                                let decodedData = Data(base64Encoded: cres.fixedBase64Format) ?? Data()
                                let acsDecodedRS = try? JSONSerialization.jsonObject(with: decodedData, options: []) as? [String: String]
                                let url = getFormAction(rawHTML: rawResponse, formName: "ResForm") ?? ""
                                submitFormData(formUrl: url, formData: formData) { result in
                                    switch result {
                                    case .success(let response):
                                        var acsResponse = AcsResponse()
                                        acsResponse.status = response == "{\"success\":true}" ? true : false
                                        acsResponse.merchantData = acsDecodedRS?["threeDSServerTransID"]
                                        completion(acsResponse)
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                        completion(nil)
                                    }
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                                completion(nil)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        completion(nil)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }

    private func checkStatus(formData: [String: String],
                             _ completion: @escaping (Result<String, NetworkError>) -> Void) {
        sleep(5)
        submitFormData(formUrl: redirectURL, formData: formData) { result in
            switch result {
            case .success(var value):
                value = value.filter { !$0.isWhitespace }
                if value != "IN_PROGRESS" {
                    completion(result)
                } else {
                    checkStatus(formData: formData, completion)
                }
            case .failure:
                completion(result)
            }
        }
    }

    private func submitFormData(formUrl: String,
                                formData: [String: String],
                                completionHandler: @escaping (Result<String, NetworkError>) -> Void) {
        guard let url = URL(string: formUrl) else {
            completionHandler(.failure(.canNotGenerateURL))
            return
        }

        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        var request = URLRequest(url: url)
        request.encodeParameters(parameters: formData)

        let task = URLSession(configuration: config).dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandler(.failure(.undefined))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completionHandler(.failure(.noResponse))
                return
            }
            guard response.statusCode == 200 else {
                completionHandler(.failure(.undefined))
                return
            }
            guard let data = data,
                  let responseString = String(data: data, encoding: String.Encoding.utf8) else {
                completionHandler(.failure(.noData))
                return
            }
            completionHandler(.success(responseString))
        }
        task.resume()
    }

    private func getInputValue(rawHTML: String, inputName: String) -> String? {
        let searchString = "name=\"\(inputName)\" value=\""
        return rawHTML.slice(from: searchString, to: "\"/>")
    }

    private func getFormAction(rawHTML: String, formName: String) -> String? {
        let searchString = "name=\"\(formName)\" action=\""
        return rawHTML.slice(from: searchString, to: "\">")
    }
}

private extension String {

    var fixedBase64Format: Self {
        let offset = count % 4
        guard offset != 0 else { return self }

        return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
    }
}
