import Foundation

struct ResourceLoader {

    enum FileExtension: String {
        case pdf
        case png
        case jpeg
        case gif
        case tiff
        case tif
        case jfif
    }

    static func loadFile(name: String,
                         extension: FileExtension,
                         bundle: Bundle = Bundle.main) -> Data? {

        if let url = bundle.url(forResource: name, withExtension: `extension`.rawValue) {
            do {
                return try Data(contentsOf: url)
            } catch {
                print("ResouceLoader error: \(error)")
                return nil
            }
        }
        return nil
    }
}
