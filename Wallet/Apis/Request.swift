//
//  Request.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

enum StatusCodeResponse: Int {
    case success = 200
    case internalServer = 500
}

public struct Requester: NetworkProtocol {
    private static let apiTimeout: Int = 240
    private static let manager = Session()
    static let kReponseStatusCode = "kReponseStatusCode"
    
    public static func request(using router: APIRequestProtocol,
                        method m: HTTPMethod = .get,
                        encoding e: ParameterEncoding = URLEncoding.default) -> Observable<(HTTPURLResponse, Data)> {
        let p = router.path
        let params = router.params
        var header: HTTPHeaders?
        if let h = router.header {
            header = HTTPHeaders(h)
        }
        return Observable<(HTTPURLResponse, Data)>.create({ (s) -> Disposable in
            let task = manager.request(p, method: m, parameters: params, encoding: e, headers: header)
            task.responseData { data in
                let result = data.result
                
                guard let response = data.response else {
                    let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
                    s.onError(e)
                    return
                }
                
                switch result {
                case .success(let value):
                    s.onNext((response, value))
                    if response.statusCode == StatusCodeResponse.success.rawValue {
                        s.onCompleted()
                    } else {
                        s.onError(NSError(domain: NSURLErrorDomain,
                                          code: response.statusCode,
                                          userInfo: nil))
                    }
                case .failure(let e):
                    s.onError(e)
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        })
        .observe(on: SerialDispatchQueueScheduler(qos: .background))
        .timeout(RxTimeInterval.seconds(apiTimeout), scheduler: SerialDispatchQueueScheduler(qos: .background))
    }
}
