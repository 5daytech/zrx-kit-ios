import Foundation
import BigInt

struct AssetPairsResponse: Codable {
  let total: Int
  let page: Int
  let perPage: Int
  let records: [AssetPair]
}

struct AssetPair: Codable {
  let assetDataA: Asset
  let assetDataB: Asset
}

struct Asset: Codable {
  let minAmount: Int
  let maxAmount: BigUInt
  let assetData: String
  let precision: Int
}
