//
//  Expense.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//
import SwiftUI
import SwiftData

@Model
class Expense{
    var title: String
    var subTitle: String
    var amount: Double
    var date: Date
    var category: Category
    var account: Account
    var paymentMode: String
    
    init(title: String, subTitle: String, amount: Double, date: Date, account: Account, category: Category) {
        self.title = title
        self.subTitle = subTitle
        self.amount = amount
        self.date = date
        self.category = category
        self.account = account
        self.paymentMode = account.accountName
    }
  
    init(title: String, subTitle: String, amount: Double, date: Date, account: Account, category: Category, paymentMode: String) {
        self.title = title
        self.subTitle = subTitle
        self.amount = amount
        self.date = date
        self.category = category
        self.account = account
        self.paymentMode = paymentMode
    }

    @Transient
    var currrencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter.string(for: amount) ?? ""
    }
}

