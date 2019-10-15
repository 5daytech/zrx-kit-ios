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
//    let words = "surprise fancy pond panic grocery hedgehog slight relief deal wash clog female".split(separator: " ").map { String($0) }
    let words = "burden crumble violin flip multiply above usual dinner eight unusual clay identify".split(separator: " ").map { String($0) }
    let seed = Mnemonic.seed(mnemonic: words)
    let hdWallet = HDWallet(seed: seed, coinType: 60, xPrivKey: 0, xPubKey: 0)
    let privateKey = try! hdWallet.privateKey(account: 0, index: 0, chain: .external).raw
    
    let pairs = [Pair<AssetItem, AssetItem>(first: ZrxKit.assetItemForAddress(address: tokenAddress), second: ZrxKit.assetItemForAddress(address: wethAddress))]
    let config = RelayerConfig(baseUrl: "http://relayer.ropsten.fridayte.ch", suffix: "", version: "v2")
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
  
  private func checkAllowance() -> Observable<Bool> {
    let base = assetPair.first
    let quote = assetPair.second
    
    return checkCoinAllowance(base.address)
  }
  
  private func checkCoinAllowance(_ address: String) -> Observable<Bool> {
    let coinWrapper = zrxKit.getErc20ProxyInstance(tokenAddress: address)
    coinWrapper.proxyAllowance(ownerAddress: EthereumAddress(hexString: address)!).subscribe(onNext: { (ethData) in
      print(ethData)
    }, onError: { (err) in
      print(err)
    }, onCompleted: {
      print("Completed")
    }).disposed(by: disposeBag)
    
    return Observable.create { observer in
      return Disposables.create()
    }
  }
}
