//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.text = "99일"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    // Observable
    let disposeBag = DisposeBag()
    
    let year = BehaviorSubject<Int>(value: 2024)
    let month = BehaviorSubject<Int>(value: 3)
    let day = BehaviorSubject<Int>(value: 29)
    let info = BehaviorSubject<Bool>(value: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        bind()
        configureLayout()
    }
    
    private func bind() {
        
        year
            .observe(on: MainScheduler.instance)
            .subscribe(with:self) { owner, value in
                owner.yearLabel.text = String(value) + "년"
            }
            .disposed(by: disposeBag)
        
        month
            .map { String($0) + "월"}
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        day
            .map { String($0) + "일"}
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        birthDayPicker.rx
            .date
            .bind(with: self) { owner, date in
                let pickerComponent = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                owner.year.onNext(pickerComponent.year!)
                owner.month.on(.next(pickerComponent.month!))
                owner.day.onNext(pickerComponent.day!)
                
                let currentCompoenet = Calendar.current.dateComponents([.year], from: Date())
                let yearCheck = currentCompoenet.year! - pickerComponent.year!
                
                print(yearCheck)
                
                owner.info.onNext(yearCheck < 17)
            }
            .disposed(by: disposeBag)
        
        info
            .bind(with: self) { owner, value in
                owner.infoLabel.text = value ? "17세 이상만 가입 가능합니다" : "가입 가능한 나이입니다."
                owner.infoLabel.textColor = value ? UIColor.red : UIColor.blue
                owner.nextButton.isEnabled = value ? false : true
                owner.nextButton.backgroundColor = value ? UIColor.lightGray : UIColor.blue
            }
            .disposed(by: disposeBag)
        
        nextButton
            .rx
            .tap
            .bind(with: self) { owner, _ in
                let viewController = SignInViewController()
                owner.view.window?.rootViewController = viewController
            }
            .disposed(by: disposeBag)
    }
    
    
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
