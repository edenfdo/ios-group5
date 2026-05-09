//
//  BudgetCategoryItem.swift
//  Group5
//
//  Created by KK on 7/5/2026.
//

import Foundation

struct BudgetCategoryItem: Identifiable, Codable
{
    let id: UUID
    let category: ExpenseCategory
    var spent: Double
    var limit: Double

    init(id: UUID = UUID(), category: ExpenseCategory, spent: Double, limit: Double)
    {
        self.id = id
        self.category = category
        self.spent = spent
        self.limit = limit
    }
}
