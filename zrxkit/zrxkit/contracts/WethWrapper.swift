import Foundation
import RxSwift
import BigInt
import Web3

public class WethWrapper: Contract, IWethWrapper {
  public struct DepositEventResponse {
    let dst: EthereumAddress
    let wad: BigUInt
    
    init?(from dict: [String: Any]) {
      guard let dst = dict["dst"] as? EthereumAddress else {
        return nil
      }
      self.dst = dst
      
      guard let wad = dict["wad"] as? BigUInt else {
        return nil
      }
      self.wad = wad
    }
  }
  
  public struct WithdrawalEventResponse {
    let src: EthereumAddress
    let wad: BigUInt
    
    init?(from dict: [String: Any]) {
      guard let src = dict["src"] as? EthereumAddress else {
        return nil
      }
      self.src = src
      
      guard let wad = dict["wad"] as? BigUInt else {
        return nil
      }
      self.wad = wad
    }
  }
  
  static let FUNC_DEPOSIT = "deposit"
  static let FUNC_WITHDRAW = "withdraw"
  
  public var depositEstimatedPrice: BigUInt {
    return (depositGasLimit * gasProvider.getGasPrice(WethWrapper.FUNC_DEPOSIT)).eth
  }

  public var withdrawEstimatedPrice: BigUInt {
    return (withdrawGasLimit * gasProvider.getGasPrice(WethWrapper.FUNC_WITHDRAW)).eth
  }

  public var depositGasLimit: BigUInt {
    return gasProvider.getGasLimit(WethWrapper.FUNC_DEPOSIT)
  }

  public var withdrawGasLimit: BigUInt {
    return gasProvider.getGasLimit(WethWrapper.FUNC_WITHDRAW)
  }
  
  typealias TransactionReceipt = Bool
  
  static var Approval: SolidityEvent {
    let inputs: [SolidityEvent.Parameter] = [
      SolidityEvent.Parameter(name: "src", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "guy", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "wad", type: .uint256, indexed: false)
    ]
    return SolidityEvent(name: "Approval", anonymous: false, inputs: inputs)
  }
  
  static var Deposit: SolidityEvent {
    let inputs: [SolidityEvent.Parameter] = [
      SolidityEvent.Parameter(name: "dst", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "wad", type: .uint256, indexed: false)
    ]
    return SolidityEvent(name: "Deposit", anonymous: false, inputs: inputs)
  }
  
  static var Withdrawal: SolidityEvent {
    let inputs: [SolidityEvent.Parameter] = [
      SolidityEvent.Parameter(name: "src", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "wad", type: .uint256, indexed: false)
    ]
    return SolidityEvent(name: "Withdrawal", anonymous: false, inputs: inputs)
  }
  
  override public var events: [SolidityEvent] {
    return [WethWrapper.Approval]
  }
  
  public var totalSupply: Observable<BigUInt> {
    let outputs = [
      SolidityFunctionParameter(name: "", type: .uint256)
    ]
    let method = SolidityConstantFunction(name: "totalSupply", inputs: [], outputs: outputs, handler: self)
    return read(method: method.invoke(), onParse: { (response) -> BigUInt in
      if let value = response.first?.value as? BigUInt {
        return value
      }
      return 0.gwei
    })
  }
  
  public func deposit(
    _ amount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onDeposit: @escaping (WethWrapper.DepositEventResponse) -> Void
  ) -> Observable<EthereumData>
  {
    return executeTransaction(
      invocation: nil,
      value: EthereumQuantity(quantity: amount),
      watchEvents: [WethWrapper.Deposit],
      onReceipt: onReceipt,
      onEvent: { (emittedEvent) in
        guard let depositResponse = DepositEventResponse(from: emittedEvent.values) else {
          return
        }
        onDeposit(depositResponse)
    })
  }
  
  public func withdraw(
    _ amount: BigUInt,
    onReceipt: @escaping (EthereumTransactionReceiptObject) -> Void,
    onWithdrawal: @escaping (WethWrapper.WithdrawalEventResponse) -> Void
  ) -> Observable<EthereumData>
  {
    let inputs = [
      SolidityFunctionParameter(name: "wad", type: .uint256)
    ]
    let method = SolidityNonPayableFunction(name: "withdraw", inputs: inputs, outputs: [], handler: self)
    return executeTransaction(
      invocation: method.invoke(amount),
      value: nil,
      watchEvents: [WethWrapper.Withdrawal],
      onReceipt: onReceipt,
      onEvent: { emittedEvent in
        guard let withdrawalResponse = WithdrawalEventResponse(from: emittedEvent.values) else {
          return
        }
        onWithdrawal(withdrawalResponse)
    })
  }
  
  public func transfer(toAddress: String, amount: BigUInt) -> Observable<EthereumData> {
    let inputs = [
      SolidityFunctionParameter(name: "dst", type: .address),
      SolidityFunctionParameter(name: "wad", type: .uint256)
    ]
    let outputs = [
      SolidityFunctionParameter(name: "", type: .bool)
    ]
    let method = SolidityNonPayableFunction(name: "transferFrom", inputs: inputs, outputs: outputs, handler: self)
    return executeTransaction(invocation: method.invoke(toAddress, amount), value: nil)
  }
  
  func approve(spenderAddress: EthereumAddress, amount: BigUInt) -> Observable<EthereumData> {
    let inputs = [
      SolidityFunctionParameter(name: "guy", type: .address),
      SolidityFunctionParameter(name: "wad", type: .uint256)
    ]
    let outputs = [
      SolidityFunctionParameter(name: "", type: .bool)
    ]
    let method = SolidityNonPayableFunction(name: "approve", inputs: inputs, outputs: outputs, handler: self)
    return executeTransaction(invocation: method.invoke(spenderAddress, amount), value: nil)
  }
  
  func transferFrom(fromAddress: EthereumAddress, toAddress: EthereumAddress, amount: BigUInt) -> Observable<EthereumData> {
    let inputs = [
      SolidityFunctionParameter(name: "src", type: .address),
      SolidityFunctionParameter(name: "dst", type: .address),
      SolidityFunctionParameter(name: "wad", type: .uint256)
    ]
    let outputs = [
      SolidityFunctionParameter(name: "", type: .bool)
    ]
    let method = SolidityNonPayableFunction(name: "transferFrom", inputs: inputs, outputs: outputs, handler: self)
    return executeTransaction(invocation: method.invoke(fromAddress, toAddress, amount), value: nil)
  }
}
