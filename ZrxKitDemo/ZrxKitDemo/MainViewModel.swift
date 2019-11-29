import Foundation
import Web3
import zrxkit
import EthereumKit
import HSHDWalletKit
import RxSwift
import RxCocoa

class MainViewModel {
  let disposeBag = DisposeBag()
  
  private let infuraCredentials: (id: String, secret: String?) = (id: "0c3f9e6a005b40c58235da423f58b198",
                                                                 secret: "57b6615fb10b4749a54b29c2894a00df")
  private let etherscanKey = "GKNHXT22ED7PRVCKZATFZQD1YI7FK9AAYE"
  private let feeRecipient = "0x2e8da0868e46fc943766a98b8d92a0380b29ce2a"
  private let wethAddress = "0xc778417e063141139fce010982780140aa0cd5ab"
  private let tokenAddress = "0x30845a385581ce1dc51d651ff74689d7f4415146"
  private let decimals = 18
  
  private let networkType: EthereumKit.NetworkType = .ropsten
  private let zrxKitNetworkType: ZrxKit.NetworkType = .Ropsten
  
  private let zrxKit: ZrxKit
  let ethereumKit: EthereumKit
  let wethContract: WethWrapper
  private let ethereumAdapter: EthereumAdapter
  private let wethAdapter: Erc20Adapter
  private let tokenAdapter: Erc20Adapter
  
  var asks = BehaviorSubject<[SignedOrder]>(value: [])
  var bids = BehaviorSubject<[SignedOrder]>(value: [])
  
  var orderInfoEvent = PublishSubject<Pair<SignedOrder, EOrderSide>>()
  
  var ethBalance = PublishSubject<Decimal>()
  var tokenBalance = PublishSubject<Decimal>()
  var wethBalance = PublishSubject<Decimal>()
  var lastBlockHeight = PublishSubject<Int?>()
  var transactions: BehaviorRelay<[TransactionRecord]> = BehaviorRelay(value: [])
  
  let adapters: [IAdapter]
  
  var assetPair: Pair<AssetItem, AssetItem> {
    return zrxKit.relayerManager.availableRelayers.first!.availablePairs[0]
  }
  
  init() {
    let words = "surprise fancy pond panic grocery hedgehog slight relief deal wash clog female".split(separator: " ").map { String($0) }
//    let words = "burden crumble violin flip multiply above usual dinner eight unusual clay identify".split(separator: " ").map { String($0) }
    let seed = Mnemonic.seed(mnemonic: words)
    let hdWallet = HDWallet(seed: seed, coinType: 1, xPrivKey: 0, xPubKey: 0)
    let privateKey = try! hdWallet.privateKey(account: 0, index: 0, chain: .external).raw
    
    print(privateKey.toEIP55Address())
    
    let pairs = [Pair<AssetItem, AssetItem>(first: ZrxKit.assetItemForAddress(address: tokenAddress), second: ZrxKit.assetItemForAddress(address: wethAddress))]
    let config = RelayerConfig(baseUrl: "https://relayer.ropsten.fridayte.ch", suffix: "", version: "v2")
    let relayers = [Relayer(id: 0, name: "BDRelayer", availablePairs: pairs, feeRecipients: [feeRecipient], exchangeAddress: zrxKitNetworkType.exchangeAddress, config: config)]
    
    zrxKit = ZrxKit.getInstance(relayers: relayers, privateKey: privateKey, infuraKey: infuraCredentials.secret!)
    ethereumKit = try! EthereumKit.instance(privateKey: privateKey, syncMode: .api, networkType: networkType, infuraCredentials: infuraCredentials, etherscanApiKey: etherscanKey, walletId: "default")
    
    wethContract = zrxKit.getWethWrapperInstance()
    ethereumAdapter = EthereumAdapter(ethereumKit: ethereumKit)
    wethAdapter = Erc20Adapter(ethereumKit: ethereumKit, name: "Wrapped Eth", coin: "WETH", contractAddress: wethAddress, decimal: decimals)
    tokenAdapter = Erc20Adapter(ethereumKit: ethereumKit, name: "Tameki Coin V2", coin: "TMKv2", contractAddress: tokenAddress, decimal: decimals)
    adapters = [ethereumAdapter, wethAdapter, tokenAdapter]
    
    ethereumAdapter.lastBlockHeightObservable.subscribe(onNext: {
      self.updateLastBlockHeight()
    }).disposed(by: disposeBag)
    
    ethereumAdapter.transactionsObservable.subscribe(onNext: {
      self.updateTransactions()
    }).disposed(by: disposeBag)
    
    ethereumAdapter.balanceObservable.subscribe(onNext: {
      self.updateEthBalance()
    }).disposed(by: disposeBag)
    
    wethAdapter.balanceObservable.subscribe(onNext: {
      self.updateWethBalance()
    }).disposed(by: disposeBag)
    
    wethAdapter.transactionsObservable.subscribe(onNext: {
      
    }).disposed(by: disposeBag)
    
    tokenAdapter.transactionsObservable.subscribe(onNext: {
      
    }).disposed(by: disposeBag)
    
    tokenAdapter.balanceObservable.subscribe(onNext: {
      self.updateTokenBalance()
    }).disposed(by: disposeBag)
    
    ethereumKit.start()
  }
  
  func refreshOrders() {
    zrxKit.relayerManager.getOrderbook(relayerId: 0, base: assetPair.first.assetData, qoute: assetPair.second.assetData)
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (orderBookResponse) in
        self.asks.onNext(orderBookResponse.asks.records.map { $0.order })
        self.bids.onNext(orderBookResponse.bids.records.map { $0.order })
      }, onError: { (error) in
        print("Orders refresh error: \(error)")
      }).disposed(by: disposeBag)
    }
  
  private func updateLastBlockHeight() {
    lastBlockHeight.onNext(ethereumAdapter.lastBlockHeight)
  }
  
  private func updateTransactions() {
    ethereumAdapter.transactionsSingle(from: nil, limit: nil)
      .observeOn(MainScheduler.instance)
      .subscribe(onSuccess: { (list) in
        self.transactions.accept(list)
      }).disposed(by: disposeBag)
  }
  
  private func updateEthBalance() {
    ethBalance.onNext(ethereumAdapter.balance)
  }
  
  private func updateWethTransactions() {
    wethAdapter.transactionsSingle(from: nil, limit: nil)
      .observeOn(MainScheduler.instance)
      .subscribe(onSuccess: { (list) in
        self.transactions.accept(list)
      }).disposed(by: disposeBag)
  }
  
  private func updateWethBalance() {
    wethBalance.onNext(wethAdapter.balance)
  }
  
  private func updateTokenTransactions() {
    tokenAdapter.transactionsSingle(from: nil, limit: nil)
      .observeOn(MainScheduler.instance)
      .subscribe(onSuccess: { (list) in
        self.transactions.accept(list)
      }).disposed(by: disposeBag)
  }
  
  private func updateTokenBalance() {
    tokenBalance.onNext(tokenAdapter.balance)
  }
  
  func filterTransactions(_ position: Int) {
    let txMethod: Single<[TransactionRecord]>
    
    switch position {
    case 0:
      txMethod = ethereumAdapter.transactionsSingle(from: nil, limit: nil)
    case 1:
      txMethod = wethAdapter.transactionsSingle(from: nil, limit: nil)
    case 2:
      txMethod = tokenAdapter.transactionsSingle(from: nil, limit: nil)
    default:
      return
    }
    
    txMethod.observeOn(MainScheduler.instance).subscribe(onSuccess: { (list) in
      self.transactions.accept(list)
    }).disposed(by: disposeBag)
  }
  
  func onOrderClick(_ position: Int, _ side: EOrderSide) {
    switch side {
    case .ASK:
      orderInfoEvent.onNext(Pair<SignedOrder, EOrderSide>(first: try! asks.value()[position], second: side))
    case .BID:
      orderInfoEvent.onNext(Pair<SignedOrder, EOrderSide>(first: try! bids.value()[position], second: side))
    }
  }
  
  func fillOrder(_ order: SignedOrder, _ side: EOrderSide, _ amount: Decimal) {
    let amountBigUInt = BigUInt("\(amount)", radix: 10)!
    checkAllowance()
  }
  
  func createOrder(_ amount: Decimal, _ price: Decimal, _ side: EOrderSide) {
    print(#function)
    print(amount)
    print(price * amount)
    
    let makerAmount = BigUInt("\(amount * pow(10, decimals))", radix: 10)!
    let takerAmount = BigUInt("\(amount * price * pow(10, decimals))", radix: 10)!
    postOrder(makerAmount, takerAmount, side)
  }
  
  func postOrder(_ makeAmount: BigUInt, _ takeAmount: BigUInt, _ side: EOrderSide) {
    let expirationTime = "\(Int(Date().timeIntervalSince1970 + (60 * 60 * 24 * 3)))" // Order valid for 3 days
    let firstCoinAsset = assetPair.first.assetData
    let secondCoinAsset = assetPair.second.assetData
    
    let makerAsset: String
    let takerAsset: String
    let makerAssetAmount: String
    let takerAssetAmount: String
    
    print(#function)
    print(makeAmount)
    print(takeAmount)
    print(expirationTime)
    print("\(Date().timeIntervalSince1970)")
    
    switch side {
    case .ASK:
      makerAsset = firstCoinAsset
      takerAsset = secondCoinAsset
      makerAssetAmount = "\(makeAmount)"
      takerAssetAmount = "\(takeAmount)"
    case .BID:
      makerAsset = secondCoinAsset
      takerAsset = firstCoinAsset
      makerAssetAmount = "\(takeAmount)"
      takerAssetAmount = "\(makeAmount)"
    }
    
    let order = Order(exchangeAddress: zrxKitNetworkType.exchangeAddress,
                      makerAssetData: makerAsset,
                      takerAssetData: takerAsset,
                      makerAssetAmount: makerAssetAmount,
                      takerAssetAmount: takerAssetAmount,
                      makerAddress: ethereumKit.receiveAddress,
                      takerAddress: "0x0000000000000000000000000000000000000000",
                      expirationTimeSeconds: expirationTime,
                      senderAddress: "0x0000000000000000000000000000000000000000",
                      feeRecipientAddress: feeRecipient,
                      makerFee: "0",
                      takerFee: "0",
                      salt: "\(Int(Date().timeIntervalSince1970 * 1000))")
   
    
    guard let signedOrder = zrxKit.signOrder(order) else {
      return
    }
    print("THE END")
    
    print(#function)
    checkAllowance()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (allowed) in
        if allowed {
          print("Allowed")
          self.zrxKit.relayerManager.postOrder(relayerId: 0, order: signedOrder).observeOn(MainScheduler.instance).subscribe(onNext: { (data) in
            print("on Next \(data)")
          }, onError: { (err) in
            print(err.localizedDescription)
          }, onCompleted: {
            print("completed")
          }).disposed(by: self.disposeBag)
        } else {
          fatalError("Unlock tokens")
        }
      }, onError: { (err) in
        print(err)
      }, onCompleted: {
        print("checkAllowanceComplete")
      }).disposed(by: disposeBag)
  }
  
  private func checkAllowance() -> Observable<Bool> {
    print(#function)
    let base = assetPair.first
    let quote = assetPair.second
    return Observable.create { observer in
      observer.onNext(true)
      return Disposables.create()
    }
//    return checkCoinAllowance(base.address)
//      .flatMap { _ in self.checkCoinAllowance(quote.address) }
  }
  
  private func checkCoinAllowance(_ address: String) -> Observable<Bool> {
    print(#function)
    let coinWrapper = zrxKit.getErc20ProxyInstance(tokenAddress: address)
    return Observable.create { observer in
      coinWrapper.proxyAllowance(ownerAddress: EthereumAddress(hexString: address)!).observeOn(MainScheduler.instance).subscribe(onNext: { (amount) in
        print("\(address) allowance \(amount)")
        if amount > BigUInt.zero {
          print("amount > 0")
          observer.onNext(true)
        } else {
          print("start setUnlimitedProxyAllowance")
          coinWrapper.setUnlimitedProxyAllowance().observeOn(MainScheduler.instance)
            .subscribe(onNext: { (ethData) in
              print(ethData.hex())
              print("setUnlimitedProxyAllowance onNext")
              observer.onNext(true)
            }, onError: { (err) in
              print("setUnlimitedProxyAllowance")
              print(err)
              observer.onError(err)
            }, onCompleted: {
              print("setUnlimitedProxyAllowance completed")
              observer.onCompleted()
            }).disposed(by: self.disposeBag)
        }
      }, onError: { (err) in
        print("proxy allowance")
        observer.onError(err)
      }, onCompleted: {
        
      }).disposed(by: self.disposeBag)
      return Disposables.create()
    }
    
  }
}
