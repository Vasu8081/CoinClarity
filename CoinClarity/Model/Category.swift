//
//  Category.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import Foundation
import SwiftUI
import SwiftData


@Model
class Category {
    var categoryName: String
    var categoryDescription: String
    @Relationship(deleteRule: .cascade, inverse: \Expense.category)
    var expenses: [Expense]?
    
    init(categoryName: String, categoryDescription: String) {
        self.categoryName = categoryName
        self.categoryDescription = categoryDescription
    }
    
}
