import Foundation
import BigInt

struct AssetItem {
  let minAmount: BigUInt
  let maxAmount: BigUInt
  let address: String
  let type: EAssetProxyId
  var assetData: String {
    return type.encode(asset: address)
  }
}
