//
//  OrdersController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 9/19/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit
import RxSwift

class OrdersController: UIViewController {
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let vm = MainViewModel()
    vm.wethContract.totalSupply
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { supply in
        print(supply)
      }, onError: { error in
        print(error)
      })
      .disposed(by: disposeBag)
  }
}
