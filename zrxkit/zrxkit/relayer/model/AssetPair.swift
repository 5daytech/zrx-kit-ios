import Foundation
import BigInt

public struct AssetPairsResponse: Codable {
  let total: Int
  let page: Int
  let perPage: Int
  let records: [AssetPair]
}

public struct AssetPair: Codable {
  let assetDataA: Asset
  let assetDataB: Asset
}

public struct Asset: Codable {
  let minAmount: Int
  let maxAmount: BigUInt
  let assetData: String
  let precision: Int
}
