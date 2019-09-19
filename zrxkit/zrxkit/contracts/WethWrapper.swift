import Foundation
import RxSwift
import BigInt
import Web3

class WethWrapper: Contract {
  
  typealias TransactionReceipt = Bool
  
  static var Approval: SolidityEvent {
    let inputs: [SolidityEvent.Parameter] = [
      SolidityEvent.Parameter(name: "src", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "guy", type: .address, indexed: true),
      SolidityEvent.Parameter(name: "wad", type: .uint256, indexed: false)
    ]
    return SolidityEvent(name: "Approval", anonymous: false, inputs: inputs)
  }
  
  override var events: [SolidityEvent] {
    return [WethWrapper.Approval]
  }
  
  var totalSupply: Observable<BigUInt> {
    let outputs = [
      SolidityFunctionParameter(name: "", type: .uint256)
    ]
    let method = SolidityConstantFunction(name: "totalSupply", inputs: [], outputs: outputs, handler: self)
    return read(method: method.invoke(), onParse: { (response) -> BigUInt in
      print(response)
      return 21.gwei
    })
  }
  
  func deposit(amount: BigUInt) -> Observable<EthereumData> {
    return executeTransaction(method: nil, value: EthereumQuantity(quantity: amount))
  }
  
  func withdraw(amount: BigUInt) -> Observable<EthereumData> {
    let inputs = [
      SolidityFunctionParameter(name: "wad", type: .uint256)
    ]
    let method = SolidityNonPayableFunction(name: "withdraw", inputs: inputs, outputs: nil, handler: self)
    return executeTransaction(method: method.invoke(amount), value: nil)
  }
  
  func transfer(toAddress: String, amount: BigUInt) -> Observable<EthereumData> {
    let inputs = [
      SolidityFunctionParameter(name: "dst", type: .address),
      SolidityFunctionParameter(name: "wad", type: .uint256)
    ]
    let outputs = [
      SolidityFunctionParameter(name: "", type: .bool)
    ]
    let method = SolidityNonPayableFunction(name: "transferFrom", inputs: inputs, outputs: outputs, handler: self)
    return executeTransaction(method: method.invoke(toAddress, amount), value: nil)
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
    return executeTransaction(method: method.invoke(spenderAddress, amount), value: nil)
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
    return executeTransaction(method: method.invoke(fromAddress, toAddress, amount), value: nil)
  }
}
