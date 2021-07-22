//
//  Decodable+Extension.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//


import UIKit

extension Decodable {
    static func toModel(from data: Data, block: ((JSONDecoder) -> Void)? = nil) throws -> Self {
        let decoder = JSONDecoder()
        let d = data
        // custom
        block?(decoder)
        do {
            let result = try decoder.decode(self, from: d)
            return result
        } catch let err as NSError {
            throw err
        }
    }
}
