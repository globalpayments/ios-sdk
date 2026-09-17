import Foundation

public struct PagedResult<T> {
    public let totalRecordCount: Int?
    public let pageSize: Int
    public let page: Int
    public let order: String?
    public let orderBy: String?
    public var results = [T]()

    // Step 4: GET /transactions list response metadata
    public var currentPageSize: Int? = nil
    public var merchantId: String? = nil
    public var merchantName: String? = nil
    public var accountId: String? = nil
    public var accountName: String? = nil
    public var filterFromTimeCreated: String? = nil
    public var filterToTimeCreated: String? = nil
}
