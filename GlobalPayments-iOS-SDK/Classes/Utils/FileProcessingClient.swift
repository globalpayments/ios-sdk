import Foundation

public class FileProcessingClient {
    
    private let url: URL
    private var urlSession = URLSession.shared
    
    public init(uploadUrl: String) {
        self.url = URL(string: uploadUrl)!
    }
    
    public func uploadFile(file: URL?, completion: ((Data?, Error?) -> Void)?) {
        sendRequest(fileURL: file, completion: completion)
    }
    
    private func sendRequest(fileURL: URL?, completion: ((Data?, Error?) -> Void)?) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("text/csv", forHTTPHeaderField: "Content-Type")
        guard let fileURL = fileURL else {
            completion?(nil, GatewayException(message: "Error file not found"))
            return
        }
        let task = urlSession.uploadTask(
            with: request,
            fromFile: fileURL,
            completionHandler: { data, response, error in
                completion?(data, error)
            }
        )
        task.resume()
    }
}
