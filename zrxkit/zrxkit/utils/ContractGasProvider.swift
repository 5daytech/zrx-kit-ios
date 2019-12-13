//
//  ContractGasProvider.swift
//  zrxkit
//
//  Created by Abai Abakirov on 12/10/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import BigInt

public protocol ContractGasProvider {
  func getGasPrice(_ contractFunc: String) -> BigUInt
  func getGasPrice() -> BigUInt
  func getGasLimit(_ contractFunc: String) -> BigUInt
  func getGasLimit() -> BigUInt
}
