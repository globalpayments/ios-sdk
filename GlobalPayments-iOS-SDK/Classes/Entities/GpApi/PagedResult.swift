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

    // GET /disputes list response metadata (filter echoed back by the gateway)
    public var filterPage: Int? = nil
    public var filterPageSize: Int? = nil
    public var filterOrder: String? = nil
    public var filterOrderBy: String? = nil
    public var filterArn: String? = nil
    public var filterBrand: String? = nil
    public var filterStatus: String? = nil
    public var filterStage: String? = nil
    public var filterFromStageTimeCreated: String? = nil
    public var filterToStageTimeCreated: String? = nil
    public var filterSystemMid: String? = nil
    public var filterSystemHierarchy: String? = nil
    /// Details of the action executed (id, type, time created, result code, app id and app name).
    public var action: ActionSummary? = nil
}
