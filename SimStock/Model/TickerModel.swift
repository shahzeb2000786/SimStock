//
//  TickerModel.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 12/27/20.
//

import Foundation


struct Ticker: Codable{
    var currency: String
    var description: String
    var displaySymbol: String
    var symbol: String
    var type: String
}
