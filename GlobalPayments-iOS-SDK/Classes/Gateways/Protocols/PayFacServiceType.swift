import Foundation

protocol PayFacServiceType {
    func processPayFac<T>(builder: PayFacBuilder<T>,
                          completion: ((T?, Error?) -> Void)?)
    
    func processBoardingUser<T>(builder: PayFacBuilder<T>,
                                completion: ((T?, Error?) -> Void)?)
}
