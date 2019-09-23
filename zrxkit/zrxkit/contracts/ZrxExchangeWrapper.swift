//
//  ZrxExchangeWrapper.swift
//  zrxkit
//
//  Created by Abai Abakirov on 9/20/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import RxSwift
import Web3

public class ZrxExchangeWrapper: Contract {
  
  let tupleTypes: [SolidityType] = [.address, .address, .address, .address, .uint256, .uint256, .uint256, .uint256, .uint256, .uint256, .bytes(length: nil), .bytes(length: nil)]
  
  func marketBuyOrders(orders: [SignedOrder]) {
    let inputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "orders", type: .array(type: .tuple(tupleTypes), length: UInt(orders.count))),
      SolidityFunctionParameter(name: "makerAssetFillAmount", type: .uint256),
      SolidityFunctionParameter(name: "signatures", type: .bytes(length: nil))
    ]
    let outputs = [
      SolidityFunctionParameter(name: "totalFillResults", type: .tuple([.uint256, .uint256, .uint256, .uint256]))
    ]
  }
}
