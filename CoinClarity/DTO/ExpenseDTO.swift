//
//  ExpenseDTO.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import Foundation

struct ExpenseDTO: Encodable, Decodable{
    var title: String
    var subTitle: String
    var amount: Double
    var date: Date
    var category: CategoryDTO
    var account: AccountDTO
    var paymentMode: String
}
