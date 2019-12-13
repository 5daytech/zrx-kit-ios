import Foundation
import Web3

public struct SignedOrder: IOrder, Codable {
  public var exchangeAddress: String
  
  public var makerAssetData: String
  
  public var takerAssetData: String
  
  public var makerAssetAmount: String
  
  public var takerAssetAmount: String
  
  public var makerAddress: String
  
  public var takerAddress: String
  
  public var expirationTimeSeconds: String
  
  public var senderAddress: String
  
  public var feeRecipientAddress: String
  
  public var makerFee: String
  
  public var takerFee: String
  
  public var salt: String
  
  public let signature: String
  
  static func fromOrder(order: IOrder, signature: String) -> SignedOrder {
    return SignedOrder(exchangeAddress: order.exchangeAddress,
                       makerAssetData: order.makerAssetData,
                       takerAssetData: order.takerAssetData,
                       makerAssetAmount: order.makerAssetAmount,
                       takerAssetAmount: order.takerAssetAmount,
                       makerAddress: order.makerAddress,
                       takerAddress: order.takerAddress,
                       expirationTimeSeconds: order.expirationTimeSeconds,
                       senderAddress: order.senderAddress,
                       feeRecipientAddress: order.feeRecipientAddress,
                       makerFee: order.makerFee,
                       takerFee: order.takerFee,
                       salt: order.salt,
                       signature: signature)
  }
  
  
  
  public func getSolWrappedValues() -> [SolidityWrappedValue] {
    return [
      SolidityWrappedValue.address(EthereumAddress(hexString: makerAddress)!),
      SolidityWrappedValue.address(EthereumAddress(hexString: takerAddress)!),
      SolidityWrappedValue.address(EthereumAddress(hexString: feeRecipientAddress)!),
      SolidityWrappedValue.address(EthereumAddress(hexString: senderAddress)!),
      SolidityWrappedValue.uint(BigUInt(makerAssetAmount, radix: 10)!),
      SolidityWrappedValue.uint(BigUInt(takerAssetAmount, radix: 10)!),
      SolidityWrappedValue.uint(BigUInt(makerFee, radix: 10)!),
      SolidityWrappedValue.uint(BigUInt(takerFee, radix: 10)!),
      SolidityWrappedValue.uint(BigUInt(expirationTimeSeconds, radix: 10)!),
      SolidityWrappedValue.uint(BigUInt(salt, radix: 10)!),
      SolidityWrappedValue.bytes(Data(hex: makerAssetData.clearPrefix())),
      SolidityWrappedValue.bytes(Data(hex: takerAssetData.clearPrefix()))
    ]
  }
}
