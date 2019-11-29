import Foundation
import RxSwift
import Web3

public class Contract: GenericERC20Contract {
  
  let privateKey: EthereumPrivateKey
  let networkType: ZrxKit.NetworkType
  
  init(address: EthereumAddress, eth: Web3.Eth, privateKey: EthereumPrivateKey, networkType: ZrxKit.NetworkType) {
    self.privateKey = privateKey
    self.networkType = networkType
    super.init(address: address, eth: eth)
  }
  
  required init(address: EthereumAddress?, eth: Web3.Eth) {
    fatalError("init(address:eth:) has not been implemented")
  }
  
  func read<T>(method: SolidityInvocation, onParse: @escaping([String: Any]) -> T) -> Observable<T> {
    return Observable.create { observer in
      method.call(completion: { (response, error) in
        if error != nil {
          observer.onError(error!)
        } else if response != nil {
          observer.onNext(onParse(response!))
        } else {
          observer.onError(ZrxError.emptyResponse)
        }
        observer.onCompleted()
      })
      return Disposables.create()
    }
  }
  
  func executeTransaction(method: SolidityInvocation?, value: EthereumQuantity?) -> Observable<EthereumData> {
    return Observable.create { observer in
      self.eth.getTransactionCount(address: self.privateKey.address, block: .latest, response: { (nonce) in
        switch nonce.status {
        case .success(let result):
          guard let transaction = self.createTransaction(method: method, value: value, nonce: result) else {
            observer.onError(ZrxError.cannotCreateTransaction)
            return
          }
          
          do {
            let signedTransaction = try transaction.sign(with: self.privateKey, chainId: EthereumQuantity(quantity: BigUInt(self.networkType.id)))
            self.eth.sendRawTransaction(transaction: signedTransaction, response: { (hashResponse) in
              switch hashResponse.status {
              case .success(let result):
                observer.onNext(result)
              case .failure(let error):
                observer.onError(error)
              }
            })
          } catch {
            observer.onError(error)
          }
          
        case .failure(let error):
          observer.onError(error)
        }
      })
      return Disposables.create()
    }
  }
  
  private func createTransaction(method: SolidityInvocation?, value: EthereumQuantity?, nonce: EthereumQuantity) -> EthereumTransaction? {
    if method != nil {
      print("create transaction")
      print(method)
      return method!.createTransaction(nonce: nonce, from: self.privateKey.address, value: value, gas: 150000, gasPrice: EthereumQuantity(quantity: 21.gwei))
    }
    return EthereumTransaction(nonce: nonce, gasPrice: EthereumQuantity(quantity: 21.gwei), gas: 150_000, to: address, value: value)
  }
}
