//
//  TransactionsCell.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 10/3/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import UIKit

class TransactionsCell: UITableViewCell {
  static let reuseID = "\(TransactionsCell.self)"
  
  @IBOutlet weak var label: UILabel!
  
  func onBind(tx: TransactionRecord, index: Int, lastBlockHeight: Int?) {
    contentView.backgroundColor = index % 2 == 0 ? UIColor.white : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    
    let format = "dd-MM-yyyy HH:mm:ss"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let date = Date(timeIntervalSince1970: tx.timestamp)
    
    var text = """
    - \(index)
    - Tx Hash: \(tx.transactionHash)
    - Tx Index: \(tx.transactionIndex)
    - Inter Tx Index: \(tx.interTransactionIndex)
    - Time: \(dateFormatter.string(from: date))
    - From: \(tx.from.address)
    - To: \(tx.to.address)
    - Amount: \(tx.amount)
    """
    
    guard let lastBlockHeight = lastBlockHeight,
      let txBlockHeight = tx.blockHeight else {
        label.text = text
        return
      }
    
    if lastBlockHeight > 0 {
      text = "\(text) \n- Confiramtions: \(lastBlockHeight - txBlockHeight)"
    }
    
    label.text = text
  }
}
