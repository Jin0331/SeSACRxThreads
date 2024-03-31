//
//  SampleViewController.swift
//  SeSACRxThreads
//
//  Created by JinwooLee on 3/31/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class SampleViewController: UIViewController {
    
    let userTextField = UITextField().then {
        $0.placeholder = "입력해주세요.."
        $0.borderStyle = .bezel
    }
    let addButton = UIButton().then {
        $0.setTitle("추가", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    let tableView = UITableView()
    
    let items = BehaviorSubject(value: ["Hue", "Bran", "Den"])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        addButton
            .rx
            .tap
            .bind(with: self) { owner, _ in
                
                if let text = owner.userTextField.text, !text.isEmpty {
                    if var value = try? owner.items.value() {
                        value.append(text)
                        owner.items.onNext(value)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        items
        .bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(row)"
            
            return cell
        }
        .disposed(by: disposeBag)
        
        
        tableView.rx.itemSelected.subscribe(with:self) { owner,indexPath in
            if var value = try? owner.items.value() {
                value.remove(at: indexPath.row)
                owner.items.onNext(value)
            }
        }.disposed(by: disposeBag)
        
    }
    
    func configureView() {
        view.backgroundColor = .white
        tableView.backgroundColor = .lightGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(userTextField)
        view.addSubview(addButton)
        view.addSubview(tableView)
                
        addButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.size.equalTo(70)
        }
        
        userTextField.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.trailing.equalTo(addButton.snp.leading).offset(10)
        }

        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(10)
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    deinit {
        print("BasicTableViewController deinit")
    }
}
