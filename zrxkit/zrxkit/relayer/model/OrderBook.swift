import Foundation

public struct OrderBook: Codable {
  let total: Int
  let page: Int
  let perPage: Int
  public let records: [OrderRecord]
}

public struct OrderRecord: Codable {
  public let order: SignedOrder
  public let metaData: OrderMetaData
}

public struct OrderMetaData: Codable {
  public let orderHash: String
  public let remainingFillableTakerAssetAmount: String?
}
