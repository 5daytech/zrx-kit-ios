//
//  OrdersController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 9/19/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit
import RxSwift
import zrxkit

protocol OrdersControllerDelegate {
  func showCreateOrderStep(_ side: EOrderSide)
  func showConfirmOrderStep(_ side: EOrderSide, _ order: SignedOrder)
}

class OrdersController: UIViewController {
  static func instance(viewModel: MainViewModel, type: EOrderSide) -> OrdersController {
    let ordersController = OrdersController()
    ordersController.viewModel = viewModel
    ordersController.side = type
    return ordersController
  }
  
  private let disposeBag = DisposeBag()
  
  var viewModel: MainViewModel!
  var side: EOrderSide!
  var delegate: OrdersControllerDelegate?
  
  @IBOutlet var tableView: UITableView!
  
  private var orders = [SignedOrder]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: String(describing: OrdersCell.self), bundle: Bundle(for: OrdersCell.self)), forCellReuseIdentifier: OrdersCell.reuseID)
    tableView.tableFooterView = UIView()
    tableView.separatorInset = .zero
    
    let ordersObservable = side == .ASK ? viewModel.asks : viewModel.bids
    
    ordersObservable.subscribe(onNext: { (orders) in
      self.orders = orders
      self.tableView.reloadData()
    }, onError: { (error) in
      print(error)
    }).disposed(by: disposeBag)
    
    viewModel.orderInfoEvent.subscribe { (event) in
      
      
    }.disposed(by: disposeBag)
    
    viewModel.refreshOrders()
  }
  
  @IBAction func onCreateOrderAction(_ sender: UIButton) {
    delegate?.showCreateOrderStep(side)
  }
}

extension OrdersController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: OrdersCell.reuseID) as? OrdersCell else {
      fatalError()
    }
    
    cell.setup(side: side)
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? OrdersCell else {
      fatalError()
    }
    cell.onBind(order: orders[indexPath.row], position: indexPath.row)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    delegate?.showConfirmOrderStep(side, orders[indexPath.row])
  }
}
