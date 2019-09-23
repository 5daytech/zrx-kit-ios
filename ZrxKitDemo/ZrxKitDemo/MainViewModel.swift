import Foundation
import Web3
import zrxkit
import EthereumKit
import HSHDWalletKit

class MainViewModel {
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
  
  let adapters: [IAdapter]
  
  
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
    
    adapters = [EthereumAdapter(ethereumKit: ethereumKit),
                Erc20Adapter(ethereumKit: ethereumKit, name: "Wrapped Eth", coin: "WETH", contractAddress: wethAddress, decimal: decimals),
                Erc20Adapter(ethereumKit: ethereumKit, name: "Tameki Coin V2", coin: "TMKv2", contractAddress: tokenAddress, decimal: decimals)]
    
    ethereumKit.start()
  }
}
