//
//  ExpenseCardView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI

struct ExpenseCardView: View {
    @Bindable var expense: Expense
    @State private var isEditing = false
    var displayTag: Bool = true
    var body: some View {
        Button(action: {isEditing.toggle()}) {
            HStack {
                VStack(alignment: .leading) {
                    Text(expense.title)
                    
                    Text(expense.subTitle)
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    if displayTag {
                        Text(expense.category.categoryName)
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.red.gradient, in: .capsule)
                    }
                }
                .lineLimit(1)
                
                Spacer(minLength: 5)
                Text(expense.currrencyString)
                    .font(.title3.bold())
                
            }
        }
        .sheet(isPresented: $isEditing){
            ModifyExpenseView(expense: expense)
        }
    }
}
