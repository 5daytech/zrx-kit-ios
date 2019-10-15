//
//  OrdersCell.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 9/26/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit
import zrxkit
import BigInt

class OrdersCell: UITableViewCell {
  
  static let reuseID = "\(OrdersCell.self)"
  
  @IBOutlet weak var orderBaseAmount: UILabel!
  @IBOutlet weak var orderQuoteAmount: UILabel!
  @IBOutlet weak var orderPrice: UILabel!
  
  private var side: EOrderSide!
  
  func setup(side: EOrderSide) {
    self.side = side
  }
  
  func onBind(order: SignedOrder, position: Int) {
    contentView.backgroundColor = position % 2 == 0 ? UIColor.white : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    
    let makerAmount = Decimal(string: BigUInt(order.makerAssetAmount, radix: 10)!.movePointLeft(18))!
    let takerAmount = Decimal(string: BigUInt(order.takerAssetAmount, radix: 10)!.movePointLeft(18))!
    
    let pricePerToken = side == EOrderSide.BID ? makerAmount / takerAmount : takerAmount / makerAmount
    
    if side == EOrderSide.BID {
      orderBaseAmount.text = "\(takerAmount) Token"
      orderQuoteAmount.text = "\(makerAmount) WETH"
    } else {
      orderBaseAmount.text = "\(makerAmount) Token"
      orderQuoteAmount.text = "\(takerAmount) WETH"
    }
    
    orderPrice.text = "\(pricePerToken) WETH per Token"
  }
}
