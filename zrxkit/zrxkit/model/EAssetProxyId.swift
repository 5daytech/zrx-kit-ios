import Foundation

enum EAssetProxyId: String {
  case ERC20 = "0xf47261b0"
  case ERC721 = "0x02571792"
  case MultiAsset = "0x94cfcdd7"
  case ERC1155 = "0xa7cb5fb7"
  
  func encode(asset: String) -> String {
    switch self {
    case .ERC20:
      return "\(rawValue)000000000000000000000000" + asset.replacingOccurrences(of: "0x", with: "").lowercased()
    case .ERC721:
      fatalError("ERC721 tokens are not supported yet.")
    case .MultiAsset:
      fatalError("MultiAsset tokens are not supported yet.")
    case .ERC1155:
      fatalError("ERC1155 tokens are not supported yet.")
    }
  }
  
  func decode(asset: String) -> String {
    switch self {
    case .ERC20:
      return "0x\(asset.replacingOccurrences(of: "000000000000000000000000", with: "").lowercased())"
    case .ERC721:
      fatalError("ERC721 tokens are not supported yet.")
    case .MultiAsset:
      fatalError("MultiAsset tokens are not supported yet.")
    case .ERC1155:
      fatalError("ERC1155 tokens are not supported yet.")
    }
  }
}
