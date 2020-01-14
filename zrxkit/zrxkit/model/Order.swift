import Foundation

public struct Order: IOrder, Codable {
  public var chainId: Int
  
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
  
  public var makerFeeAssetData: String
  
  public var takerFee: String
  
  public var takerFeeAssetData: String
  
  public var salt: String
  
  public init(
    chainId: Int,
    exchangeAddress: String,
    makerAssetData: String,
    takerAssetData: String,
    makerAssetAmount: String,
    takerAssetAmount: String,
    makerAddress: String,
    takerAddress: String,
    expirationTimeSeconds: String,
    senderAddress: String,
    feeRecipientAddress: String,
    makerFee: String,
    makerFeeAssetData: String,
    takerFee: String,
    takerFeeAssetData: String,
    salt: String
  ) {
    self.chainId = chainId
    self.exchangeAddress = exchangeAddress
    self.makerAssetData = makerAssetData
    self.takerAssetData = takerAssetData
    self.makerAssetAmount = makerAssetAmount
    self.takerAssetAmount = takerAssetAmount
    self.makerAddress = makerAddress
    self.takerAddress = takerAddress
    self.expirationTimeSeconds = expirationTimeSeconds
    self.senderAddress = senderAddress
    self.feeRecipientAddress = feeRecipientAddress
    self.makerFee = makerFee
    self.makerFeeAssetData = makerFeeAssetData
    self.takerFee = takerFee
    self.takerFeeAssetData = takerFeeAssetData
    self.salt = salt
  }
}
