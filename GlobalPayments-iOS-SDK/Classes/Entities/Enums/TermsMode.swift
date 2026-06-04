//
//  TermsMode.swift
//  Pods
//
//  Created by Ranu Dhurandhar on 13/05/26.
//

import Foundation

public enum TermsMode: String, Mappable, CaseIterable {

    case BANK_INTEREST
    case NO_INTEREST
    case BANK_PAYMENT

    public init?(value: String?) {
        guard let value = value,
              let mode = TermsMode(rawValue: value) else { return nil }
        self = mode
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
