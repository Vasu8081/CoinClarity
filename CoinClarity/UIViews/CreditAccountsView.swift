//
//  CreditAccountsView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI
import SwiftData

struct CreditAccountsView: View {
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
    @State private var modifyRequest: Bool = false
    @State private var category: Category?
    @State private var requestedAccount: Account?
    @Query(animation: .snappy) private var allCategories: [Category]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allAccounts) { account in
                    if(account.accountType == AccountType.Credit.rawValue) {
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
                            let x: [Double] = self.adder(expenses: expenses, billingDate: account.billingDate)
                            
                            Text(account.accountName)
                                .font(.headline)

                            HStack {
                                Text("Current Due:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(String(format: "%.2f", x.first ?? 0.0))
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }

                            HStack {
                                Text("Overall Due:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(String(format: "%.2f", x.last ?? 0.0))
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }
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
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                modifyRequest.toggle()
                                requestedAccount = account
                                accountName = account.accountName
                                accountDescription = account.accountDescription
                                startDate = account.billingDate
                                amount = account.totalLimit
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .tint(.blue)
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
                        Section("Total Limit") {
                            HStack(spacing: 4) {
                                Text("₹")
                                    .fontWeight(.semibold)
                                
                                TextField("0.0", value: $amount, formatter: formatter)
                                    .keyboardType(.numberPad)
                            }
                        }
                        Section("Billing Date") {
                            DatePicker("when will be expenses be due", selection: $startDate, displayedComponents: [.date])
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
                                let account = Account(accountName: accountName, accountDescription: accountDescription, billingDate: startDate, totalLimit: amount)
                                context.insert(account)
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
            .sheet(isPresented: $modifyRequest) {
                accountName = requestedAccount?.accountName ?? ""
                accountDescription = requestedAccount?.accountDescription ?? ""
            } content: {
                NavigationStack {
                    List {
                        Section("Title") {
                            TextField("Loan for home", text: $accountName)
                        }
                        Section("Description") {
                            TextField("Gave to father", text: $accountDescription )
                        }
                        Section("Total Limit") {
                            HStack(spacing: 4) {
                                Text("₹")
                                    .fontWeight(.semibold)
                                
                                TextField("0.0", value: $amount, formatter: formatter)
                                    .keyboardType(.numberPad)
                            }
                        }
                        Section("Billing Date") {
                            DatePicker("when will be expenses be due", selection: $startDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                        }
                    }
                    .navigationTitle("Account Name")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                modifyRequest.toggle()
                            }
                            .tint(.red)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Modify") {
                                requestedAccount?.accountName = accountName
                                requestedAccount?.accountDescription = accountDescription
                                requestedAccount?.billingDate = startDate
                                requestedAccount?.totalLimit = amount
                                accountName = ""
                                accountDescription = ""
                                startDate = Date()
                                amount = 0.0
                                modifyRequest.toggle()
                            }
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
    
    func adder(expenses: [Expense], billingDate: Date) -> [Double]{
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        let billingDay = calendar.component(.day, from: billingDate)
        let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: billingDay)
        let billingEndDate = calendar.date(from: dateComponents)!
        let billingStartDate = Calendar.current.date(byAdding: .month, value: -1, to:billingEndDate)
        let range = (billingStartDate ?? Date())...(billingEndDate )
        var curr_limit = 0.0
        var total_limit = 0.0
        print(billingStartDate ?? Date(), billingEndDate)
        for expense in expenses {
            if range.contains(expense.date){
                curr_limit += expense.amount
            }
            total_limit += expense.amount
        }
        return [curr_limit, total_limit]
    }
}

#Preview {
    CreditAccountsView()
}
