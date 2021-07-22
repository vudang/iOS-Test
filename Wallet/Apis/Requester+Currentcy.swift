//
//  Requester+Currentcy.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import RxSwift

extension Requester {
    static func fetchListCurrency(_ currency: String?) -> Observable<([Currency]?, Error?)> {
        let router = APIRouter.fetchPrices(currency: currency)
        let request: Observable<(HTTPURLResponse, OptionalMessageDTO<[Currency]>)> = Requester.requestDTO(using: router)
        return request.flatMap { (res) -> Observable<([Currency]?, Error?)> in
            return Observable.just((res.1.data, NSError(domain: "Occurred error!", code: res.0.statusCode, userInfo: nil)))
        }
    }
}
