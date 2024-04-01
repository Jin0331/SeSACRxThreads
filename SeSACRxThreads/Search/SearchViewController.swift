//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by JinwooLee on 4/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class SearchViewController: UIViewController {

    private let tableView = UITableView().then {
        $0.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        $0.backgroundColor = .white
        $0.rowHeight = 110
        $0.separatorStyle = .none
    }
    
    let searchBar = UISearchBar()
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    let disposeBag = DisposeBag()
    lazy var items = BehaviorSubject(value: data) // 초기화 단계에서 데이터를 사용하려면, 시점을 변경해야 된다.

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        configure()
        setSearchController()
        
        bind()
    }
    
    private func bind() {
        items
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
                cell.appNameLabel.text = "이야호 " + element
                cell.appIconImageView.backgroundColor = .systemCyan
                cell.downloadButton.rx
                    .tap
                    .bind(with: self) { owner, _ in
                        owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 2개의 Observable을 사용해야 하는 경우, zip
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .bind(with: self) { owner, value in
                owner.data.remove(at: value.0.row)
                owner.items.onNext(owner.data)
            }
            .disposed(by: disposeBag)
        
        // SearchBar 관련
        // 실시간 입력
        searchBar
            .rx
            .text
            .orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value) }
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
        
        searchBar
            .rx
            .searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value) }
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
    }
    
    private func setSearchController() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(plusButtonClicked))
    }
    
    @objc func plusButtonClicked() {
        let sample = ["A", "B", "C", "D", "E"]
        data.append(sample.randomElement()!)
        items.onNext(data)
    }
    
    private func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

    }
    
    
    
}
