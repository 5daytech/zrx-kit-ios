//
//  ConfirmOrderController.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 10/3/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit
import zrxkit
import BigInt

class ConfirmOrderController: CardViewController {
  
  static func instance(viewModel: MainViewModel, _ order: SignedOrder, _ side: EOrderSide) -> ConfirmOrderController {
    let view = ConfirmOrderController()
    view.side = side
    view.order = order
    
    let makerAmount = Decimal(string: BigUInt(order.makerAssetAmount, radix: 10)!.movePointLeft(18))!
    let takerAmount = Decimal(string: BigUInt(order.takerAssetAmount, radix: 10)!.movePointLeft(18))!
    
    view.makerAmount = makerAmount
    view.takerAmount = takerAmount
    
    let pricePerToken = side == EOrderSide.BID ? makerAmount / takerAmount : takerAmount / makerAmount
    view.price = pricePerToken
    
    view.viewModel = viewModel
    
    return view
  }
  
  override var expandedHeight: CGFloat {
    return 300
  }
  
  override var animationDuration: TimeInterval {
    return 0.5
  }
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var perTokenLabel: UILabel!
  @IBOutlet weak var fillAmountField: UITextField!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var tradeButton: UIButton!
  
  private var side: EOrderSide!
  private var order: SignedOrder!
  private var price: Decimal!
  private var makerAmount: Decimal!
  private var takerAmount: Decimal!
  private var viewModel: MainViewModel!
  
  private var isMyOrder: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    switch side! {
    case .ASK:
      titleLabel.text = "Buy Token for WETH"
      amountLabel.text = "\(makerAmount!) Token"
    case .BID:
      titleLabel.text = "Sell Token for WETH"
      amountLabel.text = "\(takerAmount!) Token"
    }
    
    perTokenLabel.text = "Per token: \(price!) WETH"
    
    isMyOrder = order.makerAddress == viewModel.ethereumKit.receiveAddress.lowercased()
    
    tradeButton.setTitle(isMyOrder ? "Cancel" : "Trade", for: .normal)
  }  
  
  @IBAction func onTradeAction(_ sender: UIButton) {
    if isMyOrder {
      viewModel.cancelOrder(order)
      dismiss(animated: true, completion: nil)
    } else {
      if getAmount() > 0 {
        let amount = side == .ASK ? getAmount() : getAmount() * price
        viewModel.fillOrder(order, side, amount)
        dismiss(animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func onFillAmountEditing(_ sender: UITextField) {
    totalLabel.text = "Total price: \(getTotalPrice()) WETH"
  }
  
  @IBAction func onBackgroundTap(_ sender: UITapGestureRecognizer) {
    dismiss(animated: true, completion: nil)
  }
  
  private func getTotalPrice() -> Decimal {
    return getAmount() * price
  }
  
  private func getAmount() -> Decimal {
    guard let amountStr = fillAmountField.text,
      let amount = Decimal(string: amountStr) else {
      return 0
    }
    
    return amount
  }
}
