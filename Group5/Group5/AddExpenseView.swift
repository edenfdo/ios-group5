//
//  AddExpenseView.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import SwiftUI

//Expense page view
struct AddExpenseView: View {
//    @ObservedObject var store: ExpenseStore
    
    @State private var selectedDate: Date = Date()
    @State private var expenseText: String = ""
    @State private var selectedCategory: ExpenseCategory? = nil
    @State private var noteText: String = ""
    @ObservedObject var viewModel: ExpenseViewModel
    
    var expenseValue: Double {
        Double(expenseText) ?? 0
    }
    
    var saveToCategory: Bool {
        expenseValue > 0 && selectedCategory != nil
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                dateSelection
                
                expenseAmount
                
                categorySelection
                
                noteSection
                
                saveButton
                
            }
        }
    }
    
    var dateSelection: some View {
        VStack(alignment: .leading){
            HStack {
                Text("Date")
                    .font(.headline)
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
            }
        }.padding()
    }
    
    var expenseAmount: some View {
        VStack(alignment: .leading){
            Text("How much you spend for this?")
                .font(.headline)
            
            HStack {
                Text("$")
                    .font(.title2)
                    .bold()
                
                TextField("Enter amount", text: $expenseText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
            } .padding(.horizontal, 20)
        }.padding()
    }
    
    var categorySelection: some View {
        LazyVGrid(
        columns: Array(repeating: GridItem(.flexible()), count: 4)
        ) {
            ForEach(ExpenseCategory.allCases) { category in
                CategoryButton(
                    category: category,
                    isSelected: selectedCategory == category
                ) {
                    selectedCategory = category
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    var noteSection: some View {
        VStack(alignment: .leading) {
            Text("Note (optional)")
                .font(.headline)
            HStack {
                Image(systemName: "magnifyingglass")
                    .bold()
                TextField("What was this for?", text: $noteText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding(.horizontal, 20)
        }.padding()
    }
    
    var saveButton: some View { //need to save to somewhere
        Button {
            if let category = selectedCategory {
                let newItem = ExpenseItem(
                    spending: expenseValue,
                    category: category,
                    note: noteText,
                    date: selectedDate
                )
                viewModel.expenses.append(newItem)
                
                expenseText = ""
                selectedCategory = nil
                noteText = ""
            }
        } label: {
            Text("Save")
                .font(.title2)
                .bold()
                .foregroundStyle(.black)
                .padding()
                .background(saveToCategory ? Color.catogories : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }.padding()
    }
    
    

}

struct CategoryButton: View{
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View{
        Button{
            action()
        } label: {
            VStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.selectedCate : Color.catogories)
                        .frame(width: 75, height: 75)
                    Image(systemName: category.icon)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Text(category.rawValue)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.black)
            }
        }
    }
}

#Preview {
    AddExpenseView(viewModel: ExpenseViewModel())
}
