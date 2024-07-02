import Foundation

public class DocumentUploadData: NSObject {
    
    /** The file format of the Document to be uploaded. This property MUST be set if using the Document property directly, but will be set automatically if using the DocumentPath property */
    public var docType: MerchantDocumentType?
    
    /**
     * The document data in base64 format.
     * This property can be assigned to directly (the DocType property must also be provided a value) or
     *This property will be set automatically by setting the DocumentPath property
    */
    public var document: String?

    /**
     * The type of document you've been asked to provide by ProPay's Risk team. Valid values are:
     * Verification, FraudHolds, Underwriting, RetrievalRequest
    */
    public var docCategory: MerchantDocumentCategory?
}
