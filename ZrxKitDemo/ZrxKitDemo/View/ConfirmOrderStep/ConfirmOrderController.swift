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

class ConfirmOrderController: UIViewController {
  
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
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var perTokenLabel: UILabel!
  @IBOutlet weak var fillAmountField: UITextField!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
  private var side: EOrderSide!
  private var order: SignedOrder!
  private var price: Decimal!
  private var makerAmount: Decimal!
  private var takerAmount: Decimal!
  private var viewModel: MainViewModel!
  
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
    
    
    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
  }
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    let userInfo = notification.userInfo
    let frame  = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
    bottomConstraint.constant = contentInset.bottom
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    bottomConstraint.constant = 0
  }
  
  
  @IBAction func onTradeAction(_ sender: UIButton) {
    if getAmount() > 0 {
      let amount = side == .ASK ? getAmount() : getAmount() * price
      viewModel.fillOrder(order, side, amount)
      dismiss(animated: true, completion: nil)
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
