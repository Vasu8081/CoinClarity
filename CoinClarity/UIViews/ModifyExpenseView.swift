//
//  ModifyExpenseView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI
import SwiftData

struct ModifyExpenseView: View {
    @Bindable var expense: Expense
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(animation: .snappy) private var allCategories: [Category]
    @Query(animation: .snappy) private var allAccounts: [Account]
    
    
    var body: some View {
        NavigationStack {
            List {
                
                Section("Expense") {
                    TextField("", text: $expense.title)
                }
                
                Section("Description") {
                    TextField("", text: $expense.subTitle)
                }
                
                Section("Amount Spent") {
                    HStack(spacing: 4) {
                        Text("₹")
                            .fontWeight(.semibold)
                        
                        TextField("", value: $expense.amount, formatter: formatter)
                            .keyboardType(.numberPad)
                    }
                }
                
                HStack {
                    Text("Account")
                    Spacer()
                    Menu {
                        ForEach(allAccounts) { account in
                            Button(account.accountName) {
                                self.expense.account = account
                            }
                        }
                    } label: {
                        Text($expense.account.accountName.wrappedValue)
                    }
                }
                
                HStack {
                    Text("Category")
                    Spacer()
                    Menu {
                        ForEach(allCategories) { category in
                            Button(category.categoryName) {
                                self.expense.category = category
                            }
                        }
                    } label: {
                        Text($expense.category.categoryName.wrappedValue)
                    }
                }
                
                Section("Date") {
                    DatePicker("", selection: $expense.date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                
            }
            .navigationTitle("Modify Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Modify", action: addExpense)
                }
            }
        }
    }
    func addExpense() {
        dismiss()
    }
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
}
