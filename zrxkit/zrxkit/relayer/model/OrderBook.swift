import Foundation

struct OrderBook: Codable {
  let total: Int
  let page: Int
  let perPage: Int
  let records: [OrderBook]
}

struct OrderRecord {
  let order: SignedOrder
  let metaData: OrderMetaData
}

struct OrderMetaData {
  let orderHash: String
}
