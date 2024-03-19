import Foundation

public class FileProcessingService {
    
    public static func initiate() -> FileProcessingBuilder<FileProcessor> {
        return FileProcessingBuilder<FileProcessor>(fileProcessingActionType:.CREATE_UPLOAD_URL)
    }
    
    public static func getDetails(resourceId: String?) -> FileProcessingBuilder<FileProcessor> {
        return FileProcessingBuilder<FileProcessor>(fileProcessingActionType: .GET_DETAILS)
            .withResourceId(resourceId)
    }
}
