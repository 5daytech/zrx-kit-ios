//
//  OrderBookResponse.swift
//  zrxkit
//
//  Created by Abai Abakirov on 9/11/19.
//  Copyright © 2019 BlocksDecoded. All rights reserved.
//

import Foundation

struct OrderBookResponse: Codable {
  let bids: OrderBook
  let asks: OrderBook
}
