//
//  BudgetViewModel.swift
//  Group5
//
//  Created by KK on 8/5/2026.
//

import Foundation
import Combine

class BudgetViewModel: ObservableObject
{
    // Total monthly budget amount
    @Published var monthlyBudget: Double = 0
    {
        didSet
        {
            saveMonthlyBudget()
        }
    }
    
    // Total amount spent
    @Published var monthlySpent: Double = 0
    
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
}
