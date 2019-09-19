import Foundation

struct FeeRecipientsResponse: Codable {
  let total: Int
  let page: Int
  let perPage: Int
  let records: [String]
}
