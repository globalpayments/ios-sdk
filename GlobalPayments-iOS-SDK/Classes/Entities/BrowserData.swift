import Foundation

public class BrowserData {
    public var acceptHeader: String?
    public var colorDepth: ColorDepth?
    public var ipAddress: String?
    public var javaEnabled: Bool?
    public var javaScriptEnabled: Bool?
    public var language: String?
    public var screenHeight: Int?
    public var screenWidth: Int?
    public var challengeWindowSize: ChallengeWindowSize?
    public var timezone: String?
    public var userAgent: String?

    public init() { }

    public enum ColorDepth: String {
        case oneBit = "ONE_BIT"
        case twoBits = "TWO_BITS"
        case fourBits = "FOUR_BITS"
        case eightBits = "EIGHT_BITS"
        case fifteenBits = "FIFTEEN_BITS"
        case sixteenBits = "SIXTEEN_BITS"
        case twentyFourBits = "TWENTY_FOUR_BITS"
        case thirtyTwoBits = "THIRTY_TWO_BITS"
        case fortyEightBits = "FORTY_EIGHT_BITS"
    }

    public enum ChallengeWindowSize: String {
        case windowed250x400 = "WINDOWED_250X400"
        case windowed390x400 = "WINDOWED_390X400"
        case windowed500x600 = "WINDOWED_500X600"
        case windowed600x400 = "WINDOWED_600X400"
        case fullScreen = "FULL_SCREEN"
    }
}
