import Foundation
import BigInt

public struct AssetItem {
  let minAmount: BigUInt
  let maxAmount: BigUInt
  let address: String
  let type: EAssetProxyId
  var assetData: String {
    return type.encode(asset: address)
  }
}
