//
//  AccountDTO.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import Foundation

struct AccountDTO: Encodable, Decodable{
    var accountName: String
    var accountDescription: String
    var accountType: String
    var billingDate: Date
    var totalLimit: Double
}
