//
//  ReceiptView.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 12/16/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit
import Web3

class ReceiptView: CardViewController {
  
  static func instance(receipt: EthereumTransactionReceiptObject) -> ReceiptView {
    let vc = ReceiptView()
    vc.receipt = receipt
    return vc
  }
  
  override var expandedHeight: CGFloat {
    return 300
  }
  
  override var collapsedHeight: CGFloat {
    return 0
  }
  
  override var animationDuration: TimeInterval {
    return 1.5
  }
  
  private var receipt: EthereumTransactionReceiptObject?
  
  @IBOutlet weak var statusLbl: UILabel!
  @IBOutlet weak var transactionHashLbl: UILabel!
  @IBOutlet weak var blockNumberLbl: UILabel!
  @IBOutlet weak var gasUsedLbl: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let receipt = receipt else {
      return
    }
    statusLbl.text = "Status: \(receipt.status == 1 ? "Success" : "Error")"
    transactionHashLbl.text = "Transaction hash: \(receipt.transactionHash.hex())"
    blockNumberLbl.text = "Block number: \(receipt.blockNumber.quantity)"
    gasUsedLbl.text = "Gas used: \(receipt.gasUsed.quantity)"
  }
}
