//
//  AddExpenseView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var account: Account?
    @State private var title: String = ""
    @State private var subTitle: String = ""
    @State private var date: Date = .init()
    @State private var amount: CGFloat = 0
    @State private var category: Category?
    @Query(animation: .snappy) private var allCategories: [Category]
    @Query(animation: .snappy) private var allAccounts: [Account]
    
    var body: some View {
        NavigationStack {
            List {
                
                Section("Expense") {
                    TextField("", text: $title)
                }
                
                Section("Description") {
                    TextField("", text: $subTitle)
                }
                
                Section("Amount Spent") {
                    HStack(spacing: 4) {
                        Text("₹")
                            .fontWeight(.semibold)
                        
                        TextField("0.0", value: $amount, formatter: formatter)
                            .keyboardType(.numberPad)
                    }
                }
                
                HStack {
                    Text("Account")
                    Spacer()
                    Menu {
                        ForEach(allAccounts) { account in
                            Button(account.accountName) {
                                self.account = account
                            }
                        }
                    } label: {
                        Text(account?.accountName ?? "None")
                    }
                }
                
                HStack {
                    Text("Category")
                    Spacer()
                    Menu {
                        ForEach(allCategories) { category in
                            Button(category.categoryName) {
                                self.category = category
                            }
                        }
                    } label: {
                        Text(category?.categoryName ?? "None")
                    }
                }
                
                Section("Date") {
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", action: addExpense)
                        .disabled(isAddButtonDisabled)
                }
            }
            .onAppear {
                account = allAccounts.first
                category = allCategories.first
            }
        }
    }
    
    var isAddButtonDisabled: Bool {
        return title.isEmpty || subTitle.isEmpty || amount == .zero
    }
    
    func addExpense() {
        let expense = Expense(title: title, subTitle: subTitle, amount: amount, date: date, account: account!, category: category!)
        context.insert(expense)
        dismiss()
    }
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

#Preview {
    AddExpenseView()
}
