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
