import Foundation
import BigInt

public struct OrderInfo {
  public let orderStatus: UInt8
  public let orderHash: Data
  public let orderTakerAssetFilledAmount: BigUInt
}
