import Foundation
import RxSwift

class RelayerManager: IRelayerManager {
  private let _availableRelayers: [Relayer]
  private let networkType: ZrxKit.NetworkType
  private let relayerClients: [RelayerApiClient]
  
  var availableRelayers: [Relayer] {
    return _availableRelayers
  }
  
  init(availableRelayers: [Relayer], networkType: ZrxKit.NetworkType) {
    self._availableRelayers = availableRelayers
    self.networkType = networkType
    self.relayerClients = availableRelayers.map { RelayerApiClient(config: $0.config) }
  }
  
  func getAssetPairs(relayerId: Int) -> Observable<[AssetPair]> {
    relayerClients[relayerId].getAssets(limit: 100).map { $0.records }
  }
  
  func getOrderbook(relayerId: Int, base: String, quote: String) -> Observable<OrderBookResponse> {
    relayerClients[relayerId].getOrderBook(base: base, quote: quote)
  }
  
  func postOrder(relayerId: Int, order: SignedOrder) -> Observable<UInt> {
    relayerClients[relayerId].postOrder(order: order)
  }
  
  func getOrders(relayerId: Int, makerAddress: String, limit: Int) -> Observable<OrderBook> {
    relayerClients[relayerId].getOrders(makerAddress: makerAddress, limit: limit)
  }
}
