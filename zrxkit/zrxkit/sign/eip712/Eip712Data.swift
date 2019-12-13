//
//  Eip712Data.swift
//  zrxkit
//
//  Created by Abai Abakirov on 10/25/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation

internal class Eip712Data {
  struct Entry: Codable {
    let name: String
    let type: String
  }
  
  struct EIP712Domain: Codable {
    let name: String
    let version: String
    let chainId: Int
    let verifyingContract: String
  }
  
  struct EIP712Message {
    let types: [String: [Entry]]
    let primaryType: String
    let message: Any // TODO: Check
    let domain: EIP712Domain
    
    var string: String {
      return """
      EIP712Message{
        primaryType='\(primaryType)',
        message='\(message)'
      }
      """
    }
  }
}
