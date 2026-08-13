import Foundation

/// Test data for Click to Pay decrypt tests.
///
/// **QA Instructions:**
/// 1. Generate a fresh encrypted payload from the Visa SRC SDK.
/// 2. Replace `encryptedPayload` below with the new JWT string.
/// 3. Run the tests immediately — tokens expire ~60 seconds after generation.
///
/// Leave `encryptedPayload` as `nil` to skip the CTP decrypt tests automatically.
struct GpApiClickToPayTestData {

    // MARK: - Token (replace before running)

    /// The short-lived JWT encrypted payload from the Visa SRC SDK.
    /// Paste a fresh value here, then run the tests straight away.
    static let encryptedPayload: String? = nil

    // MARK: - Static reference data (stable, no need to change)

    static let dpaReference: String = "08f56394-4599-af88-ff38-1a64db7c6502"
    static let dataTypeIndicator: String = "FULL"
}
