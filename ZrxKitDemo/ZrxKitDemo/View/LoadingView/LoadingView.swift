//
//  LoadingView.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 12/16/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit

class LoadingView: CardViewController {
  override var expandedHeight: CGFloat {
    return 300
  }
  
  override var collapsedHeight: CGFloat {
    return 0
  }
  
  override var animationDuration: TimeInterval {
    return 1.5
  }
}
