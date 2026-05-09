//
//  CategoryLimit.swift
//  Group5
//
//  Created by KK on 8/5/2026.
//

import Foundation

struct CategoryLimit: Identifiable, Codable
{
    let id: UUID
    let category: ExpenseCategory
    var limit: Double
    
    init(id: UUID = UUID(), category: ExpenseCategory, limit: Double = 0)
    {
        self.id = id
        self.category = category
        self.limit = limit
    }
}
