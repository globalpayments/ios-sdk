//
//  ApmCategory.swift
//  Pods
//
//  Created by Ranu Dhurandhar on 13/05/26.
//

import Foundation

public enum ApmCategory: String, Mappable, CaseIterable {

    case BNPL

    public init?(value: String?) {
        guard let value = value,
              let category = ApmCategory(rawValue: value) else { return nil }
        self = category
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
