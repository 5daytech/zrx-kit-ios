import Foundation

public struct Relayer {
  public init(id: Int, name: String, availablePairs: [Pair<AssetItem, AssetItem>], feeRecipients: [String], exchangeAddress: String, config: RelayerConfig) {
    self.id = id
    self.name = name
    self.availablePairs = availablePairs
    self.feeRecipients = feeRecipients
    self.exchangeAddress = exchangeAddress
    self.config = config
  }
  let id: Int
  let name: String
  let availablePairs: [Pair<AssetItem, AssetItem>]
  let feeRecipients: [String]
  let exchangeAddress: String
  let config: RelayerConfig
}

public struct RelayerConfig {
  public init(baseUrl: String, suffix: String, version: String) {
    self.baseUrl = baseUrl
    self.suffix = suffix
    self.version = version
  }
  let baseUrl: String
  let suffix: String
  let version: String
}
