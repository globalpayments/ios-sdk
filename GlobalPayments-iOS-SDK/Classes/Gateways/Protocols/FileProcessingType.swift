import Foundation

protocol FileProcessingType {
    func processFileUpload<T>(builder: FileProcessingBuilder<T>,
                          completion: ((T?, Error?) -> Void)?)
}

