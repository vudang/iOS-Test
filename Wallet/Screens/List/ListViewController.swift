//
//  ListViewController.swift
//  Wallet
//
//  Created by Vu Dang on 7/20/21.
//  Copyright © 2021 Vu Dang. All rights reserved.
//

import UIKit
import RxRelay
import RxSwift
import RxCocoa

protocol ListViewOutputs: AnyObject {
    func viewDidLoad()
    func searchCurrency(with keyword: String?)
    func changeCounter(_ counter: String)
    func pullToRefresh()
    func didSelected(_ currency: Currency)
}

final class ListViewController: UIViewController {

    internal var presenter: ListViewOutputs?
    internal let currencySubject = BehaviorRelay<[Currency]>.init(value: [])
    internal let counterSubject = BehaviorRelay<[String]>.init(value: [])
    private lazy var disposeBag = DisposeBag()

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var emptyView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        presenter?.viewDidLoad()
    }
    
    private func configure() {
        view.backgroundColor = .white
        navigationItem.title = "Currency"
        navigationController?.navigationBar.prefersLargeTitles = true
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(filterPressed))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        configureTableView()
        configureSearchBar()
        configureEmptyView()
    }
    
    private func configureTableView() {
        let cellIdentifier = String(describing: ListTableViewCell.self)
        tableView.isHidden = true
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.register(UINib(nibName: ListHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: ListHeaderView.identifier)
        tableView.estimatedSectionHeaderHeight = 44
        
        // add refresh control
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        refresh.tintColor = .orange
        tableView.refreshControl = refresh
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        currencySubject.observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: ListTableViewCell.self)) { (row, data, cell) in
                cell.configure(with: data)
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Currency.self)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] currency in
                self?.presenter?.didSelected(currency)
            }.disposed(by: disposeBag)
        
        currencySubject.skip(1)
            .map { $0.isEmpty }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Search"
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.rx.text
            .distinctUntilChanged()
            .bind(onNext: { [weak self] keyword in
                self?.presenter?.searchCurrency(with: keyword)
            }).disposed(by: disposeBag)
    }
    
    private func configureEmptyView() {
        emptyView.isHidden = true
        currencySubject.skip(1)
            .map { !$0.isEmpty }
            .bind(to: emptyView.rx.isHidden )
            .disposed(by: disposeBag)
    }
    
    @objc func filterPressed() {
        counterSubject.take(1)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] counters in
                self?.showFilterCounter(counters)
            }.disposed(by: disposeBag)
    }
    
    @objc func pullToRefresh() {
        self.presenter?.pullToRefresh()
    }
    
    private func showFilterCounter(_ counters: [String]) {
        var actions: [UIAlertController.AlertAction] = counters.map {
            UIAlertController.AlertAction(title: $0, style: .default)
        }
        actions.append(.action(title: "Close", style: .cancel))

        UIAlertController
            .present(in: self, title: "Choose counter", style: .actionSheet, actions: actions)
            .subscribe(onNext: { [weak self] index in
                guard index < counters.count else {
                    return
                }
                let counter = counters[index]
                self?.presenter?.changeCounter(counter)
            }).disposed(by: disposeBag)
    }
}

extension ListViewController: ListViewInputs {
    func reloadCounters(_ counters: [String]) {
        counterSubject.accept(counters)
    }
    
    func reloadData(_ data: ListEntities) {
        currencySubject.accept(data.entryEntity.currencies ?? [])
        tableView.refreshControl?.endRefreshing()
    }
    
    func indicator(animate: Bool) {
        DispatchQueue.main.async { [weak self] in
            _ = animate ? self?.indicatorView.startAnimating() : self?.indicatorView.stopAnimating()
        }
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListHeaderView.identifier) as! ListHeaderView
        headerView.contentView.backgroundColor = .white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ListViewController: Viewable {}
