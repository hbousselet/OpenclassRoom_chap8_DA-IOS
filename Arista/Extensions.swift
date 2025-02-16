//
//  Extensions.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 16/02/2025.
//

import Foundation

enum ErrorHandler: Error {
    case none
    case fetchCoreDataFailed(String)
    case writeInCoreDataFailed(String)
    
    var failureReason: String? {
        switch self {
        case .fetchCoreDataFailed(let reason): return reason
        case .writeInCoreDataFailed(let reason): return reason
        default: return nil
        }
    }
}
