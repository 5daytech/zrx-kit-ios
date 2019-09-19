import Foundation

struct Relayer {
  let id: Int
  let name: String
  let availablePairs: [Pair<AssetItem, AssetItem>]
  let feeRecipients: [String]
  let exchangeAddress: String
  let config: RelayerConfig
}

struct RelayerConfig {
  let baseUrl: String
  let suffix: String
  let version: String
}
