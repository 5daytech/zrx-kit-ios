//
//  TransactionsController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 10/2/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit
import RxSwift

class TransactionsController: UIViewController {
  static func instance(viewModel: MainViewModel) -> TransactionsController {
    let view = TransactionsController()
    view.viewModel = viewModel
    return view
  }
  
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var tableView: UITableView!
  var viewModel: MainViewModel!
  
  var lastBlockHeight: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UINib(nibName: TransactionsCell.reuseID, bundle: Bundle(for: TransactionsCell.self)), forCellReuseIdentifier: TransactionsCell.reuseID)
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 150
    
    viewModel.lastBlockHeight.subscribe(onNext: { (lastBH) in
      self.lastBlockHeight = lastBH
    }).disposed(by: disposeBag)
    
    viewModel.transactions.bind(to: tableView.rx.items(cellIdentifier: TransactionsCell.reuseID)) { row, model, cell in
      guard let cell = cell as? TransactionsCell else {
        return
      }
      cell.onBind(tx: model, index: row, lastBlockHeight: self.lastBlockHeight)
    }.disposed(by: disposeBag)
  }
  
  @IBAction func onEthAction(_ sender: UIButton) {
    viewModel.filterTransactions(0)
  }
  
  @IBAction func onWethAction(_ sender: UIButton) {
    viewModel.filterTransactions(1)
  }
  
  @IBAction func onTokenAction(_ sender: UIButton) {
    viewModel.filterTransactions(2)
  }
}
