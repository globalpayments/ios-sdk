import Foundation

public protocol AccessTokenProvider {
    
    func signIn(appId: String, appKey: String, secondsToExpire: Int?, intervalToExpire: IntervalToExpire?, permissions: [String]?) -> GpApiRequest
    
    func signOut() -> GpApiRequest?
}
