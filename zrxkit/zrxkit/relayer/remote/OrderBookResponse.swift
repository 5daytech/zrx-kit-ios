//
//  OrderBookResponse.swift
//  zrxkit
//
//  Created by Abai Abakirov on 9/11/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation

public struct OrderBookResponse: Codable {
  public let bids: OrderBook
  public let asks: OrderBook
}
