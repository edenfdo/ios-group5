//
//  AddExpenseViewModel.swift
//  Group5
//
//  Created by Eden Fernando on 3/5/2026.
//

import Foundation
import Combine

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [ExpenseItem] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    // 1. Add a monthly budget property
    @Published var monthlyBudget: Double = 100.0 // Default value
    
    private let saveKey = "SavedExpenses"
    
    init() {
        loadFromUserDefaults()
    }
    
    // Calculate the total for the "Today" tab
    var todayTotal: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // 2. Calculate total for the current month
    var currentMonthTotal: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.spending }
    }
    
    // 3. Calculate remaining budget
    var remainingMonthlyBudget: Double {
        return monthlyBudget - currentMonthTotal
    }

    // 4. Helper for Calendar colors (Total for a specific day)
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

    // Save data using JSON encoding
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // Load data using JSON decoding
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
            self.expenses = decoded
        }
    }
}
