//
//  AddExpenseViewModel.swift
//  Group5
//
//  Created by Eden Fernando on 3/5/2026.
//

import Foundation
import Combine

class ExpenseViewModel: ObservableObject {
    
    // Total amount spent
    @Published var monthlySpent: Double = 0
    
    
    private let saveKey = "SavedExpenses"
    
    @Published var expenses: [ExpenseItem] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    
    // Total monthly budget amount
    @Published var monthlyBudget: Double = 0
    {
        didSet
        {
            saveMonthlyBudget()
        }
    }
    
    // Budget limit information for all categories
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
    
    // UserDefaults storage
    private let monthlyBudgetKey = "SavedMonthlyBudget"
    private let categoryLimitsKey = "SavedCategoryLimits"
    
    // Initialiser
    init()
    {

        loadBudgetData()
        loadFromUserDefaults()
    }
    
    // Load monthly budget and category limits from UserDefaults
    private func loadBudgetData()
    {
        monthlyBudget = UserDefaults.standard.double(forKey: monthlyBudgetKey)
        
        if let data = UserDefaults.standard.data(forKey: categoryLimitsKey),
           let decoded = try? JSONDecoder().decode([CategoryLimit].self, from: data)
        {
            categoryLimits = decoded
        }
    }
    
    
    // Set the total monthly budget amount
    func setMonthlyBudget(_ amount: Double)
    {
        monthlyBudget = amount
    }
    
    // Save monthly budget to UserDefaults
    private func saveMonthlyBudget()
    {
        UserDefaults.standard.set(monthlyBudget, forKey: monthlyBudgetKey)
    }
    
    // Save category limits to UserDefaults
    private func saveCategoryLimits()
    {
        if let encoded = try? JSONEncoder().encode(categoryLimits)
        {
            UserDefaults.standard.set(encoded, forKey: categoryLimitsKey)
        }
    }
    
    // Calculate the total category budget limit
    var totalCategoryLimit: Double
    {
        categoryLimits.reduce(0) { $0 + $1.limit }
    }
    
    // Update the budget limit for a specific category
    // Returns true if the update succeeds
    // Returns false if the total category limit exceeds the monthly budget
    func setCategoryLimit(category: ExpenseCategory, limit: Double) -> Bool
    {
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
        
        // Reassign the whole array so didSet runs and UserDefaults saves
        categoryLimits = updatedLimits
        
        return true
    }
    
    
   
    
   
    
    // calculate the total for the "Today" tab
    var todayTotal: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // calculate total for the current month
    var currentMonthTotal: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.spending }
    }
    
    //calculate remaining budget
    var remainingMonthlyBudget: Double {
        return monthlyBudget - currentMonthTotal
    }

    // helper for Calendar colors (Total for a specific day)
    func totalFor(day: Date) -> Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + $1.spending }
    }

    func expensesFor(day: Date) -> [ExpenseItem] {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    // save data using JSON encoding
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // load data using JSON decoding
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
            self.expenses = decoded
        }
    }
    
    func deleteExpense(_ item: ExpenseItem) {
        expenses.removeAll { $0.id == item.id }
    }
}
