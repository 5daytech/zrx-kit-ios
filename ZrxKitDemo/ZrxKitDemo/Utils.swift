//
//  Utils.swift
//  ZrxKitDemo
//
//  Created by Abai Abakirov on 9/26/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
  func movePointLeft(_ shift: Int) -> String {
    var mutNumber = "\(self)"
    if mutNumber.count > shift {
      let index = mutNumber.count - shift
      let stringIndex = String.Index(utf16Offset: index, in: mutNumber)
      mutNumber.insert(".", at: stringIndex)
      mutNumber = mutNumber.trimmingCharacters(in: ["0"])
      if mutNumber.last == "." {
        mutNumber.append("0")
      }
    } else if mutNumber.count == shift {
      mutNumber.insert(".", at: String.Index(utf16Offset: 0, in: mutNumber))
      mutNumber = mutNumber.trimmingCharacters(in: ["0"])
      mutNumber.insert("0", at: String.Index(utf16Offset: 0, in: mutNumber))
    } else {
      let diff = shift - mutNumber.count
      let zeros = String(repeating: "0", count: diff)
      mutNumber.insert(contentsOf: zeros, at: String.Index(utf16Offset: 0, in: mutNumber))
      mutNumber.insert(".", at: String.Index(utf16Offset: 0, in: mutNumber))
      mutNumber = mutNumber.trimmingCharacters(in: ["0"])
      mutNumber.insert("0", at: String.Index(utf16Offset: 0, in: mutNumber))
    }
    return mutNumber
  }
}


