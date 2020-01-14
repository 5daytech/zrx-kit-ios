import Foundation
import Alamofire
import RxSwift

class RelayerApiClient {
  
  let relayerConfig: RelayerConfig
  
  init(config: RelayerConfig) {
    relayerConfig = config
  }
  
  func getOrderBook(base: String, quote: String) -> Observable<OrderBookResponse> {
    let urlConvertible = RelayerNetworkClient.getOrderBook(url: "\(relayerConfig.url)/orderbook", baseAsset: base, quoteAsset: quote)
    return request(try! urlConvertible.asURLRequest())
  }
  
  func feeRecipients() -> Observable<FeeRecipientsResponse> {
    let urlConvertible = RelayerNetworkClient.getFeeRecipients(url: "\(relayerConfig.url)/fee_recipients")
    return request(urlConvertible)
  }
  
  func getAssets(limit: Int = 100) -> Observable<AssetPairsResponse> {
    let urlConvertible = RelayerNetworkClient.getAssetPairs(url: "\(relayerConfig.url)/asset_pairs", perPage: limit)
    return request(urlConvertible)
  }
  
  func postOrder(order: SignedOrder) -> Observable<UInt> {
    let urlConvertible = RelayerNetworkClient.postOrder(url: "\(relayerConfig.url)/order", order: order)
    
    return Observable.create { observer in
      let request = Alamofire.request(try! urlConvertible.asURLRequest()).responseData(completionHandler: { (response) in
        let statusCode = response.response?.statusCode
        switch response.result {
        case .success:
          if statusCode == 200 {
            observer.onNext(1)
          }
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      })
      return Disposables.create {
        request.cancel()
      }
    }
  }
  
  func getOrders(makerAddress: String?, limit: Int?) -> Observable<OrderBook> {
    let urlConvertible = RelayerNetworkClient.getOrders(url: "\(relayerConfig.url)/orders", makerAddress: makerAddress, limit: limit)
    return request(try! urlConvertible.asURLRequest())
  }
  
  private func request<T: Codable>(_ urlConvertible: URLRequestConvertible) -> Observable<T> {
    return Observable<T>.create { observer in
      let request = Alamofire.request(urlConvertible).responseData(completionHandler: { (response) in
        
        let statusCode = response.response?.statusCode
        
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
  case getOrderBook(url: String, baseAsset: String, quoteAsset: String)
  case getFeeRecipients(url: String)
  case postOrder(url: String, order: SignedOrder)
  case getAssetPairs(url: String, perPage: Int)
  case getOrders(url: String, makerAddress: String?, limit: Int?)
  
  func asURLRequest() throws -> URLRequest {
    var url: URL!
    var urlRequest: URLRequest!
    
    switch self {
    case .getOrderBook(let inUrl, _, _):
      url = try inUrl.asURL()
      urlRequest = URLRequest(url: url)
    case .postOrder(let inUrl, _):
      url = try inUrl.asURL()
      urlRequest = URLRequest(url: url)
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    case .getOrders(let inUrl, _, _):
      url = try inUrl.asURL()
      urlRequest = URLRequest(url: url)
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
    case .getOrderBook, .getAssetPairs, .getFeeRecipients, .getOrders:
      return .get
    case .postOrder:
      return .post
    }
  }
  
  private var parameters: Parameters? {
    switch self {
    case .getOrderBook(_, let baseAsset, let quoteAsset):
      return ["baseAssetData": baseAsset, "quoteAssetData": quoteAsset]
    case .getFeeRecipients(_):
      return [:]
    case .getAssetPairs(_, let perPage):
      return ["perPage": perPage]
    case .postOrder(_, _):
      return [:]
    case .getOrders(_, let makerAddress, let limit):
      return ["makerAddress": makerAddress ?? "", "perPage": limit ?? 0]
    }
  }
  
  private var body: Data? {
    switch self {
    case .postOrder(_, let order):
      return try? JSONEncoder().encode(order)
    default:
      return nil
    }
  }
}
