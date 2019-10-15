import Foundation

public struct OrderBook: Codable {
  let total: Int
  let page: Int
  let perPage: Int
  public let records: [OrderRecord]
}

public struct OrderRecord: Codable {
  public let order: SignedOrder
  let metaData: OrderMetaData
}

public struct OrderMetaData: Codable {
  let orderHash: String
}
