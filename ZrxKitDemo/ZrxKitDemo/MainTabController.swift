//
//  MainTabController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 9/19/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit
import zrxkit
import Web3

class MainTabController: UITabBarController {
  
  enum CardState {
    case expanded
    case collapsed
    case keyboardExpanded(_ height: CGFloat)
    case keyboardCollapsed
  }
  
  var cardVisible = false
  var nextState: CardState {
    return cardVisible ? .collapsed : .expanded
  }
  
  var runningAnimations = [UIViewPropertyAnimator]()
  var animationProgressWhenInterapted: CGFloat = 0
  var visualEffectView: UIVisualEffectView!
  var cardViewController: CardViewController!
  let cardViewSpacing: CGFloat = 16
  
  var nextCardViews: [CardViewController] = []
  
  var isLoading = false
  
  let viewModel = MainViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.mainTabBarController = self
    
    let balanceController = BalanceController.instance(viewModel: viewModel)
    let balanceNavigation = UINavigationController(rootViewController: balanceController)
    balanceNavigation.tabBarItem.title = "Balance"
    
    let asksController = OrdersController.instance(viewModel: viewModel, type: .ASK)
    asksController.delegate = self
    let asksNavigation = UINavigationController(rootViewController: asksController)
    asksNavigation.tabBarItem.title = "ASKS"
    
    let bidsController = OrdersController.instance(viewModel: viewModel, type: .BID)
    bidsController.delegate = self
    let bidsNavigation = UINavigationController(rootViewController: bidsController)
    bidsNavigation.tabBarItem.title = "BIDS"
    
    let transactionsController = TransactionsController.instance(viewModel: viewModel)
    let transactionsNavigation = UINavigationController(rootViewController: transactionsController)
    transactionsNavigation.tabBarItem.title = "Transactions"
    
    viewControllers = [balanceNavigation, transactionsNavigation, bidsNavigation, asksNavigation]
    
    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    let userInfo = notification.userInfo
    let frame  = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    if cardViewController != nil {
      animateTransitionIfNeeded(state: .keyboardExpanded(frame.height), duration: 0.5)
    }
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    if cardViewController != nil {
      animateTransitionIfNeeded(state: .keyboardCollapsed, duration: 0.5)
    }
  }
  
  func setupCardViewController(_ vc: CardViewController) {
    visualEffectView = UIVisualEffectView()
    visualEffectView.frame = self.view.frame
    self.view.addSubview(visualEffectView)
    
    cardViewController = vc
    
    self.addChild(cardViewController)
    self.view.addSubview(cardViewController.view)
    
    cardViewController.view.frame = CGRect(x: self.cardViewSpacing, y: self.view.frame.height - cardViewController.collapsedHeight, width: self.view.bounds.width - (2 * self.cardViewSpacing), height: cardViewController.expandedHeight)
    
    cardViewController.view.clipsToBounds = true
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
    
    cardViewController.view.addGestureRecognizer(tapGestureRecognizer)
    cardViewController.view.addGestureRecognizer(panGestureRecognizer)
  }
  
  @objc func handleCardTap(recognizer: UITapGestureRecognizer) {
    switch recognizer.state {
    case .ended:
      animateTransitionIfNeeded(state: nextState, duration: cardViewController!.animationDuration)
    default:
      break
    }
  }
  
  @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      startInteractiveTransition(state: nextState, duration: cardViewController!.animationDuration)
    case .changed:
      let translation = recognizer.translation(in: self.cardViewController.view)
      var fractionComplete = translation.y / cardViewController.expandedHeight
      fractionComplete = cardVisible ? fractionComplete : -fractionComplete
      updateInteractiveTransition(fractionCompleted: fractionComplete)
    case .ended:
      continueInteractiveTransition()
    default:
      break
    }
  }
  
  func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
    if runningAnimations.isEmpty {
      let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        switch state {
        case .expanded:
          self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardViewController.expandedHeight - self.cardViewSpacing
        case .collapsed:
          self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardViewController.collapsedHeight
        case .keyboardExpanded(let keyboardHeight):
          self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardViewController.expandedHeight - keyboardHeight - self.cardViewSpacing
        case .keyboardCollapsed:
          self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardViewController.expandedHeight
        }
      }
      
      frameAnimator.addCompletion { (_) in
        switch state {
        case .collapsed:
          self.cardVisible = false
        case .expanded:
          self.cardVisible = true
        default:
          break
        }
        self.runningAnimations.removeAll()
        if !self.cardVisible && self.cardViewController != nil {
          self.cardViewController.removeFromParent()
          self.cardViewController.view.removeFromSuperview()
          self.visualEffectView.removeFromSuperview()
          self.cardViewController = nil
          self.checkNext()
          
        }
      }
      
      frameAnimator.startAnimation()
      runningAnimations.append(frameAnimator)
      
      let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
        switch state {
        case .collapsed:
          self.cardViewController.view.layer.cornerRadius = 0
        case .expanded:
          self.cardViewController.view.layer.cornerRadius = 12
        default:
          break
        }
      }
      
      cornerRadiusAnimator.startAnimation()
      runningAnimations.append(cornerRadiusAnimator)
      
      let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        switch state {
        case .expanded:
          self.visualEffectView.effect = UIBlurEffect(style: .dark)
        case .collapsed:
          self.visualEffectView.effect = nil
        default:
          break
        }
      }
      
      blurAnimator.startAnimation()
      runningAnimations.append(blurAnimator)
    }
  }
  
  func startInteractiveTransition(state: CardState, duration: TimeInterval) {
    if runningAnimations.isEmpty {
      animateTransitionIfNeeded(state: state, duration: duration)
    }
    
    for animator in runningAnimations {
      animator.pauseAnimation()
      animationProgressWhenInterapted = animator.fractionComplete
    }
  }
  
  func updateInteractiveTransition(fractionCompleted: CGFloat) {
    for animator in runningAnimations {
      animator.fractionComplete = fractionCompleted + animationProgressWhenInterapted
    }
  }
  
  func continueInteractiveTransition() {
    for animator in runningAnimations {
      animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
  }
  
  func checkNext() {
    if isLoading {
      let vc = LoadingView()
      setupCardViewController(vc)
      animateTransitionIfNeeded(state: .expanded, duration: vc.animationDuration)
    } else {
      if !nextCardViews.isEmpty {
        let vc = nextCardViews[0]
        setupCardViewController(vc)
        animateTransitionIfNeeded(state: .expanded, duration: vc.animationDuration)
        nextCardViews.remove(at: 0)
      }
    }
  }
  
  func showLoading() {
    if self.isLoading { return }
    self.isLoading = true
    if cardViewController == nil {
      checkNext()
    }
  }
  
  func hideLoading() {
    if !isLoading { return }
    isLoading = false
    animateTransitionIfNeeded(state: .collapsed, duration: 0)
  }
  
  func showReceipt(receipt: EthereumTransactionReceiptObject) {
    nextCardViews.append(ReceiptView.instance(receipt: receipt))
    if cardViewController == nil {
      checkNext()
    }
  }
}

extension MainTabController: OrdersControllerDelegate {
  func showCreateOrderStep(_ side: EOrderSide) {
    let vc = CreateOrderController.instance(side, viewModel)
    vc.cardViewDelegate = self
    setupCardViewController(vc)
    animateTransitionIfNeeded(state: .expanded, duration: vc.animationDuration)
  }
  
  func showConfirmOrderStep(_ side: EOrderSide, _ order: SignedOrder) {
    let vc = ConfirmOrderController.instance(viewModel: viewModel, order, side)
    vc.cardViewDelegate = self
    setupCardViewController(vc)
    animateTransitionIfNeeded(state: .expanded, duration: vc.animationDuration)
  }
}

extension MainTabController: CardViewControllerDelegate {
  func dismissController(duration: TimeInterval) {
    animateTransitionIfNeeded(state: .collapsed, duration: duration)
  }
}
