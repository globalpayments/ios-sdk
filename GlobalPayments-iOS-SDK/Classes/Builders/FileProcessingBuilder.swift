import Foundation

 public class FileProcessingBuilder<TResult>: BaseBuilder<TResult> {
    
    var resourceId: String?
    let fileProcessingActionType: FileProcessingActionType
    
    init(fileProcessingActionType: FileProcessingActionType) {
        self.fileProcessingActionType = fileProcessingActionType
    }
    
    func withResourceId(_ value: String?) -> FileProcessingBuilder {
        self.resourceId = value
        return self
    }
    
    public override func execute(configName: String = "default",
                                 completion: ((TResult?, Error?) -> Void)?) {

        super.execute(configName: configName) { _, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            do {
                let client = try ServicesContainer.shared.fileProcessingClient(configName: configName)
                client.processFileUpload(builder: self, completion: completion)
            } catch {
                completion?(nil, error)
            }
        }
    }
}
