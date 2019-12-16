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
  public struct FillEventResponse {
    let makerAddress: EthereumAddress
    let feeRecipientAddress: EthereumAddress
    let takerAddress: EthereumAddress
    let senderAddress: EthereumAddress
    let makerAssetFilledAmount: BigUInt
    let takerAssetFilledAmount: BigUInt
    let makerFeePaid: BigUInt
    let takerFeePaid: BigUInt
    let orderHash: Data
    let makerAssetData: Data
    let takerAssetData: Data
    
    init?(from dict: [String: Any]) {
      guard let makerAddress = dict["makerAddress"] as? EthereumAddress else {
        return nil
      }
      self.makerAddress = makerAddress
      
      guard let takerAddress = dict["takerAddress"] as? EthereumAddress else {
        return nil
      }
      self.takerAddress = takerAddress
      
      guard let feeRecipientAddress = dict["feeRecipientAddress"] as? EthereumAddress else {
        return nil
      }
      self.feeRecipientAddress = feeRecipientAddress
      
      guard let senderAddress = dict["senderAddress"] as? EthereumAddress else {
        return nil
      }
      self.senderAddress = senderAddress
      
      guard let makerAssetFilledAmount = dict["makerAssetFilledAmount"] as? BigUInt else {
        return nil
      }
      self.makerAssetFilledAmount = makerAssetFilledAmount
      
      guard let takerAssetFilledAmount = dict["takerAssetFilledAmount"] as? BigUInt else {
        return nil
      }
      self.takerAssetFilledAmount = takerAssetFilledAmount
      
      guard let makerFeePaid = dict["makerFeePaid"] as? BigUInt else {
        return nil
      }
      self.makerFeePaid = makerFeePaid
      
      guard let takerFeePaid = dict["takerFeePaid"] as? BigUInt else {
        return nil
      }
      self.takerFeePaid = takerFeePaid
      
      guard let orderHash = dict["orderHash"] as? Data else {
        return nil
      }
      self.orderHash = orderHash
      
      guard let makerAssetData = dict["makerAssetData"] as? Data else {
        return nil
      }
      self.makerAssetData = makerAssetData
      
      guard let takerAssetData = dict["takerAssetData"] as? Data else {
        return nil
      }
      self.takerAssetData = takerAssetData
    }
  }
  
  public struct CancelEventResponse {
    let makerAddress: EthereumAddress
    let feeRecipientAddress: EthereumAddress
    let senderAddress: EthereumAddress
    let orderHash: Data
    let makerAssetData: Data
    let takerAssetData: Data
    
    init?(from dict: [String: Any]) {
      guard let makerAddress = dict["makerAddress"] as? EthereumAddress else {
        return nil
      }
      self.makerAddress = makerAddress
      
      guard let feeRecipientAddress = dict["feeRecipientAddress"] as? EthereumAddress else {
        return nil
      }
      self.feeRecipientAddress = feeRecipientAddress
      
      guard let senderAddress = dict["senderAddress"] as? EthereumAddress else {
        return nil
      }
      self.senderAddress = senderAddress
      
      guard let orderHash = dict["orderHash"] as? Data else {
        return nil
      }
      self.orderHash = orderHash
      
      guard let makerAssetData = dict["makerAssetData"] as? Data else {
        return nil
      }
      self.makerAssetData = makerAssetData
      
      guard let takerAssetData = dict["takerAssetData"] as? Data else {
        return nil
      }
      self.takerAssetData = takerAssetData
    }
  }
  
  
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
  
  static var Cancel: SolidityEvent {
    let inputs = [
      SolidityEvent.Parameter(name: "makerAddress", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "feeRecipientAddress", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "senderAddress", type: .address, indexed: false),
      SolidityEvent.Parameter(name: "orderHash", type: .bytes(length: 32), indexed: true),
      SolidityEvent.Parameter(name: "makerAssetData", type: .bytes(length: nil), indexed: false),
      SolidityEvent.Parameter(name: "takerAssetData", type: .bytes(length: nil), indexed: false)
    ]
    return SolidityEvent(name: "Cancel", anonymous: false, inputs: inputs)
  }
  
  public var contractAddress: String {
    return address?.hex(eip55: true) ?? ""
  }
  
  let orderTypes: [SolidityType] = [.address, .address, .address, .address, .uint256, .uint256, .uint256, .uint256, .uint256, .uint256, .bytes(length: nil), .bytes(length: nil)]
  
  public func marketBuyOrders(
    orders: [SignedOrder],
    fillAmount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onFill: @escaping (FillEventResponse) -> Void
  ) -> Observable<EthereumData>
  {
    let inputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "orders", type: .array(type: .tuple(orderTypes), length: nil)),
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
    return executeTransactionForFillEvent(invocation: invocation, onReceipt: onReceipt, onFill: onFill)
  }
  
  public func marketSellOrders(
    orders: [SignedOrder],
    fillAmount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onFill: @escaping (ZrxExchangeWrapper.FillEventResponse) -> Void
  ) -> Observable<EthereumData>
  {
    let inputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "orders", type: .array(type: .tuple(orderTypes), length: nil)),
      SolidityFunctionParameter(name: "takerAssetFillAmount", type: .uint256),
      SolidityFunctionParameter(name: "signatures", type: .array(type: .bytes(length: nil), length: nil))
    ]
    let outputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "totalFillResults", type: .tuple([.uint256, .uint256, .uint256, .uint256]))
    ]
    
    let method = SolidityNonPayableFunction(name: "marketSellOrders", inputs: inputs, outputs: outputs, handler: self)
    
    let ordersInTuple = orders.map { SolidityTuple($0.getSolWrappedValues()) }
    let ordersSignatures = orders.map { Data(hex: $0.signature.clearPrefix()) }
    let invocation = method.invoke(ordersInTuple, fillAmount, ordersSignatures)
    return executeTransactionForFillEvent(invocation: invocation, onReceipt: onReceipt, onFill: onFill)
  }
  
  public func fillOrder(
    order: SignedOrder,
    fillAmount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onFill: @escaping (ZrxExchangeWrapper.FillEventResponse) -> Void
  ) -> Observable<EthereumData>
  {
    let inputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "order", type: .tuple(orderTypes)),
      SolidityFunctionParameter(name: "takerAssetFillAmount", type: .uint256),
      SolidityFunctionParameter(name: "signature", type: .bytes(length: nil))
    ]
    let outputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "fillResults", type: .tuple([.uint256, .uint256, .uint256, .uint256]))
    ]
    let method = SolidityNonPayableFunction(name: "fillOrder", inputs: inputs, outputs: outputs, handler: self)
    let orderInTuple = SolidityTuple(order.getSolWrappedValues())
    let orderSignature = Data(hex: order.signature.clearPrefix())
    let invocation = method.invoke(orderInTuple, fillAmount, orderSignature)
    return executeTransactionForFillEvent(invocation: invocation, onReceipt: onReceipt, onFill: onFill)
  }
  
  public func cancelOrder(
    order: SignedOrder,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onCancel: @escaping (ZrxExchangeWrapper.CancelEventResponse) -> Void
  ) -> Observable<EthereumData>
  {
    let inputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "order", type: .tuple(orderTypes))
    ]
    let method = SolidityNonPayableFunction(name: "cancelOrder", inputs: inputs, outputs: [], handler: self)
    let orderInTuple = SolidityTuple(order.getSolWrappedValues())
    let invocation = method.invoke(orderInTuple)
    return executeTransactionForCancelEvent(invocation: invocation, onReceipt: onReceipt, onCancel: onCancel)
  }
  
  public func batchCancelOrders(
    orders: [SignedOrder],
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onCancel: @escaping (ZrxExchangeWrapper.CancelEventResponse) -> Void
  ) -> Observable<EthereumData>
  {
    let inputs: [SolidityFunctionParameter] = [
      SolidityFunctionParameter(name: "orders", type: .array(type: .tuple(orderTypes), length: nil))
    ]
    let method = SolidityNonPayableFunction(name: "batchCancelOrders", inputs: inputs, handler: self)
    let ordersInTuple = orders.map { SolidityTuple($0.getSolWrappedValues()) }
    let invocation = method.invoke(ordersInTuple)
    return executeTransactionForCancelEvent(invocation: invocation, onReceipt: onReceipt, onCancel: onCancel)
  }
  
  public func ordersInfo(orders: [SignedOrder]) -> Observable<[OrderInfo]> {
    return Observable.create { (observer) -> Disposable in
      return Disposables.create()
    }
  }
  
  private func executeTransactionForFillEvent(
    invocation: SolidityInvocation,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onFill: @escaping (ZrxExchangeWrapper.FillEventResponse) -> Void) -> Observable<EthereumData> {
    return executeTransaction(invocation: invocation, value: nil, watchEvents: [ZrxExchangeWrapper.Fill], onReceipt: onReceipt, onEvent: { emitedEvent in
      switch emitedEvent.name {
      case ZrxExchangeWrapper.Fill.name:
        guard let filled = FillEventResponse(from: emitedEvent.values) else {
          return
        }
        onFill(filled)
      default:
        break
      }
    })
  }
  
  private func executeTransactionForCancelEvent(
    invocation: SolidityInvocation,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onCancel: @escaping (ZrxExchangeWrapper.CancelEventResponse) -> Void) -> Observable<EthereumData> {
    return executeTransaction(invocation: invocation, value: nil, watchEvents: [ZrxExchangeWrapper.Cancel], onReceipt: onReceipt) { (emitedEvent) in
      switch emitedEvent.name {
      case ZrxExchangeWrapper.Cancel.name:
        guard let cancel = CancelEventResponse(from: emitedEvent.values) else {
          return
        }
        onCancel(cancel)
      default:
        break
      }
    }
  }
}
