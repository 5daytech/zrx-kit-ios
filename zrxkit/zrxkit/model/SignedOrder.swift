import Foundation

struct SignedOrder: IOrder, Codable {
  var exchangeAddress: String
  
  var makerAssetData: String
  
  var takerAssetData: String
  
  var makerAssetAmount: String
  
  var takerAssetAmount: String
  
  var makerAddress: String
  
  var takerAddress: String
  
  var expirationTimeSeconds: String
  
  var senderAddress: String
  
  var feeRecipientAddress: String
  
  var makerFee: String
  
  var takerFee: String
  
  var salt: String
  
  let signature: String
  
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
}
