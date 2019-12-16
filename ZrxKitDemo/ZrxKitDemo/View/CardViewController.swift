//
//  CardViewController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 12/13/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit

protocol CardViewControllerDelegate {
  func dismissController(duration: TimeInterval)
}

class CardViewController: UIViewController {
  var expandedHeight: CGFloat {
    return 0
  }
  var collapsedHeight: CGFloat {
    return 0
  }
  var animationDuration: TimeInterval {
    return 0
  }
  
  var cardViewDelegate: CardViewControllerDelegate?
}
