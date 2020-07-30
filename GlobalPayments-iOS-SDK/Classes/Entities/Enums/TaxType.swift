import Foundation

/// Indicates the tax type.
public enum TaxType: String {
    /// Indicates tax was not used.
    case notUsed
    /// Indicates sales tax was applied.
    case salesTax
    /// Indicates tax exemption.
    case taxExempt
}
