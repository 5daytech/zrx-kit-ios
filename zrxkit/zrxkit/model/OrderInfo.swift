import Foundation
import BigInt

public struct OrderInfo {
  let orderStatus: UInt8
  let orderHash: Data
  let orderTakerAssetFilledAmount: BigUInt
}
