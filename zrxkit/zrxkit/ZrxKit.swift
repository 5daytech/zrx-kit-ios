import Foundation
import BigInt
import Web3

public class ZrxKit {
  static public let defaultGasProvider = GasInfoProvider()
  static private let minAmount = BigUInt(0)
  static private let maxAmount = BigUInt(999999999999999999)
  
  public static func getInstance(relayers: [Relayer], privateKey: Data, infuraKey: String, networkType: NetworkType = .Ropsten, gasInfoProvider: ContractGasProvider = defaultGasProvider) -> ZrxKit {
    let relayerManager = RelayerManager(availableRelayers: relayers, networkType: networkType)
    let ethereumPrivateKey = try! EthereumPrivateKey(hexPrivateKey: privateKey.toHexString())
    return ZrxKit(relayerManager: relayerManager, privateKey: ethereumPrivateKey, infuraKey: infuraKey, networkType: networkType, gasInfoProvider: gasInfoProvider)
  }
  
  public static func assetItemForAddress(address: String, type: EAssetProxyId = EAssetProxyId.ERC20) -> AssetItem {
    return AssetItem(minAmount: minAmount, maxAmount: maxAmount, address: address, type: type)
  }
  
  public let relayerManager: IRelayerManager
  private let privateKey: EthereumPrivateKey
  private let networkType: NetworkType
  private let gasInfoProvider: ContractGasProvider
  private let web3: Web3
  
  private init(relayerManager: IRelayerManager, privateKey: EthereumPrivateKey, infuraKey: String, networkType: NetworkType, gasInfoProvider: ContractGasProvider) {
    self.relayerManager = relayerManager
    self.privateKey = privateKey
    self.networkType = networkType
    self.gasInfoProvider = gasInfoProvider
    web3 = Web3(rpcURL: networkType.getInfuraUrl(infuraKey: infuraKey))
  }
  
  public func getWethWrapperInstance(wrapperAddress: String? = nil) -> IWethWrapper {
    let address: EthereumAddress
    if wrapperAddress != nil {
      address = EthereumAddress(hexString: wrapperAddress!)!
    } else {
      address = EthereumAddress(hexString: networkType.wethAddress)!
    }
    return WethWrapper(address: address, eth: web3.eth, privateKey: privateKey, gasProvider: gasInfoProvider, networkType: networkType)
  }
  
  public func getErc20ProxyInstance(tokenAddress: String) -> IErc20Proxy {
    return getErc20ProxyInstance(tokenAddress: tokenAddress, proxyAddress: networkType.erc20ProxyAddress)
  }
  
  public func getExchangeInstance() -> IZrxExchange {
    return getExchangeInstance(address: networkType.exchangeAddress)
  }
  
  public func getExchangeInstance(address: String) -> IZrxExchange {
    return ZrxExchangeWrapper(address: EthereumAddress(hexString: address)!, eth: web3.eth, privateKey: privateKey, gasProvider: gasInfoProvider, networkType: networkType)
  }
  
  public func getErc20ProxyInstance(tokenAddress: String, proxyAddress: String) -> IErc20Proxy {
    return Erc20ProxyWrapper(address: EthereumAddress(hexString: tokenAddress)!, eth: web3.eth, privateKey: privateKey, proxyAddress: EthereumAddress(hexString: proxyAddress)!, gasProvider: gasInfoProvider, networkType: networkType)
  }
  
  public func signOrder(_ order: Order) -> SignedOrder? {
    return SignUtils().ecSignOrder(order, privateKey, networkType.id)
  }
  
  public enum NetworkType {
    case MainNet
    case Ropsten
    case Kovan
    
    public var id: Int {
      switch self {
      case .MainNet:
        return 1
      case .Ropsten:
        return 3
      case .Kovan:
        return 42
      }
    }
    
    public var exchangeAddress: String {
      switch self {
      case .MainNet:
        return "0x61935cbdd02287b511119ddb11aeb42f1593b7ef"
      case .Ropsten:
        return "0xfb2dd2a1366de37f7241c83d47da58fd503e2c64"
      case .Kovan:
        return "0x4eacd0af335451709e1e7b570b8ea68edec8bc97"
      }
    }
    
    var erc20ProxyAddress: String {
      switch self {
      case .MainNet:
        return "0x95e6f48254609a6ee006f7d493c8e5fb97094cef"
      case .Ropsten:
        return "0xb1408f4c245a23c31b98d2c626777d4c0d766caa"
      case .Kovan:
        return "0xf1ec01d6236d3cd881a0bf0130ea25fe4234003e"
      }
    }
    
    var erc721ProxyAddress: String {
      switch self {
      case .MainNet:
        return "0xefc70a1b18c432bdc64b596838b4d138f6bc6cad"
      case .Ropsten:
        return "0xe654aac058bfbf9f83fcaee7793311dd82f6ddb4"
      case .Kovan:
        return "0x2a9127c745688a165106c11cd4d647d2220af821"
      }
    }
    
    var wethAddress: String {
      switch self {
      case .MainNet:
        return "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
      case .Ropsten:
        return "0xc778417e063141139fce010982780140aa0cd5ab"
      case .Kovan:
        return "0xd0a1e359811322d97991e03f863a0c30c2cf029c"
      }
    }
    
    var subdomain: String {
      switch self {
      case .MainNet:
        return "mainnet"
      case .Ropsten:
        return "ropsten"
      case .Kovan:
        return "kovan"
      }
    }
    
    func getInfuraUrl(infuraKey: String) -> String {
      return "https://\(subdomain).fridayte.ch/\(infuraKey)"
    }
  }
  
  public struct GasInfoProvider: ContractGasProvider {
    public func getGasPrice(_ contractFunc: String) -> BigUInt {
      return 5_000_000_000
    }
    
    public func getGasPrice() -> BigUInt {
      return getGasPrice("")
    }
    
    public func getGasLimit(_ contractFunc: String) -> BigUInt {
      switch contractFunc {
      case WethWrapper.FUNC_DEPOSIT:
        return 40_000
      case WethWrapper.FUNC_WITHDRAW:
        return 60_000
      case Erc20ProxyWrapper.FUNC_APPROVE:
        return 80_000
      default:
        return 400_000
      }
    }
    
    public func getGasLimit() -> BigUInt {
      return getGasLimit("")
    }
  }
}
