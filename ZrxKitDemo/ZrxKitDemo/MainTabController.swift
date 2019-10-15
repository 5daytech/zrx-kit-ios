//
//  MainTabController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 9/19/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let viewModel = MainViewModel()
    
    let balanceController = BalanceController()
    balanceController.viewModel = viewModel
    let balanceNavigation = UINavigationController(rootViewController: balanceController)
    balanceNavigation.tabBarItem.title = "Balance"
    
    let asksController = OrdersController.instance(viewModel: viewModel, type: .ASK)
    let asksNavigation = UINavigationController(rootViewController: asksController)
    asksNavigation.tabBarItem.title = "ASKS"
    
    let bidsController = OrdersController.instance(viewModel: viewModel, type: .BID)
    let bidsNavigation = UINavigationController(rootViewController: bidsController)
    bidsNavigation.tabBarItem.title = "BIDS"
    
    let transactionsController = TransactionsController.instance(viewModel: viewModel)
    let transactionsNavigation = UINavigationController(rootViewController: transactionsController)
    transactionsNavigation.tabBarItem.title = "Transactions"
    
    
    viewControllers = [balanceNavigation, transactionsNavigation, asksNavigation, bidsNavigation]
  }
}
