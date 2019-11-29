//
//  Extension+Decimal.swift
//  zrxkit
//
//  Created by Abai Abakirov on 11/22/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import BigInt
import Web3

extension Decimal {
  public func toBigUInt() -> BigUInt {
    var bytes: Bytes = Bytes()    
    for i in 0..<_length {
      let mantissa: UInt16
      switch _length - i - 1 {
      case 0:
        mantissa = _mantissa.0
      case 1:
        mantissa = _mantissa.1
      case 2:
        mantissa = _mantissa.2
      case 3:
        mantissa = _mantissa.3
      case 4:
        mantissa = _mantissa.4
      case 5:
        mantissa = _mantissa.5
      case 6:
        mantissa = _mantissa.6
      case 7:
        mantissa = _mantissa.7
      default:
        fatalError()
      }
      bytes.append(contentsOf: mantissa.makeBytes())
    }
    return BigUInt(bytes)
  }
}
