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
    
    viewControllers = [balanceNavigation]
  }
}
