//
//  Account.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import Foundation
import SwiftData

enum AccountType: String {
    case Loan
    case Credit
    case Default = "Default"
}

@Model
class Account {
    var accountName: String
    var accountDescription: String
    var accountType: String
    var billingDate: Date
    var totalLimit: Double
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.account)
    var expenses: [Expense]?
    
    init(accountName: String, accountDescription: String) {
        self.accountName = accountName
        self.accountDescription = accountDescription
        self.accountType = AccountType.Default.rawValue
        self.billingDate = Date.init()
        self.totalLimit = 0.0
    }
    
    init(accountName: String, accountDescription: String, accountType: AccountType) {
        self.accountName = accountName
        self.accountDescription = accountDescription
        self.accountType = accountType.rawValue
        self.billingDate = Date.init()
        self.totalLimit = 0.0
    }
    
    init(accountName: String, accountDescription: String, billingDate: Date, totalLimit: Double) {
        self.accountName = accountName
        self.accountDescription = accountDescription
        self.accountType = AccountType.Credit.rawValue
        self.billingDate = billingDate
        self.totalLimit = totalLimit
    }
}

