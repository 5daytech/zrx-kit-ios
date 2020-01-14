import Foundation

public protocol IOrder {
  var chainId: Int { get set }
  var exchangeAddress: String { get set }
  var makerAssetData: String { get set }
  var takerAssetData: String { get set }
  var makerAssetAmount: String { get set }
  var takerAssetAmount: String { get set }
  var makerAddress: String { get set }
  var takerAddress: String { get set }
  var expirationTimeSeconds: String { get set }
  var senderAddress: String { get set }
  var feeRecipientAddress: String { get set }
  var makerFee: String { get set }
  var makerFeeAssetData: String { get set }
  var takerFee: String { get set }
  var takerFeeAssetData: String { get set }
  var salt: String { get set }
}
