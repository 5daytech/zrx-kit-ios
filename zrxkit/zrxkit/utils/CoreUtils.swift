//
//  CoreUtils.swift
//  zrxkit
//
//  Created by Abai Abakirov on 1/20/20.
//  Copyright © 2020 BlocksDecoded. All rights reserved.
//

import Foundation
import BigInt

class CoreUtils {
  static func getProtocolFee(gasInfoProvider: ContractGasProvider, fillOrderCount: Int) -> BigUInt {
    return BigUInt("\(150_000 * fillOrderCount)", radix: 10)! * gasInfoProvider.getGasPrice("")
  }
}
