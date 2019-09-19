import Foundation
import BigInt
import Web3

class ZrxKit {
  static private let minAmount = BigUInt(0)
  static private let maxAmount = BigUInt(999999999999999999)
  
//  static func getInstance(relayers: [Relayer], privateKey: Data, infuraKey: String, networkType: NetworkType = .Ropsten) -> ZrxKit {
//    
//  }
  
  let relayerManager: IRelayerManager
  private let privateKey: EthereumPrivateKey
//  private let gasInfoProvider: ContractGasProvider
  private let networkType: NetworkType
  private let web3: Web3
  
  init(relayerManager: IRelayerManager, privateKey: Data, infuraKey: String, networkType: NetworkType) {
    self.relayerManager = relayerManager
    self.privateKey = try! EthereumPrivateKey(hexPrivateKey: privateKey.toHexString())
    self.networkType = networkType
    web3 = Web3(rpcURL: networkType.getInfuraUrl(infuraKey: infuraKey))
  }
  
  func getWethWrapperInstance(wrapperAddress: String? = nil) -> WethWrapper {
    let address: EthereumAddress
    if wrapperAddress != nil {
      address = EthereumAddress(hexString: wrapperAddress!)!
    } else {
      address = EthereumAddress(hexString: networkType.wethAddress)!
    }
    return WethWrapper(address: address, eth: web3.eth, privateKey: privateKey)
  }
  
  enum NetworkType {
    case MainNet
    case Ropsten
    case Kovan
    
    var id: Int {
      switch self {
      case .MainNet:
        return 1
      case .Ropsten:
        return 3
      case .Kovan:
        return 42
      }
    }
    
    var exchangeAddress: String {
      switch self {
      case .MainNet:
        return "0x080bf510fcbf18b91105470639e9561022937712"
      case .Ropsten:
        return "0xbff9493f92a3df4b0429b6d00743b3cfb4c85831"
      case .Kovan:
        return "0x30589010550762d2f0d06f650d8e8b6ade6dbf4b"
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
      return "https://\(subdomain).infura.io/\(infuraKey)"
    }
  }
}
