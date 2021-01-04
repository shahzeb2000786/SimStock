//
//  StockModel.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 12/25/20.
//

import Foundation

struct Stock: Codable{
    var ticker: String?
    var open: String?
    var high: String?
    var low: String?
    var price: String?
    var volume: String?
    var date: String?
    var previousClose: String?
    var change: String?
    var changePercent: String?
    var exchange: String?
    var sector: String?
    var industry: String?
    var fiftyTwoHigh: String?
    var fiftyTwoLow: String?
    var peRatio: String?
    var marketCap: String?
    var dividendYield: String?
    var fiftyDayMovingAverage: String?
    var description: String?
   
}

struct StockStats {
    var open: String?
    var high: String?
    var low: String?
    var close: String?
    var volume: String?
    var date: String?
    var previousClose: String?
    var change: String?
    var changePercent: String?
    var exchange: String?
    var sector: String?
    var industry: String?
    var fiftyTwoHigh: String?
    var fiftyTwoLow: String?
    var peRatio: String?
    var marketCap: String?
    var dividendYield: String?
    var fiftyDayMovingAverage: String?
    var description: String?
   
}
