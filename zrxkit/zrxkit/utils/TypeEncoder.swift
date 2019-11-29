//
//  TypeEncoder.swift
//  zrxkit
//
//  Created by Abai Abakirov on 11/25/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import Web3

class TypeEncoder {
  static let MAX_BIT_LENGTH = 256
  static let MAX_BYTE_LENGTH = MAX_BIT_LENGTH / 8
  
  static func encodeBigUInt(bigUInt: BigUInt) -> String {
    let rawValue = bigUInt.makeBytes()
    var paddedRawValue = Bytes(repeating: 0, count: MAX_BYTE_LENGTH)
    paddedRawValue[(paddedRawValue.count - rawValue.count)..<paddedRawValue.count] = rawValue[0..<rawValue.count]
    return toHexStringNoPrefix(bytes: paddedRawValue)
  }
  
  static func encodeAddress(string: String) -> String {
    let rawValue = string.hexToBytes()
    var paddedRawValue = Bytes(repeating: 0, count: MAX_BYTE_LENGTH)
    paddedRawValue[(paddedRawValue.count - rawValue.count)..<paddedRawValue.count] = rawValue[0..<rawValue.count]
    return toHexStringNoPrefix(bytes: paddedRawValue)
  }
  
  static func encodeBytes(bytes: Bytes) -> String {
    let length = bytes.count
    let mod = length % MAX_BYTE_LENGTH
    
    var dest = Bytes()
    if mod != 0 {
      let padding = MAX_BYTE_LENGTH - mod
      dest = Bytes(repeating: 0, count: padding + length)
      dest[0..<length] = bytes[0..<length]
    } else {
      dest = bytes
    }
    
    return toHexStringNoPrefix(bytes: dest)
  }
  
  static func toHexStringNoPrefix(bytes: Bytes) -> String {
    return toHexString(bytes: bytes, offset: 0, length: bytes.count, withPrefix: false)
  }
  
  static func toHexString(bytes: Bytes, offset: Int, length: Int, withPrefix: Bool) -> String {
    var string = ""
    if withPrefix {
      string = "0x"
    }
    
    for i in 0..<(offset + length) {
      string = "\(string)\(String(format: "%02x", bytes[i] & 0xFF))"
    }
    
    return string
  }
  
  static func hexStringToBytes(input: String) -> Bytes {
    let cleanInput = cleanHexPrefix(input: input)
    
    let len = cleanInput.count
    
    if len == 0 {
      return Bytes()
    }
    
    var data: Bytes
    let startIdx: Int
    if len % 2 != 0 {
      data = Bytes(repeating: 0, count: len / 2 + 1)
      data[0] = Byte(hexString: String(cleanInput.first!))!
      startIdx = 1
    } else {
      data = Bytes(repeating: 0, count: len / 2)
      startIdx = 0
    }
    
    for i in stride(from: startIdx, to: len, by: 2) {
      data[(i + 1) / 2] = (Byte(hexString: cleanInput.substr(i, 1)!)! << 4) + Byte(hexString: cleanInput.substr(i + 1, 1)!)!
    }
    
    return data
  }
  
  static func cleanHexPrefix(input: String) -> String {
    if containsHexPrefix(input: input) {
      return input.clearPrefix()
    }
    return input
  }
  
  static func containsHexPrefix(input: String) -> Bool {
    return !input.isEmpty && input.count > 1 && input.dropFirst(2) == "0x"
  }
}
