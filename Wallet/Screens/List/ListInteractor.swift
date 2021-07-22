//
//  ListInteractor.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import RxSwift
import RxRelay

protocol ListInteractorOutputs: AnyObject {
    func onSuccessSearch(res: [Currency])
    func onErrorSearch(error: Error)
}

final class ListInteractor: Interactorable {

    weak var presenter: ListInteractorOutputs?
    private lazy var disposeBag = DisposeBag()
    private let counterSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private let nameSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private let resultSubject = BehaviorRelay<[Currency]>.init(value: [])
    
    init() {
        self.observerSearchingByCounter()
        self.observerSearchingByName()
    }

    private func observerSearchingByCounter() {
        let timerSubject = Observable<Int>.timer(RxTimeInterval.seconds(0),
                                                 period: RxTimeInterval.seconds(30),
                                                 scheduler: ConcurrentMainScheduler.instance)
        let searchSubject = counterSubject
            .debounce(RxTimeInterval.milliseconds(500), scheduler: ConcurrentMainScheduler.instance)
            .flatMapLatest { Requester.fetchListCurrency($0) }
        
        timerSubject.flatMap { _ in searchSubject }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] res in
                guard let list = res.0 else {
                    self?.resultSubject.accept([])
                    return
                }
                self?.presenter?.onSuccessSearch(res: list)
                self?.resultSubject.accept(list)
            } onError: { [weak self] error in
                self?.presenter?.onErrorSearch(error: error)
                self?.resultSubject.accept([])
            }.disposed(by: disposeBag)
    }
    
    private func observerSearchingByName() {
        Observable.combineLatest(nameSubject.distinctUntilChanged(), resultSubject.skip(1)) { (keyword: $0, currencies: $1) }
            .map { data in
                guard let k = data.keyword, !k.isEmpty else {
                    return data.currencies
                }
                
                return data.currencies.filter { currency in
                    let name = [currency.name ?? "", currency.base ?? ""].joined(separator: " ")
                    return name.lowercased().contains(k.lowercased())
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] list in
                self?.presenter?.onSuccessSearch(res: list)
            }.disposed(by: disposeBag)
    }
    
    func searchCurrencies(counter: String? = nil) {
        self.counterSubject.onNext(counter)
    }
    
    func filterCurrencies(name: String? = nil) {
        self.nameSubject.onNext(name)
    }
}
