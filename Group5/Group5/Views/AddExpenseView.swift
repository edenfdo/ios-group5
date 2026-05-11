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
    @State private var selectedCategory: ExpenseCategory? = nil //getting icon and name from ExpenseCategory model
    @State private var noteText: String = ""
    @ObservedObject var viewModel: ExpenseViewModel
    
    let maxExpenseAmount: Double = 99999999999999.99
    let maxNoteLength: Int = 200
    
    var expenseValue: Double {
        Double(expenseText) ?? 0
    }
    
    var saveToCategory: Bool {
        expenseValue > 0 && selectedCategory != nil
    }
    
    var body: some View {
        ZStack {
                VStack(spacing: 10) {
                    
                    dateSelection
                    
                    expenseAmount
                    
                    categorySelection
                    
                    noteSection
                    
                    saveButton
                    
                }
                .padding(.bottom, 30)
        }
    }
    
    //select the date when was this expense spend
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
    
    //expense textfield
    var expenseAmount: some View {
        VStack(alignment: .leading){
            Text("How much you spend for this?")
                .font(.headline)
            
            HStack {
                Text("$")
                    .font(.title2)
                    .bold()
                
                TextField("Enter amount", text: $expenseText)
                    .font(Font.system(size: 28))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .onChange(of: expenseText) { oldValue, newValue in
                        limitedExpenseInput(newValue)
                    }
                    .frame(height: 55)
                    
            } .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        
    }
    
    //limit money amount
    func limitedExpenseInput(_ newValue: String) {
        var money = ""
        
        for character in newValue {
            if character.isNumber {
                money.append(character)
            } else if character == "."{
                money.append(character)
            }
        }
        
        if let decimalIndex = money.firstIndex(of: "."){
            let afterDecimal = money[money.index(after: decimalIndex)...]
            if afterDecimal.count > 2 {
                let allowedPart = money.index(decimalIndex, offsetBy: 3)
                money = String(money[..<allowedPart])
            }
        }
        
        if let amount = Double(money), amount > maxExpenseAmount {
            money = String(maxExpenseAmount)
        }
        
        if money != expenseText {
                expenseText = money
            }
        
    }
    
    //category icons view
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
    
    //note writing view
    var noteSection: some View {
        VStack(alignment: .leading) {
            Text("Note (optional)")
                .font(.headline)
            HStack {
                Image(systemName: "magnifyingglass")
                    .bold()
                TextField("What was this for?", text: $noteText, axis: .vertical)
                    .font(Font.system(size: 18))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...3)
                    .onChange(of: noteText) { oldValue, newValue in
                        limitNoteInput(newValue)
                    }
                    .frame(height: 65)
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 15)
        .padding(.top, 20)
    }
    
    //limit note length
    func limitNoteInput(_ newValue: String) {
        if newValue.count > maxNoteLength {
            noteText = String(newValue.prefix(maxNoteLength))
        }
    }
    
    //saveButton view
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
                .background(saveToCategory ? Color.categories : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }.padding()
    }

}

//Button's view for each category
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
                        .fill(isSelected ? Color.selectedCate : Color.categories)
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
