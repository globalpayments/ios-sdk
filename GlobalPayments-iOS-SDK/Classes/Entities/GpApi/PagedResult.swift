import Foundation

public struct PagedResult<T> {
    public let totalRecordCount: Int?
    public let pageSize: Int
    public let page: Int
    public let order: String?
    public let orderBy: String?
    public var results = [T]()
}
