//
//  AccountsView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    @Query(animation: .snappy) private var allAccounts: [Account]
    @Query(animation: .snappy) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context
    @State private var addAccount: Bool = false
    @State private var accountName: String = ""
    @State private var accountDescription: String = ""
    @State private var deleteRequest: Bool = false
    @State private var modifyRequest: Bool = false
    @State private var requestedAccount: Account?
    var body: some View {
        NavigationStack {
            List {
                ForEach(allAccounts) { account in
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
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            modifyRequest.toggle()
                            requestedAccount = account
                            accountName = account.accountName
                            accountDescription = account.accountDescription
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Accounts")
            .overlay {
                if allAccounts.isEmpty {
                    ContentUnavailableView {
                        Label("No Accounts", systemImage: "tray.fill")
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
            } content: {
                NavigationStack {
                    List {
                        Section("Title") {
                            TextField("General", text: $accountName)
                        }
                        Section("Description") {
                            TextField("General", text: $accountDescription )
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
                                let account = Account(accountName: accountName, accountDescription: accountDescription)
                                context.insert(account)
                                accountName = ""
                                accountDescription = ""
                                addAccount = false
                            }
                            .disabled(accountName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(250)])
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
                            TextField("", text: $accountName)
                        }
                        Section("Description") {
                            TextField("", text: $accountDescription )
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
                                accountName = ""
                                accountDescription = ""
                                modifyRequest.toggle()
                            }
                            .disabled(accountName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(250)])
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
    
    
}

#Preview {
    AccountsView()
}

