//
//  PorticoRequestData.swift
//  GlobalPayments-iOS-SDK
//
//  Created by Yashwant Patil on 18/02/26.
//

import Foundation

protocol PorticoRequestData {
    associatedtype Builder
    associatedtype Config
    associatedtype Payload
    
    func generateRequest(for builder: Builder, config: Config) -> Payload
}
