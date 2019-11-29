//
//  Extension+String.swift
//  zrxkit
//
//  Created by Abai Abakirov on 10/25/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import BigInt

extension String {
  func prefixed() -> String {
    return "0x\(self)"
  }
  
  func toBigUInt() -> BigUInt {
    return BigUInt(self, radix: 10) ?? BigUInt(0)
  }
  
  func clearPrefix() -> String {
    return self.substr(2, count - 2) ?? self
  }
}
