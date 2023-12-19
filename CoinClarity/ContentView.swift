//
//  ContentView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI

struct ContentView: View {
    @State private var currentTab: String = "Expenses"
    @State private var toggler: Bool = false
    var body: some View {
        
        TabView(selection: $currentTab) {
            HomeView(currentTab: $currentTab)
                .tag("Expenses")
                .tabItem {
                    Image(systemName: "menucard.fill")
                    Text("Expenses")
                }
            
            CategoriesView()
                .tag("Categories")
                .tabItem {
                    Image(systemName: "list.clipboard.fill")
                    Text("Categories")
                }
            
            AccountsView()
                .tag("all")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("All")
                }
            LoanAccountsView()
                .tag("Loan")
                .tabItem {
                    Image(systemName: "lanyardcard.fill")
                    Text("Loan")
                }
            CreditAccountsView()
                .tag("Credit")
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Credit")
                }
        }
    }
}

#Preview {
    ContentView()
}

