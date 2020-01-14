import Foundation
import RxSwift

public protocol IRelayerManager {
  var availableRelayers: [Relayer] { get }
  
  func getAssetPairs(relayerId: Int) -> Observable<[AssetPair]>
  
  func getOrderbook(relayerId: Int, base: String, quote: String) -> Observable<OrderBookResponse>
  
  func postOrder(relayerId: Int, order: SignedOrder) -> Observable<UInt>
  
  func getOrders(relayerId: Int, makerAddress: String, limit: Int) -> Observable<OrderBook>
}
