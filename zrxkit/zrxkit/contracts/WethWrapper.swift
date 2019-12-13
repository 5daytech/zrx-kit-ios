import Foundation
import RxSwift
import BigInt
import Web3

public class WethWrapper: Contract, IWethWrapper {
  
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
  
  public func deposit(_ amount: BigUInt) -> Observable<EthereumData> {
    return executeTransaction(invocation: nil, value: EthereumQuantity(quantity: amount))
  }
  
  public func withdraw(_ amount: BigUInt) -> Observable<EthereumData> {
    let inputs = [
      SolidityFunctionParameter(name: "wad", type: .uint256)
    ]
    let method = SolidityNonPayableFunction(name: "withdraw", inputs: inputs, outputs: [], handler: self)
    return executeTransaction(invocation: method.invoke(amount), value: nil)
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
