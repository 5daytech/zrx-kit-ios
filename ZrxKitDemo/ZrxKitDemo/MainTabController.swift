//
//  MainTabController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 9/19/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {
  
  enum CardState {
    case expanded
    case collapsed
    case keyboardExpanded(_ height: CGFloat)
    case keyboardCollapsed
  }
  
  let animationDuration: TimeInterval = 0.9
  var cardVisible = false
  var nextState: CardState {
    return cardVisible ? .collapsed : .expanded
  }
  
  var runningAnimations = [UIViewPropertyAnimator]()
  var animationProgressWhenInterapted: CGFloat = 0
  var visualEffectView: UIVisualEffectView!
  var createOrderController: CreateOrderController!
  let cardViewSpacing: CGFloat = 16
  
  let viewModel = MainViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let balanceController = BalanceController()
    balanceController.viewModel = viewModel
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
    
    viewControllers = [balanceNavigation, transactionsNavigation, asksNavigation, bidsNavigation]
    
    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    let userInfo = notification.userInfo
    let frame  = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    animateTransitionIfNeeded(state: .keyboardExpanded(frame.height), duration: 0.5)
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    animateTransitionIfNeeded(state: .keyboardCollapsed, duration: 0.5)
  }
  
  func setupCreateOrder(_ side: EOrderSide) {
    visualEffectView = UIVisualEffectView()
    visualEffectView.frame = self.view.frame
    self.view.addSubview(visualEffectView)
    
    createOrderController = CreateOrderController.instance(side, viewModel)
    self.addChild(createOrderController)
    self.view.addSubview(createOrderController.view)
    
    createOrderController.view.frame = CGRect(x: self.cardViewSpacing, y: self.view.frame.height - CreateOrderController.collapsedHeight, width: self.view.bounds.width - (2 * self.cardViewSpacing), height: CreateOrderController.expandedHeight)
    
    createOrderController.view.clipsToBounds = true
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
    
    createOrderController.view.addGestureRecognizer(tapGestureRecognizer)
    createOrderController.view.addGestureRecognizer(panGestureRecognizer)
  }
  
  @objc func handleCardTap(recognizer: UITapGestureRecognizer) {
    switch recognizer.state {
    case .ended:
      animateTransitionIfNeeded(state: nextState, duration: animationDuration)
    default:
      break
    }
  }
  
  @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      startInteractiveTransition(state: nextState, duration: animationDuration)
    case .changed:
      let translation = recognizer.translation(in: self.createOrderController.view)
      var fractionComplete = translation.y / CreateOrderController.expandedHeight
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
          self.createOrderController.view.frame.origin.y = self.view.frame.height - CreateOrderController.expandedHeight - self.cardViewSpacing
        case .collapsed:
          self.createOrderController.view.frame.origin.y = self.view.frame.height - CreateOrderController.collapsedHeight
        case .keyboardExpanded(let keyboardHeight):
          self.createOrderController.view.frame.origin.y = self.view.frame.height - CreateOrderController.expandedHeight - keyboardHeight - self.cardViewSpacing
        case .keyboardCollapsed:
          self.createOrderController.view.frame.origin.y = self.view.frame.height - CreateOrderController.expandedHeight
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
        if !self.cardVisible {
          self.createOrderController.removeFromParent()
          self.createOrderController.view.removeFromSuperview()
          self.visualEffectView.removeFromSuperview()
        }
      }
      
      frameAnimator.startAnimation()
      runningAnimations.append(frameAnimator)
      
      let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
        switch state {
        case .collapsed:
          self.createOrderController.view.layer.cornerRadius = 0
        case .expanded:
          self.createOrderController.view.layer.cornerRadius = 12
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
}

extension MainTabController: OrdersControllerDelegate {
  func showCreateOrderStep(_ side: EOrderSide) {
    setupCreateOrder(side)
    animateTransitionIfNeeded(state: nextState, duration: animationDuration)
  }
}
