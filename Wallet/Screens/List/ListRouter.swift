//
//  ListRouter.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import Foundation
import UIKit

struct ListRouterInput {

    func view() -> ListViewController {
        let view = ListViewController()
        let interactor = ListInteractor()
        let dependencies = ListPresenterDependencies(interactor: interactor, router: ListRouterOutput(view))
        let presenter = ListPresenter(view: view, dependencies: dependencies)
        view.presenter = presenter
        interactor.presenter = presenter
        return view
    }

    func push(from: Viewable) {
        let view = self.view()
        from.push(view, animated: true)
    }

    func present(from: Viewable) {
        let nav = UINavigationController(rootViewController: view())
        from.present(nav, animated: true)
    }
}

final class ListRouterOutput: Routerable {

    private(set) weak var view: Viewable!

    init(_ view: Viewable) {
        self.view = view
    }

    func transitionDetail(_ currency: Currency) {
        // TODO: show detail 
    }
}


