import Foundation

struct Order: IOrder, Codable {
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
}
