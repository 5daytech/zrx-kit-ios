//
//  Erc20ProxyWrapper.swift
//  zrxkit
//
//  Created by Abai Abakirov on 10/4/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import RxSwift
import BigInt
import Web3

public class Erc20ProxyWrapper: Contract {
  
  private let proxyAddress: EthereumAddress
  
  init(address: EthereumAddress, eth: Web3.Eth, privateKey: EthereumPrivateKey, proxyAddress: EthereumAddress, networkType: ZrxKit.NetworkType) {
    self.proxyAddress = proxyAddress
    super.init(address: address, eth: eth, privateKey: privateKey, networkType: networkType)
  }
  
  required init(address: EthereumAddress?, eth: Web3.Eth) {
    fatalError("init(address:eth:) has not been implemented")
  }
  
  public func proxyAllowance(ownerAddress: EthereumAddress) -> Observable<BigUInt> {
    return read(method: allowance(owner: ownerAddress, spender: proxyAddress)) { (result) -> BigUInt in
      guard let value = result["_remaining"] as? BigUInt else {
        fatalError()
      }
      return value
    }
  }
  
  public func setUnlimitedProxyAllowance() -> Observable<EthereumData> {
    return executeTransaction(method: approve(spender: proxyAddress, value: Constants.MAX_ALLOWANCE), value: nil)
  }
}
