import Foundation

public struct Order: IOrder, Codable {
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
}
