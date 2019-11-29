//
//  Eip712Encoder.swift
//  zrxkit
//
//  Created by Abai Abakirov on 10/25/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import CryptoSwift
import Web3

internal class Eip712Encoder {
  
  private let jsonMessageObject: Eip712Data.EIP712Message
  
  // Matches array declarations like arr[5][10], arr[][], arr[][34][], etc.
  // Doesn't match array declarations where there is a 0 in any dimension.
  // Eg- arr[0][5] is not matched.
  private let arrayTypeRegex = "^([a-zA-Z_$][a-zA-Z_$0-9]*)((\\[([1-9]\\d*)?\\])+)$"
  private lazy var arrayTypeMatcher: NSRegularExpression = {
    return try! NSRegularExpression(pattern: arrayTypeRegex, options: .caseInsensitive)
  }()
  
  // This regex tries to extract the dimensions from the
  // square brackets of an array declaration using the ``Regex Groups``.
  // Eg- It extracts ``5, 6, 7`` from ``[5][6][7]``
  private let arrayDimensionRegex = "\\[([1-9]\\d*)?\\]"
  private lazy var arrayDimensionMatcher: NSRegularExpression = {
    return try! NSRegularExpression(pattern: arrayDimensionRegex, options: .caseInsensitive)
  }()
  
  // Fields of Entry Objects need to follow a regex pattern
  // Type Regex matches to a valid name or an array declaration.
  private let typeRegex = "^[a-zA-Z_$][a-zA-Z_$0-9]*(\\[([1-9]\\d*)*\\])*$"
  
  // Identifier Regex matches to a valid name, but can't be an array declaration.
  private let identifierRegex = "^[a-zA-Z_$][a-zA-Z_$0-9]*$"
  
  init(_ jsonMessageObject: Eip712Data.EIP712Message) {
    self.jsonMessageObject = jsonMessageObject
  }
  
  private func getDependencies(_ primaryType: String) -> Set<String> {
    let types = jsonMessageObject.types
    var deps = Set<String>()
    
    if !types.keys.contains(primaryType) {
      return deps
    }
    
    var remainingTypes = [String]()
    remainingTypes.append(primaryType)
    
    while (remainingTypes.count > 0) {
      let structName = remainingTypes[remainingTypes.count - 1]
      remainingTypes.remove(at: remainingTypes.count - 1)
      deps.insert(structName)
      
      var itr = types[primaryType]!.makeIterator()
      while let entry = itr.next() {
        if !types.keys.contains(entry.type) {
          // Don't expand on non-user defined types
          continue
        } else if deps.contains(entry.type) {
          // Skip types which are already expanded
          continue
        } else {
          remainingTypes.append(entry.type)
        }
      }
    }
    
    return deps
  }
  
  private func encodeStruct(_ structName: String) -> String {
    print("encodeStruct")
    let types = jsonMessageObject.types
    
    var structRepresentation = "\(structName)("
    for entry in types[structName]! {
      structRepresentation += "\(entry.type) \(entry.name),"
    }
    structRepresentation = structRepresentation.substr(0, structRepresentation.count - 1)!
    structRepresentation += ")"
    print(structRepresentation)
    return structRepresentation
  }
  
  private func getArrayDimensionsFromDeclaration(_ declaration: String) -> [Int] {
    // Get the dimensions which were declared in Schema.
    // If any dimension is empty, then it's value is set to -1.
    
    let dimensionsMatch = arrayTypeMatcher.firstMatch(in: declaration, options: [], range: NSRange(location: 0, length: declaration.count))!
    let dimensionsString = String(declaration[Range(dimensionsMatch.range(at: 1), in: declaration)!])
    
    var dimensions = [Int]()
    arrayDimensionMatcher.enumerateMatches(in: dimensionsString, options: [], range: NSRange(location: 0, length: dimensionsString.count)) { (match, flags, pointer) in
      
      guard let match = match,
            let range = Range(match.range(at: 1), in: dimensionsString) else {
          dimensions.append(-1)
          return
      }
      let currentDimension = String(dimensionsString[range])
      dimensions.append(Int(currentDimension, radix: 10)!)
    }
    return dimensions
  }
  
  private func getDepthsAndDimensions(_ data: Any?, _ depth: Int) -> [Pair<Any, Any>] {
    if let dataAsArray = data as? [Any] {
      var list = [Pair<Any, Any>]()
      list.append(Pair<Any, Any>(first: depth, second: dataAsArray.count))
      for subdimentionalData in dataAsArray {
        list.append(contentsOf: getDepthsAndDimensions(subdimentionalData, depth + 1))
      }
      return list
    } else {
      return []
    }
  }
  
  func getArrayDimensionsFromData(_ data: Any?) -> [Int] {
    let depthsAndDimensions = getDepthsAndDimensions(data, 0)
  
    var groupedByDepth = [Pair<Int, [Pair<Any, Any>]>]()
    for pair in depthsAndDimensions {
      groupedByDepth.append(Pair(first: pair.first as! Int, second: pair.second as! [Pair<Any, Any>]))
    }
    
    var depthDimensionsMap = [Int: [Int]]()
    for pair in groupedByDepth {
      var pureDimensions = [Int]()
      for depthDimensionsPair in pair.second {
        pureDimensions.append(depthDimensionsPair.second as! Int)
      }
      depthDimensionsMap[pair.first] = pureDimensions
    }
    
    var dimensions = [Int]()
    for (key, value) in depthDimensionsMap {
      let setOfDimensionsInParticularDepth = Set(value)
      if (setOfDimensionsInParticularDepth.count != 1) {
        fatalError("Depth \(key) of array data has more than one dimensions")
      }
      dimensions.append(setOfDimensionsInParticularDepth.first!)
    }
    
    return dimensions
  }
  
  private func flattenMultidimensionalArray(_ data: Any?) -> [Any] {
    guard let dataArray = data as? [Any] else {
      return [data!]
    }
    
    var flattenedArray = [Any]()
    for arrayItem in dataArray {
      for otherArrayItem in flattenMultidimensionalArray(arrayItem) {
        flattenedArray.append(otherArrayItem)
      }
    }
    
    return flattenedArray
  }
  
  func encodeType(_ primaryType: String) -> String {
    print("encodeType")
    var deps = getDependencies(primaryType)
    deps.remove(primaryType)
    
    var depsAsList = Array(deps)
    depsAsList.sort()
    depsAsList.insert(primaryType, at: 0)
    
    var result = ""
    for structName in depsAsList {
      result += encodeStruct(structName)
    }
    print(result)
    return result
  }
  
  func hashType(_ primaryType: String) -> Array<UInt8> {
    print("hashType")
    print(primaryType)
    let encoded = encodeType(primaryType)
    print("hashType: \(encoded)")
    print("sha3 string")
    print(encoded.sha3(.keccak256))
    print(encoded.sha3(.keccak256).hexToBytes().map{ String(format: "%02x", $0) }.joined())
    return encoded.sha3(.keccak256).hexToBytes()
  }
  
  func encodeData(_ primaryType: String, _ data: [String: Any]) -> [UInt8] {
    print("encodeData")
    let types = jsonMessageObject.types
    
    var encTypes = [String]()
    var encValues = [Any]()
    
    encTypes.append("bytes32")
    encValues.append(hashType(primaryType))
    
    print(encTypes)
    print(encValues)
    
    for field in types[primaryType]! {
      let value = data[field.name]
      print("field name: \(field.name)")
      print("field type: \(field.type)")
      if field.type == "string" {
        print("string")
        encTypes.append("bytes32")
        let hashedValue = (value as! String).sha3(.keccak256).hexToBytes()
        print(hashedValue.toHexString())
        encValues.append(hashedValue)
      } else if field.type == "bytes" {
        print("bytes")
        encTypes.append("bytes32")
        print((value as! [UInt8]).toHexString())
        let hashedValue = (value as! [UInt8]).sha3(.keccak256)
        print(hashedValue.toHexString())
        encValues.append(hashedValue)
      } else if types.keys.contains(field.type) {
        print("types contains \(field.type)")
        let hashedValue = encodeData(field.type, (value as! [String: Any]))
        print(hashedValue.map{ String(format: "%02x", $0) }.joined())
        encTypes.append("bytes32")
        encValues.append(hashedValue)
      } else if field.type.range(of: arrayTypeRegex, options: .regularExpression) != nil {
        print("array regex")
        let baseTypeName = field.type.substr(0, field.type.distance(from: field.type.startIndex, to: field.type.firstIndex(of: "[")!))!
        print("Base type name")
        print(baseTypeName)
        let expectedDimensions = getArrayDimensionsFromDeclaration(field.type)
        print("expected dimensions")
        print(expectedDimensions)
        let dataDimensions = getArrayDimensionsFromData(value)
        print("Data dimensions")
        print(dataDimensions)
        if expectedDimensions.count != dataDimensions.count {
          // Ex: Expected a 3d array, but got only a 2d array
          fatalError("Array Data \(value ?? "") has dimensions \(dataDimensions), " + "but expected dimensions are \(expectedDimensions)")
        }
        
        for i in expectedDimensions.indices {
          if expectedDimensions[i] == -1 {
            // Skip empty or dynamically declared dimensions
            continue
          }
          if expectedDimensions[i] != dataDimensions[i] {
            fatalError("Array Data \(value ?? "") has dimensions \(dataDimensions), " + "but expected dimensions are \(expectedDimensions)")
          }
        }
        
        let arrayItems = flattenMultidimensionalArray(value)
        var concatenatedArrayEncodingBuffer = Array<UInt8>()
        for arrayItem in arrayItems {
          let arrayItemEncoding = encodeData(baseTypeName, arrayItem as! [String: Any])
          concatenatedArrayEncodingBuffer.append(contentsOf: arrayItemEncoding)
        }
        let hashedValue = concatenatedArrayEncodingBuffer.sha3(.keccak256)
        encTypes.append("bytes32")
        encValues.append(contentsOf: hashedValue)
      } else {
        if value != nil {
          encTypes.append(field.type)
          encValues.append(value!)
        }
      }
    }
    
    print(encTypes)
    print(encValues)
    
    return encodePacked(encTypes, encValues)
  }
  
  private func encodePacked(_ types: [String], _ values: [Any]) -> [UInt8] {
    var result = [UInt8]()
    
    for i in types.indices {
      print(types[i])
      switch types[i] {
      case "string":
        print(values[i])
        break
      case "address":
        if let string = values[i] as? String {
          let encoded = TypeEncoder.encodeAddress(string: string.clearPrefix())
          print(encoded)
          let encodedBytes = TypeEncoder.hexStringToBytes(input: encoded)
          print(encodedBytes.toHexString())
          result.append(contentsOf: encodedBytes)
        }
      case "bytes":
        print(values[i])
        break
      case "uint256":
        print(values[i])
        if let uint = values[i] as? BigUInt {
          let encoded = TypeEncoder.encodeBigUInt(bigUInt: uint)
          print(encoded)
          let encodedBytes = TypeEncoder.hexStringToBytes(input: encoded)
          print(encodedBytes.toHexString())
          result.append(contentsOf: encodedBytes)
        }
        break
      case "bytes32":
        if let bytes = values[i] as? Bytes {
          let encoded = TypeEncoder.encodeBytes(bytes: bytes)
          print(encoded)
          
          let encodedBytes = TypeEncoder.hexStringToBytes(input: encoded)
          print(encodedBytes.toHexString())
          result.append(contentsOf: encodedBytes)
        }
      default:
        fatalError()
      }
    }
    return result
  }
  
  
  func hashDomain() -> [UInt8] {
    var data = [String: Any]()
    data["verifyingContract"] = jsonMessageObject.domain.verifyingContract
    data["name"] = jsonMessageObject.domain.name
    
    if jsonMessageObject.domain.chainId > 0 {
      data["chainId"] = jsonMessageObject.domain.chainId
    }
    
    data["version"] = jsonMessageObject.domain.version
    print("hashDomain function")
    print(data)
    return encodeData("EIP712Domain", data).sha3(.keccak256)
  }
  
  func hashMessage(_ primaryType: String, _ data: [String: Any]) -> [UInt8] {
    return SHA3(variant: .keccak256).calculate(for: encodeData(primaryType, data))
  }
  
  func hashStructuredData() -> Array<UInt8> {
    var byteArray = Array<UInt8>()
    byteArray.append(contentsOf: "1901".hexToBytes())
    print("hashStructuredData")
    print(byteArray.map { String(format: "%02x", $0) }.joined())
    
    let domainHash = hashDomain()
    byteArray.append(contentsOf: domainHash)
    print("hashDomain")
    print(byteArray.toHexString())
    
    let dataHash = hashMessage(jsonMessageObject.primaryType, jsonMessageObject.message as! [String: Any])
    byteArray.append(contentsOf: dataHash)
    return byteArray.sha3(.keccak256)
  }
  
  func validateStructuredData(_ jsonMessageObject: Eip712Data.EIP712Message) throws {
    try jsonMessageObject.types.keys.forEach { (key) in
      let fields = jsonMessageObject.types[key]
      try fields?.forEach({ (entry) in
        if entry.name.range(of: identifierRegex, options: .regularExpression) == nil {
          throw ZrxError.encodeError("Invalid Identifier \(entry.name) in \(key)")
        }
        if entry.type.range(of: typeRegex, options: .regularExpression) == nil {
          throw ZrxError.encodeError("Invalid Type \(entry.type) in \(key)")
        }
      })
    }
  }
}
