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

public class ZrxExchangeWrapper: Contract, IZrxExchange {
  let disposeBag = DisposeBag()
  
  static var Fill: SolidityEvent {
    let inputs = [
      SolidityEvent.Parameter(name: "makerAddress", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "feeRecipientAddress", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "takerAddress", type: .address, indexed: false),
      SolidityEvent.Parameter(name: "senderAddress", type: .address, indexed: false),
      SolidityEvent.Parameter(name: "makerAssetFilledAmount", type: .uint256, indexed: false),
      SolidityEvent.Parameter(name: "takerAssetFilledAmount", type: .uint256, indexed: false),
      SolidityEvent.Parameter(name: "makerFeePaid", type: .uint256, indexed: false),
      SolidityEvent.Parameter(name: "takerFeePaid", type: .uint256, indexed: false),
      SolidityEvent.Parameter(name: "orderHash", type: .bytes(length: 32), indexed: true),
      SolidityEvent.Parameter(name: "makerAssetData", type: .bytes(length: nil), indexed: false),
      SolidityEvent.Parameter(name: "takerAssetData", type: .bytes(length: nil), indexed: false)
    ]
    return SolidityEvent(name: "Fill", anonymous: false, inputs: inputs)
  }
  
  public var contractAddress: String {
    return address?.hex(eip55: true) ?? ""
  }
  
  private func getNonce() -> Observable<EthereumQuantity> {
    return Observable.create { (observer) -> Disposable in
      self.eth.getTransactionCount(address: self.address!, block: .latest) { (response) in
        switch response.status {
        case .success(let nonce):
          observer.onNext(nonce)
        case .failure(let err):
          observer.onError(err)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  let tupleTypes: [SolidityType] = [.address, .address, .address, .address, .uint256, .uint256, .uint256, .uint256, .uint256, .uint256, .bytes(length: nil), .bytes(length: nil)]
  
  public func marketBuyOrders(orders: [SignedOrder], fillAmount: BigUInt) -> Observable<EthereumData> {
    let inputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "orders", type: .array(type: .tuple(tupleTypes), length: nil)),
      SolidityFunctionParameter(name: "makerAssetFillAmount", type: .uint256),
      SolidityFunctionParameter(name: "signatures", type: .array(type: .bytes(length: nil), length: nil))
    ]
    let outputs = [
      SolidityFunctionParameter(name: "totalFillResults", type: .tuple([.uint256, .uint256, .uint256, .uint256]))
    ]
    let method = SolidityNonPayableFunction(name: "marketBuyOrders", inputs: inputs, outputs: outputs, handler: self)
    
    let ordersInTuple = orders.map { SolidityTuple($0.getSolWrappedValues()) }
    let ordersSignatures = orders.map { Data(hex: $0.signature.clearPrefix()) }
    let invocation = method.invoke(ordersInTuple, fillAmount, ordersSignatures)
    return executeTransaction(invocation: invocation, value: nil)
  }
  
  public func marketSellOrders(orders: [SignedOrder], fillAmount: BigUInt) -> Observable<String> {
    return Observable.create { (observer) -> Disposable in
      return Disposables.create()
    }
  }
  
  public func fillOrder(order: SignedOrder, fillAmount: BigUInt) -> Observable<String> {
    return Observable.create { (observer) -> Disposable in
      return Disposables.create()
    }
  }
  
  public func cancelOrder(order: SignedOrder) -> Observable<String> {
    return Observable.create { (observer) -> Disposable in
      return Disposables.create()
    }
  }
  
  public func batchCancelOrders(order: [SignedOrder]) -> Observable<String> {
    return Observable.create { (observer) -> Disposable in
      return Disposables.create()
    }
  }
  
  public func ordersInfo(orders: [SignedOrder]) -> Observable<[OrderInfo]> {
    return Observable.create { (observer) -> Disposable in
      return Disposables.create()
    }
  }
}
