import Foundation
import Alamofire
import RxSwift

class RelayerApiClient {
  
  let relayerConfig: RelayerConfig
  
  init(config: RelayerConfig) {
    relayerConfig = config
  }
  
  func getOrderBook(base: String, quote: String, networkId: Int = 3) -> Observable<OrderBookResponse> {
    let urlConvertible = RelayerNetworkClient.getOrderBook(url: "\(relayerConfig.url)/orderbook", baseAsset: base, quoteAsset: quote, networkId: networkId)
    return request(try! urlConvertible.asURLRequest())
  }
  
  func feeRecipients(networkId: Int = 3) -> Observable<FeeRecipientsResponse> {
    let urlConvertible = RelayerNetworkClient.getFeeRecipients(url: "\(relayerConfig.url)/fee_recipients", networkId: networkId)
    return request(urlConvertible)
  }
  
  func getAssets(limit: Int = 100, networkId: Int = 3) -> Observable<AssetPairsResponse> {
    let urlConvertible = RelayerNetworkClient.getAssetPairs(url: "\(relayerConfig.url)/asset_pairs", perPage: limit, networkId: networkId)
    return request(urlConvertible)
  }
  
  func postOrder(order: SignedOrder, networkId: Int) -> Observable<UInt> {
    let urlConvertible = RelayerNetworkClient.postOrder(url: "\(relayerConfig.url)/order", order: order, networkId: networkId)
    return request(try! urlConvertible.asURLRequest())
  }
  
  private func request<T: Codable>(_ urlConvertible: URLRequestConvertible) -> Observable<T> {
    return Observable<T>.create { observer in
      let request = Alamofire.request(urlConvertible).responseData(completionHandler: { (response) in
        switch response.result {
        case .success(let value):
          do {            
            let decoded = try JSONDecoder().decode(T.self, from: value)
            observer.onNext(decoded)
            observer.onCompleted()
          } catch {
            observer.onError(error)
          }
        case .failure(let error):
          observer.onError(error)
        }
      })
      return Disposables.create {
        request.cancel()
      }
    }
  }
}

enum RelayerNetworkClient: URLRequestConvertible {
  case getOrderBook(url: String, baseAsset: String, quoteAsset: String, networkId: Int)
  case getFeeRecipients(url: String, networkId: Int)
  case postOrder(url: String, order: SignedOrder, networkId: Int)
  case getAssetPairs(url: String, perPage: Int, networkId: Int)
  
  func asURLRequest() throws -> URLRequest {
    var url: URL!
    var urlRequest: URLRequest!
    
    switch self {
    case .getOrderBook(let inUrl, _, _, _):
      url = try inUrl.asURL()
      urlRequest = URLRequest(url: url)
    case .postOrder(let inUrl, _, _):
      url = try inUrl.asURL()
      urlRequest = URLRequest(url: url)
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    default:
      fatalError()
    }
    
    if let parameters = parameters {
      if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
        urlComponents.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
          let queryItem = URLQueryItem(name: key, value: "\(value)")
          urlComponents.queryItems?.append(queryItem)
        }
        urlRequest.url = urlComponents.url
      }
    }
    
    
    urlRequest.httpMethod = method.rawValue
    urlRequest.httpBody = body
    return urlRequest
  }
  
  private var method: HTTPMethod {
    switch self {
    case .getOrderBook, .getAssetPairs, .getFeeRecipients:
      return .get
    case .postOrder:
      return .post
    }
  }
  
  private var parameters: Parameters? {
    switch self {
    case .getOrderBook(_, let baseAsset, let quoteAsset, let networkId):
      return ["baseAssetData": baseAsset, "quoteAssetData": quoteAsset, "networkId": networkId]
    case .getFeeRecipients(_, let networkId):
      return ["networkId": networkId]
    case .getAssetPairs(_, let perPage, let networkId):
      return ["perPage": perPage, "networkId": networkId]
    case .postOrder(_, _, let networkId):
      return ["networkId": networkId]
    }
  }
  
  private var body: Data? {
    switch self {
    case .postOrder(_, let order, _):
      return try? JSONEncoder().encode(order)
    default:
      return nil
    }
  }
}
