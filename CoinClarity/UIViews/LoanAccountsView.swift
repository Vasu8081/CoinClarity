//
//  LoanAccountsView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI
import SwiftData

struct LoanAccountsView: View {
    @Query(animation: .snappy) private var allAccounts: [Account]
    @Query(animation: .snappy) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context
    @State private var addAccount: Bool = false
    @State private var accountName: String = ""
    @State private var accountDescription: String = ""
    @State private var startDate: Date = Date.init()
    @State private var totalMonths: String = ""
    @State private var amount: CGFloat = 0
    @State private var deleteRequest: Bool = false
    @State private var category: Category?
    @State private var requestedAccount: Account?
    @Query(animation: .snappy) private var allCategories: [Category]
    var body: some View {
        NavigationStack {
            List {
                ForEach(allAccounts) { account in
                    if(account.accountType == AccountType.Loan.rawValue) {
                        let expenses: [Expense] = allExpenses.filter { $0.account == account }
                        
                        DisclosureGroup {
                            if !expenses.isEmpty {
                                ForEach(expenses) { expense in
                                    ExpenseCardView(expense: expense, displayTag: false)
                                }
                            } else {
                                ContentUnavailableView {
                                    Label("No Expenses", systemImage: "tray.fill")
                                }
                            }
                        } label: {
                            Text(account.accountName)
                            Text(account.accountDescription)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                deleteRequest.toggle()
                                requestedAccount = account
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
            .overlay {
                if allAccounts.isEmpty {
                    ContentUnavailableView {
                        Label("No Loan Accounts", systemImage: "tray.fill")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        accountName = ""
                        accountDescription = ""
                        addAccount.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $addAccount) {
                accountName = ""
                accountDescription = ""
                startDate = Date.init()
                totalMonths = ""
                amount = 0.0
            } content: {
                NavigationStack {
                    List {
                        Section("Title") {
                            TextField("Loan for home", text: $accountName)
                        }
                        Section("Description") {
                            TextField("Gave to father", text: $accountDescription )
                        }
                        Section("Amount to payback in a month") {
                            HStack(spacing: 4) {
                                Text("₹")
                                    .fontWeight(.semibold)
                                
                                TextField("0.0", value: $amount, formatter: formatter)
                                    .keyboardType(.numberPad)
                            }
                        }
                        Section("Total Months") {
                            TextField("duration of loan", text: $totalMonths )
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
                        Section("Date of payment") {
                            DatePicker("which date to add", selection: $startDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                        }
                        
                    }
                    .navigationTitle("Account Name")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                addAccount = false
                            }
                            .tint(.red)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                let account = Account(accountName: accountName, accountDescription: accountDescription, accountType: AccountType.Loan)
                                context.insert(account)
                                if let totalMonthsInt = Int(totalMonths) {
                                    for i in 0..<totalMonthsInt {
                                        let date = Calendar.current.date(byAdding: .month, value: i, to: startDate)
                                        let title = "\(accountName) month-\(i+1)"
                                        let expense = Expense(title: title, subTitle: "", amount: amount, date: date!, account: account, category: category!)
                                        context.insert(expense)
                                    }
                                }
                                accountName = ""
                                accountDescription = ""
                                addAccount = false
                            }
                            .disabled(accountName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(1000)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
        }
        .alert("If you delete a category, all the associated expenses will be deleted too.", isPresented: $deleteRequest) {
            Button(role: .destructive) {
                if let requestedAccount {
                    context.delete(requestedAccount)
                    self.requestedAccount = nil
                }
            } label: {
                Text("Delete")
            }
            
            Button(role: .cancel) {
                requestedAccount = nil
            } label: {
                Text("Cancel")
            }
        }
        .onChange(of: allExpenses, initial: true) { _, _ in
            
        }
    }
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

#Preview {
    LoanAccountsView()
}
