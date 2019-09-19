import Foundation

protocol IOrder {
  var exchangeAddress: String { get }
  var makerAssetData: String { get }
  var takerAssetData: String { get }
  var makerAssetAmount: String { get }
  var takerAssetAmount: String { get }
  var makerAddress: String { get }
  var takerAddress: String { get }
  var expirationTimeSeconds: String { get }
  var senderAddress: String { get }
  var feeRecipientAddress: String { get }
  var makerFee: String { get }
  var takerFee: String { get }
  var salt: String { get }
}
