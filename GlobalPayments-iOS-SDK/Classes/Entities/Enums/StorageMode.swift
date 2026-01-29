//
//  StorageMode.swift
//  GlobalPayments-iOS-SDK
//

import Foundation

public enum StorageMode: String, CaseIterable {
    ///Always store the data.
    case always = "ALWAYS"
    
    ///Never store the data.
    case off = "OFF"
    
    ///Prompt the user before storing the data.
    case prompt = "PROMPT"
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
