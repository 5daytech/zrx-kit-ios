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
  
  init(address: EthereumAddress, eth: Web3.Eth, privateKey: EthereumPrivateKey, proxyAddress: EthereumAddress) {
    self.proxyAddress = proxyAddress
    super.init(address: address, eth: eth)
  }
  
  required init(address: EthereumAddress?, eth: Web3.Eth) {
    fatalError("init(address:eth:) has not been implemented")
  }
  
  public func proxyAllowance(ownerAddress: EthereumAddress) -> Observable<EthereumData> {
    return executeTransaction(method: allowance(owner: ownerAddress, spender: proxyAddress), value: nil)
  }
}
