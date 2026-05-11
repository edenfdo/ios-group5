//
//  AddExpenseViewModel.swift
//  Group5
//
//  Created by Eden Fernando on 3/5/2026.
//

import Foundation
import Combine

class ExpenseViewModel: ObservableObject {
    // expenses
    @Published var expenses: [ExpenseItem] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    // total monthly budget amount
    @Published var monthlyBudget: Double = 0
    {
        didSet
        {
            saveMonthlyBudget()
        }
    }
    
    //  budget limit information for all categories
    @Published var categoryLimits: [CategoryLimit] = ExpenseCategory.allCases.map
    {
        CategoryLimit(category: $0)
    }
    {
        didSet
        {
            saveCategoryLimits()
        }
    }
    
    // total amount spent
    @Published var monthlySpent: Double = 0
    
    // calculate total for the current month
    var currentMonthTotal: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // calculate the total category budget limit
    var totalCategoryLimit: Double
    {
        categoryLimits.reduce(0) { $0 + $1.limit }
    }
    
    // calculate the total for the "Today" tab
    var todayTotal: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // calculate remaining budget
    var remainingMonthlyBudget: Double {
        return monthlyBudget - currentMonthTotal
    }
    
    // UserDefaults storage
    private let monthlyBudgetKey = "SavedMonthlyBudget"
    private let categoryLimitsKey = "SavedCategoryLimits"
    private let saveKey = "SavedExpenses"
    

    // initialiser
    init()
    {
        loadBudgetData()
        loadFromUserDefaults()
    }
    
    // set the total monthly budget amount
    func setMonthlyBudget(_ amount: Double)
    {
        monthlyBudget = amount
    }
    
    // update the budget limit for a specific category
    // returns true if the update succeeds
    // returns false if the total category limit exceeds the monthly budget
    func setCategoryLimit(category: ExpenseCategory, limit: Double) -> Bool {
        guard let index = categoryLimits.firstIndex(where: { $0.category == category })
        else
        {
            return false
        }
        
        let currentLimit = categoryLimits[index].limit
        let newTotalLimit = totalCategoryLimit - currentLimit + limit
        
        if newTotalLimit > monthlyBudget
        {
            return false
        }
        
        var updatedLimits = categoryLimits
        updatedLimits[index].limit = limit
        
        // reassign the whole array so didSet runs and UserDefaults saves
        categoryLimits = updatedLimits
        
        return true
    }
    
    // calculates the total amount of money spent on a specific day
    func totalFor(day: Date) -> Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // delete an expense
    func deleteExpense(_ item: ExpenseItem) {
        expenses.removeAll { $0.id == item.id }
    }
    
    // save monthly budget to UserDefaults
    private func saveMonthlyBudget()
    {
        UserDefaults.standard.set(monthlyBudget, forKey: monthlyBudgetKey)
    }
    
    // save data using JSON encoding
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // load monthly budget and category limits from UserDefaults
    private func loadBudgetData()
    {
        monthlyBudget = UserDefaults.standard.double(forKey: monthlyBudgetKey)
        
        if let data = UserDefaults.standard.data(forKey: categoryLimitsKey),
           let decoded = try? JSONDecoder().decode([CategoryLimit].self, from: data)
        {
            categoryLimits = decoded
        }
    }
    
    
    // save category limits to UserDefaults
    private func saveCategoryLimits()
    {
        if let encoded = try? JSONEncoder().encode(categoryLimits)
        {
            UserDefaults.standard.set(encoded, forKey: categoryLimitsKey)
        }
    }
   
    // expenses for a specifc date
    func expensesFor(day: Date) -> [ExpenseItem] {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    
    // load data using JSON decoding
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
            self.expenses = decoded
        }
    }
}
