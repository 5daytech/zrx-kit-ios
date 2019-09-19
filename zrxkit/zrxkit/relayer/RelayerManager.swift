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
    return relayerClients[relayerId].getAssets(limit: 100, networkId: networkType.id).map { $0.records }
  }
  
  func getOrderbook(relayerId: Int, base: String, qoute: String) -> Observable<OrderBookResponse> {
    return relayerClients[relayerId].getOrderBook(base: base, quote: qoute, networkId: networkType.id)
  }
  
  func postOrder(relayerId: Int, order: SignedOrder) -> Observable<UInt> {
    return relayerClients[relayerId].postOrder(order: order, networkId: networkType.id)
  }
  
  func getOrders(relayerId: Int, makerAddress: String, makerAsset: String, takerAsset: String) -> Observable<OrderBookResponse> {
    fatalError("Get orders not implemented")
  }
}
