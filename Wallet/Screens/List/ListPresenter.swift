//
//  ListPresenter.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import Foundation
import RxSwift

typealias ListPresenterDependencies = (
    interactor: ListInteractor,
    router: ListRouterOutput
)

protocol ListViewInputs: AnyObject {
    func reloadData(_ data: ListEntities)
    func reloadCounters(_ counters: [String])
    func indicator(animate: Bool)
}

final class ListPresenter: Presenterable {

    internal var entities: ListEntities?
    private weak var view: ListViewInputs!
    let dependencies: ListPresenterDependencies
    private var counter: String?

    init(view: ListViewInputs,
         dependencies: ListPresenterDependencies)
    {
        self.view = view
        self.dependencies = dependencies
    }
}

extension ListPresenter: ListViewOutputs {
    func viewDidLoad() {
        view.indicator(animate: true)
        view.reloadCounters(Counter.allCases.map{ $0.rawValue })
        dependencies.interactor.searchCurrencies()
    }
    
    func changeCounter(_ counter: String) {
        self.counter = counter
        view.indicator(animate: true)
        dependencies.interactor.searchCurrencies(counter: counter)
    }
    
    func searchCurrency(with keyword: String?) {
        view.indicator(animate: true)
        dependencies.interactor.filterCurrencies(name: keyword)
    }
    
    func pullToRefresh() {
        dependencies.interactor.searchCurrencies(counter: counter)
    }
    
    func didSelected(_ currency: Currency) {
        dependencies.router.transitionDetail(currency)
    }
}

extension ListPresenter: ListInteractorOutputs {
    func onSuccessSearch(res: [Currency]) {
        view.reloadData(ListEntities(entryEntity: ListEntryEntity(currencies: res)))
        view.indicator(animate: false)
    }

    func onErrorSearch(error: Error) {
        view.indicator(animate: false)
    }
}
