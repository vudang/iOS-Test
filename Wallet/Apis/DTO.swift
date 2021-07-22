//
//  DTO.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import Foundation

public protocol NetworkResponseStatusProtocol {
    associatedtype Model: Decodable
    var data: Model { get }
}

public struct MessageDTO<T: Decodable>: Decodable, NetworkResponseStatusProtocol {
    public var data: T
}

public struct OptionalMessageDTO<T: Decodable>: Decodable, NetworkResponseStatusProtocol {
    public typealias Model = Optional<T>
    public var data: Model
}
