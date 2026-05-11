//
//  ExpenseItem.swift
//  Group5
//
//  Created by chuyue zhang on 2/5/2026.
//

import Foundation

// expense model
struct ExpenseItem: Identifiable, Codable {
    let id: UUID
    var spending: Double
    var category: ExpenseCategory
    var note: String?
    var date: Date
    
    init(id: UUID = UUID(), spending: Double, category: ExpenseCategory, note: String? = nil, date: Date = Date()){
        self.id = UUID()
        self.spending = spending
        self.category = category
        self.note = note
        self.date = date
    }
}
