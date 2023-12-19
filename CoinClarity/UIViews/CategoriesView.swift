//
//  CategoriesView.swift
//  CoinClarity
//
//  Created by Vasudhan Varma on 19/12/23.
//

import SwiftUI
import SwiftData


struct CategoriesView: View {
    @Query(animation: .snappy) private var allCategories: [Category]
    @Query(animation: .snappy) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context
    @State private var addCategory: Bool = false
    @State private var categoryName: String = ""
    @State private var categoryDescription: String = ""
    @State private var deleteRequest: Bool = false
    @State private var modifyRequest: Bool = false
    @State private var requestedCategory: Category?
    @State private var toggler: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allCategories) { category in
                    let expenses: [Expense] = allExpenses.filter { $0.category == category }
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
                        Text(category.categoryName)
                        Text(category.categoryDescription)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            deleteRequest.toggle()
                            requestedCategory = category
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            modifyRequest.toggle()
                            requestedCategory = category
                            categoryName = category.categoryName
                            categoryDescription = category.categoryDescription
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Categories")
            .overlay {
                if allCategories.isEmpty {
                    ContentUnavailableView {
                        Label("No Categories", systemImage: "tray.fill")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        categoryName = ""
                        categoryDescription = ""
                        addCategory.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $addCategory) {
                categoryName = ""
                categoryDescription = ""
            } content: {
                NavigationStack {
                    List {
                        Section("Title") {
                            TextField("General", text: $categoryName)
                        }
                        Section("Description") {
                            TextField("General", text: $categoryDescription)
                        }
                    }
                    .navigationTitle("Category Name")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                addCategory = false
                            }
                            .tint(.red)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                let category = Category(categoryName: categoryName, categoryDescription: categoryDescription)
                                context.insert(category)
                                categoryName = ""
                                categoryDescription = ""
                                addCategory = false
                            }
                            .disabled(categoryName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(250)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
            
            .sheet(isPresented: $modifyRequest) {
                categoryName = requestedCategory?.categoryName ?? "None"
                categoryDescription = requestedCategory?.categoryDescription ?? "None"
            } content: {
                NavigationStack {
                    List {
                        Section("Title") {
                            TextField("", text: $categoryName)
                        }
                        Section("Description") {
                            TextField("", text: $categoryDescription)
                        }
                    }
                    .navigationTitle("Category Name")
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
                                requestedCategory?.categoryName = categoryName
                                requestedCategory?.categoryDescription = categoryDescription
                                categoryName = ""
                                categoryDescription = ""
                                modifyRequest.toggle()
                            }
                            .disabled(categoryName.isEmpty)
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
                if let requestedCategory {
                    context.delete(requestedCategory)
                    self.requestedCategory = nil
                }
            } label: {
                Text("Delete")
            }
            
            Button(role: .cancel) {
                requestedCategory = nil
            } label: {
                Text("Cancel")
            }
        }
        .onChange(of: allExpenses, initial: false) { _, _ in
            toggler.toggle()
        }
    }
    
    
}

#Preview {
    CategoriesView()
}
