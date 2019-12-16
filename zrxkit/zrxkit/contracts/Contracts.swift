//
//  Contracts.swift
//  zrxkit
//
//  Created by Abai Abakirov on 12/10/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import RxSwift
import Web3

public protocol IErc20Proxy {
  func lockProxy() -> Observable<EthereumData>
  func setUnlimitedProxyAllowance() -> Observable<EthereumData>
  func proxyAllowance(_ ownerAddress: String) -> Observable<BigUInt>
}

public protocol IWethWrapper {
  var depositEstimatedPrice: BigUInt { get }
  var withdrawEstimatedPrice: BigUInt { get }
  var depositGasLimit: BigUInt { get }
  var withdrawGasLimit: BigUInt { get }
  
  func deposit(
    _ amount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onDeposit: @escaping (WethWrapper.DepositEventResponse) -> Void
  ) -> Observable<EthereumData>
  
  func withdraw(
    _ amount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onWithdrawal: @escaping (WethWrapper.WithdrawalEventResponse) -> Void
  ) -> Observable<EthereumData>
}

public protocol IZrxExchange {
  var contractAddress: String { get }
  
  func marketBuyOrders(
    orders: [SignedOrder],
    fillAmount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onFill: @escaping (ZrxExchangeWrapper.FillEventResponse) -> Void
  ) -> Observable<EthereumData>
  
  func marketSellOrders(
    orders: [SignedOrder],
    fillAmount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onFill: @escaping (ZrxExchangeWrapper.FillEventResponse) -> Void
  ) -> Observable<EthereumData>
  
  func fillOrder(
    order: SignedOrder,
    fillAmount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onFill: @escaping (ZrxExchangeWrapper.FillEventResponse) -> Void
  ) -> Observable<EthereumData>
  
  func cancelOrder(
    order: SignedOrder,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onCancel: @escaping (ZrxExchangeWrapper.CancelEventResponse) -> Void
  ) -> Observable<EthereumData>
  
  func batchCancelOrders(
    orders: [SignedOrder],
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onCancel: @escaping (ZrxExchangeWrapper.CancelEventResponse) -> Void
  ) -> Observable<EthereumData>
  
  func ordersInfo(orders: [SignedOrder]) -> Observable<[OrderInfo]>
}


