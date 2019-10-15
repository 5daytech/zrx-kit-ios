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

class OrdersController: UITableViewController {
  static func instance(viewModel: MainViewModel, type: EOrderSide) -> OrdersController {
    let ordersController = OrdersController()
    ordersController.viewModel = viewModel
    ordersController.side = type
    return ordersController
  }
  
  private let disposeBag = DisposeBag()
  
  var viewModel: MainViewModel!
  var side: EOrderSide!
  
  private var orders = [SignedOrder]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UINib(nibName: String(describing: OrdersCell.self), bundle: Bundle(for: OrdersCell.self)), forCellReuseIdentifier: OrdersCell.reuseID)
    tableView.tableFooterView = UIView()
    tableView.separatorInset = .zero
    
    let ordersObservable = side == .ASK ? viewModel.asks : viewModel.bids
    
    ordersObservable.subscribe(onNext: { (orders) in
      print("orrrders \(orders.count)")
      self.orders = orders
      self.tableView.reloadData()
    }, onError: { (error) in
      print(error)
    }).disposed(by: disposeBag)
    
    viewModel.orderInfoEvent.subscribe { (event) in
      let view = ConfirmOrderController.instance(viewModel: self.viewModel, event.element!.first, event.element!.second)
      view.modalPresentationStyle = .overCurrentContext
      self.present(view, animated: true, completion: nil)
    }.disposed(by: disposeBag)
    
    viewModel.refreshOrders()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: OrdersCell.reuseID) as? OrdersCell else {
      fatalError()
    }
    cell.setup(side: side)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? OrdersCell else {
      fatalError()
    }
    cell.onBind(order: orders[indexPath.row], position: indexPath.row)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    viewModel.onOrderClick(indexPath.row, side)
  }
}
