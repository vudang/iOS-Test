//
//  Protocol.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public protocol APIRequestProtocol {
    var path: String { get }
    var params: [String: Any]? { get }
    var header: [String: String]? { get }
}

public protocol NetworkProtocol {
     static func request(using router: APIRequestProtocol, method m: HTTPMethod, encoding e: ParameterEncoding) -> Observable<(HTTPURLResponse, Data)>
}

public struct Response<T: Decodable> {
    public let httpResponse: HTTPURLResponse
    public let response: T
}

public extension NetworkProtocol {
    static func customResponse<E: Decodable>(using router: APIRequestProtocol,
                                                      method m: HTTPMethod = .get,
                                                      encoding e: ParameterEncoding = URLEncoding.default,
                                                      transform: @escaping (Data) throws -> E) -> Observable<(HTTPURLResponse, E)>
    {
        return self.request(using: router, method: m, encoding: e)
            .map { ($0.0, try transform($0.1)) }
            .retry { e in
                return e.enumerated().flatMap { (data) -> Observable<Int> in
                    let error = data.1
                    let errorCode = (error as NSError).code
                    guard (errorCode == StatusCodeResponse.internalServer.rawValue), data.0 < 3 else {
                        return Observable.error(data.1)
                    }
                    return Observable<Int>.timer(RxTimeInterval.seconds(5), scheduler: MainScheduler.asyncInstance).take(1)
                }
            }
    }
    
    static func requestDTO<E: Decodable>(using router: APIRequestProtocol,
                                                method m: HTTPMethod = .get,
                                                encoding e: ParameterEncoding = URLEncoding.default,
                                                block: ((JSONDecoder) -> Void)? = nil) -> Observable<(HTTPURLResponse, E)> {
        return self.customResponse(using: router,
                                   method: m,
                                   encoding: e,
                                   transform: { try E.toModel(from: $0, block: block) })
    }
    
    
    static func responseDTO<E: Decodable>(decodeTo type:E.Type,
                                                using router: APIRequestProtocol,
                                                method m: HTTPMethod = .get,
                                                encoding e: ParameterEncoding = URLEncoding.default,
                                                block: ((JSONDecoder) -> Void)? = nil) -> Observable<Response<E>> {
        let r: Observable<(HTTPURLResponse, E)> = self.requestDTO(using: router, method: m, encoding: e, block: block)
        return r.map { Response(httpResponse: $0.0, response: $0.1) }
    }
    
}
