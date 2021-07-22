//
//  APIRouter.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//


public enum APIRouter: APIRequestProtocol {
    case fetchPrices(currency: String?)
}


// MARK: - Path define
extension APIRouter {
    public var path: String {
        switch self {
        case .fetchPrices(_):
            return "\(API.domain)/api/v3/price/all_prices_for_mobile"
        }
    }
}


// MARK: - Params
extension APIRouter {
    public var params: [String : Any]? {
        switch self {
        case .fetchPrices(let currency):
            if let c = currency {
                return ["counter_currency": c]
            }
            return nil
        }
    }
}

// MARK: - Header
var defaultHeader: [String: String] = [:]
extension APIRouter {
    public var header: [String : String]? {
        switch self {
        default:
            return defaultHeader
        }
    }
}
