//
//  Currency.swift
//  Wallet
//
//  Created by tony on 7/20/21.
//  Copyright © 2021 Tsubasa Hayashi. All rights reserved.
//

struct Currency: Codable {
    let base: String?
    let counter: String?
    let buyPrice: String?
    let sellPrice: String?
    let icon: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case base, counter
        case buyPrice = "buy_price"
        case sellPrice = "sell_price"
        case icon, name
    }
}
