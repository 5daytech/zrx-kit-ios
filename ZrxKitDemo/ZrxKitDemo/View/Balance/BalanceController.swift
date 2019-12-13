//
//  BalanceController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 12/9/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit
import RxSwift

class BalanceController: UIViewController {
  static func instance(viewModel: MainViewModel) -> BalanceController {
    let view = BalanceController()
    view.viewModel = viewModel
    return view
  }
  
  let disposeBag = DisposeBag()
  private var viewModel: MainViewModel!
  @IBOutlet weak var ethLabel: UILabel!
  @IBOutlet weak var wethLabel: UILabel!
  @IBOutlet weak var tokenLabel: UILabel!
  @IBOutlet weak var lastBlockLabel: UILabel!
  @IBOutlet weak var ethAmountField: UITextField!
  @IBOutlet weak var wethAmountField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
    
    for (index, adapter) in viewModel.adapters.enumerated() {
    Observable.merge([adapter.lastBlockHeightObservable, adapter.syncStateObservable, adapter.balanceObservable])
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] in
          self?.update(index: index)
        })
        .disposed(by: disposeBag)
    }
  }
  
  private func update(index: Int) {
    let adapter = viewModel.adapters[index]
    switch index {
    case 0:
      ethLabel.text = "ETH: \(adapter.balance)"
    case 1:
      wethLabel.text = "WETH: \(adapter.balance)"
    case 2:
      tokenLabel.text = "ZRX: \(adapter.balance)"
    default:
      break
    }
    lastBlockLabel.text = "Last block: \(adapter.lastBlockHeight.map { "\($0)" } ?? "n/a")"
  }
  
  @objc func refresh() {
    viewModel.ethereumKit.refresh()
  }
  
  @IBAction func wrapAction(_ sender: Any) {
    guard let amountStr = ethAmountField.text else {
      return
    }
    if let wrapAmount = Decimal(string: amountStr) {
      viewModel.wrapEther(wrapAmount)
    } else {
      print("Invalid input amount")
    }
  }
  
  @IBAction func unwrapAction(_ sender: Any) {
    guard let amountStr = wethAmountField.text else {
      return
    }
    if let unwrapAmount = Decimal(string: amountStr) {
      viewModel.unwrapEther(unwrapAmount)
    } else {
      print("Invalid input amount")
    }
  }
}
