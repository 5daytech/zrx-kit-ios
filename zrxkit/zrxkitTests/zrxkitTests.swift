//
//  zrxkitTests.swift
//  zrxkitTests
//
//  Created by Abai Abakirov on 12/5/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import XCTest
import zrxkit
import Web3

class zrxkitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
  
  func testOrderSign() {
    
    let privateKey = try! EthereumPrivateKey(hexPrivateKey: "26A5D2061D8D958ADF0B3A0BBD1A58338BC11865BE26B27B56256FE13732E090")
    
    XCTAssertEqual("0xe2507b493bef003030f0a053d55af80237a44c64", privateKey.address.hex(eip55: true).lowercased())
    
    let order = Order(
      chainId: 3,
      exchangeAddress: "0x35dd2932454449b14cee11a94d3674a936d5d7b2",
      makerAssetData: "0xf47261b00000000000000000000000002002d3812f58e35f0ea1ffbf80a75a38c32175fa",
      takerAssetData: "0xf47261b0000000000000000000000000d0a1e359811322d97991e03f863a0c30c2cf029c",
      makerAssetAmount: "10000000000000000000",
      takerAssetAmount: "10000000000000000",
      makerAddress: "0xe2507b493bef003030f0a053d55af80237a44c64",
      takerAddress: "0x0000000000000000000000000000000000000000",
      expirationTimeSeconds: "1561628788",
      senderAddress: "0x0000000000000000000000000000000000000000",
      feeRecipientAddress: "0xa258b39954cef5cb142fd567a46cddb31a670124",
      makerFee: "0",
      makerFeeAssetData: "0x",
      takerFee: "0",
      takerFeeAssetData: "0x",
      salt: "1561542388954"
    )
    
    let signedOrder = SignUtils().ecSignOrder(order, privateKey)
    
    XCTAssertEqual(signedOrder?.signature, "0x1cf1bf46f7b255f15a00100317e60da98da5b2f14e554cc2e28d8393bf7bbbb3f65879afa3337c8f16edb88419f43064d6de8862764f8ede7f2a0f9acc35f140c802")
  }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
