//
//  Extensions.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 16/02/2025.
//

import Foundation

enum ErrorHandler: Error {
    case none
    case cantLoadRepository(String)
    case fetchCoreDataFailed(String)
    case writeInCoreDataFailed(String)
    
    var failureReason: String? {
        switch self {
        case .cantLoadRepository(let reason): return reason
        case .fetchCoreDataFailed(let reason): return reason
        case .writeInCoreDataFailed(let reason): return reason
        default: return nil
        }
    }
}

protocol Repository {
    associatedtype T
    func getAsync<T>() async throws -> [T]?
}

