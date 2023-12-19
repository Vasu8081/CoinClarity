//
//  HomeView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var currentTab: String
    @Query(sort: [
        SortDescriptor(\Expense.date, order: .reverse)
    ], animation: .snappy) private var allExpenses: [Expense]
    @Query(animation: .snappy) private var allCategories: [Category]
    @Query(animation: .snappy) private var allAccounts: [Account]
    @Environment(\.modelContext) private var context
    @State private var groupedExpenses: [GroupedExpenses] = []
    @State private var originalGroupedExpenses: [GroupedExpenses] = []
    @State private var addExpense: Bool = false
    @State private var presentShareSheet: Bool = false
    @State private var shareURL: URL = URL(string: "https://apple.com")!
    @State private var filePicker: Bool = false
    @State private var  searchText: String = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach($groupedExpenses) { $group in
                    Section(group.groupTitle) {
                        ForEach(group.expenses) { expense in
                            ExpenseCardView(expense: expense)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        context.delete(expense)
                                        withAnimation {
                                            group.expenses.removeAll(where: { $0.id == expense.id})
                                            if group.expenses.isEmpty {
                                                groupedExpenses.removeAll(where: { $0.id == group.id})
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                            
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Text("Search"))
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses", systemImage: "tray.fill")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addExpense.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading){
                    Menu {
                        Button("Import"){
                            filePicker.toggle()
                        }
                        Button("Export"){
                            var expensesStruct :[ExpenseDTO] = []
                            for expense in allExpenses{
                                let c = CategoryDTO(categoryName: expense.category.categoryName, categoryDescription: expense.category.categoryDescription)
                                let a = AccountDTO(accountName: expense.account.accountName, accountDescription: expense.account.accountDescription,
                                                   accountType: expense.account.accountType,
                                                   billingDate: expense.account.billingDate,
                                                   totalLimit: expense.account.totalLimit
                                )
                                let e = ExpenseDTO(title: expense.title, subTitle: expense.subTitle, amount: expense.amount, date: expense.date, category: c, account: a, paymentMode: expense.paymentMode)
                                
                                expensesStruct.append(e)
                            }
                            print("Saving")
                            do {
                                let jsonData = try JSONEncoder().encode(expensesStruct)
                                let jsonString = String(data: jsonData, encoding: .utf8)!
                                if let tempURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let pathURL = tempURL.appending(component: "Export\(Date().formatted(date: .complete, time: .omitted)).json")
                                    try jsonString.write(to: pathURL, atomically: true, encoding: .utf8)
                                    shareURL = pathURL
                                    presentShareSheet.toggle()
                                }
                                print("Saved")
                            } catch {
                                print("Error encoding expense: \(error.localizedDescription)")
                            }
                            
                            
                        }
                    }
                label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.init(degrees: -90))
                }
                }
            }
        }
        .onChange(of: searchText, initial: false) { oldValue, newValue in
            if !newValue.isEmpty {
                filterExpenses(newValue)
            } else {
                groupedExpenses = originalGroupedExpenses
            }
        }
        .onChange(of: allExpenses, initial: true) { oldValue, newValue in
            if newValue.count > oldValue.count || groupedExpenses.isEmpty || currentTab == "Categories" {
                createGroupedExpenses(newValue)
            }
        }
        .sheet(isPresented: $addExpense) {
            AddExpenseView()
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $presentShareSheet){
            deleteTempFile()
        } content: {
            CustomShareSheet(url: $shareURL)
        }
        
        .fileImporter(isPresented: $filePicker, allowedContentTypes: [.json]){ result in
            switch result {
            case .success(let success):
                importJson(success)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        
        .onAppear {
            if allCategories.isEmpty {
                let category = Category(categoryName: "Home", categoryDescription:"home expenses")
                context.insert(category)
            }
            if allAccounts.isEmpty {
                let account = Account(accountName: "main", accountDescription: "main account")
                context.insert(account)
            }
        }
    }
    
    func importJson(_ url: URL){
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let items = try decoder.decode([ExpenseDTO].self, from: jsonData)
            for expense in items{
                let category = findCategory(categoryName: expense.category.categoryName)
                category.categoryDescription = expense.category.categoryDescription
                let account = findAccount(accountName: expense.account.accountName)
                account.accountDescription = expense.account.accountDescription
                account.accountType = expense.account.accountType
                account.billingDate = expense.account.billingDate
                account.totalLimit = expense.account.totalLimit
                let expense = Expense(title: expense.title, subTitle: expense.subTitle, amount: expense.amount, date: expense.date, account: account, category: category, paymentMode: expense.paymentMode)
                context.insert(expense)
            }
        }
        catch{
            print(error)
        }
    }
    
    func findCategory(categoryName: String) -> Category {
        for category in allCategories {
            if category.categoryName == categoryName{
                return category
            }
        }
        return Category(categoryName: categoryName, categoryDescription: "")
    }
    
    func findAccount(accountName: String) -> Account {
        for account in allAccounts {
            if account.accountName == accountName{
                return account
            }
        }
        return Account(accountName: accountName, accountDescription: "")
    }
    
    func deleteTempFile(){
        do{
            try FileManager.default.removeItem(at: shareURL)
            print("removed")
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    
    func filterExpenses(_ text: String) {
        Task.detached(priority: .high) {
            let query = text.lowercased()
            let filteredExpenses = originalGroupedExpenses.compactMap { group -> GroupedExpenses? in
                let expenses = group.expenses.filter({ $0.title.lowercased().contains(query)})
                if expenses.isEmpty {
                    return nil
                }
                return .init(date: group.date, expenses: expenses)
            }
            
            await MainActor.run {
                groupedExpenses = filteredExpenses
            }
        }
    }
    
    
    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = Dictionary(grouping: expenses) { expense in
                let dateComponents = Calendar.current.dateComponents([.month, .day, .year], from: expense.date)
                
                return dateComponents
            }
            
            let sortedDict = groupedDict.sorted {
                let calendar = Calendar.current
                let date1 = calendar.date(from: $0.key) ?? .init()
                let date2 = calendar.date(from: $1.key) ?? .init()
                
                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }
            
            await MainActor.run {
                groupedExpenses = sortedDict.compactMap({ dict in
                    let date = Calendar.current.date(from: dict.key) ?? .init()
                    return .init(date: date, expenses: dict.value)
                })
                originalGroupedExpenses = groupedExpenses
            }
        }
    }
}

#Preview {
    ContentView()
}

struct CustomShareSheet: UIViewControllerRepresentable{
    @Binding var url: URL
    func makeUIViewController(context: Context) -> some UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
