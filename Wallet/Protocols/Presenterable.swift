//
//  Presenterable.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import Foundation

protocol Presenterable {
    //    associatedtype V: Viewable
    //    associatedtype I: Interactorable
    //    associatedtype R: Routerable
    //    associatedtype E: PresenterEntities
    //    var dependencies: (view: V, router: R, interactor: I, entities: E) { get }

    associatedtype I: Interactorable
    associatedtype R: Routerable
    var dependencies: (interactor: I, router: R) { get }
}

