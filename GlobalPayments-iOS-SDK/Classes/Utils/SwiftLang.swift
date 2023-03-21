import Foundation

public class SwiftLang {

    public static func getVersion() -> String {
        var currentVersion = "5.0"

        #if swift(>=5.3)
        currentVersion = "5.3"
        #elseif swift(>=5.4)
        currentVersion = "5.4"
        #elseif swift(>=5.5)
        currentVersion = "5.5"
        #endif

        return currentVersion
    }
}
