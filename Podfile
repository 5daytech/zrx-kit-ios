platform :ios, '11.0'
use_frameworks!

workspace 'zrxkit'

project 'zrxkit/zrxkit'
project 'ZrxKitDemo/ZrxKitDemo'

def common_pods
    pod 'BigInt', '~> 4.0'
    pod 'RxSwift', '~> 5'
    pod 'RxCocoa', '~> 5'
    pod 'Web3', git: 'https://github.com/abaikirov/Web3.swift'
    pod 'Web3/ContractABI', git: 'https://github.com/abaikirov/Web3.swift'
    pod 'Alamofire', '~> 4.0'
end

target :zrxkit do
    project 'zrxkit/zrxkit'
    common_pods
end

target :zrxkitTests do
  project 'zrxkit/zrxkit'
  common_pods
end

target :ZrxKitDemo do
    project 'ZrxKitDemo/ZrxKitDemo'
    common_pods
    pod 'EthereumKit.swift', git: 'https://github.com/horizontalsystems/ethereum-kit-ios/'
    pod 'Erc20Kit.swift', git: 'https://github.com/horizontalsystems/ethereum-kit-ios/'
end
