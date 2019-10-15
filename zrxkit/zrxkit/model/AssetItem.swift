import Foundation
import BigInt

public struct AssetItem {
  public let minAmount: BigUInt
  public let maxAmount: BigUInt
  public let address: String
  public let type: EAssetProxyId
  public var assetData: String {
    return type.encode(asset: address)
  }
}
